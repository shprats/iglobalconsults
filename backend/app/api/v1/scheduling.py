"""
Scheduling API Endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime
from uuid import UUID

from app.core.database import get_db
from app.api.v1.auth import get_current_user
from app.schemas.auth import UserResponse
from app.schemas.scheduling import (
    AvailabilityBlockCreate,
    AvailabilityBlockResponse,
    AppointmentSlotResponse,
    AppointmentSlotListResponse,
    BookAppointmentRequest
)
from app.repositories.scheduling_repository import SchedulingRepository
from app.repositories.consultation_repository import ConsultationRepository
from app.repositories.case_repository import CaseRepository

router = APIRouter()


@router.post("/availability", response_model=AvailabilityBlockResponse, status_code=status.HTTP_201_CREATED)
async def create_availability_block(
    block_data: AvailabilityBlockCreate,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create availability block (volunteers only)"""
    if current_user.role != 'volunteer_physician':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only volunteers can create availability blocks"
        )
    
    # Validate times
    if block_data.end_time <= block_data.start_time:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="end_time must be after start_time"
        )
    
    repo = SchedulingRepository(db)
    
    block_dict = {
        "volunteer_id": UUID(current_user.id),
        "start_time": block_data.start_time,
        "end_time": block_data.end_time,
        "timezone": block_data.timezone,
        "slot_duration_minutes": block_data.slot_duration_minutes,
        "is_recurring": block_data.is_recurring,
        "recurrence_pattern": block_data.recurrence_pattern,
        "status": "active"
    }
    
    block = repo.create_availability_block(block_dict)
    
    # Generate appointment slots from the block
    slots = repo.generate_slots_from_block(block)
    
    return AvailabilityBlockResponse(
        id=str(block.id),
        volunteer_id=str(block.volunteer_id),
        start_time=block.start_time,
        end_time=block.end_time,
        timezone=block.timezone,
        slot_duration_minutes=block.slot_duration_minutes,
        is_recurring=block.is_recurring,
        recurrence_pattern=block.recurrence_pattern,
        status=block.status,
        created_at=block.created_at,
        updated_at=block.updated_at
    )


@router.get("/availability", response_model=list[AvailabilityBlockResponse])
async def list_availability_blocks(
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """List availability blocks for current user"""
    if current_user.role != 'volunteer_physician':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only volunteers can view availability blocks"
        )
    
    repo = SchedulingRepository(db)
    blocks = repo.list_availability_blocks(volunteer_id=current_user.id)
    
    return [
        AvailabilityBlockResponse(
            id=str(b.id),
            volunteer_id=str(b.volunteer_id),
            start_time=b.start_time,
            end_time=b.end_time,
            timezone=b.timezone,
            slot_duration_minutes=b.slot_duration_minutes,
            is_recurring=b.is_recurring,
            recurrence_pattern=b.recurrence_pattern,
            status=b.status,
            created_at=b.created_at,
            updated_at=b.updated_at
        )
        for b in blocks
    ]


@router.put("/availability/{block_id}", response_model=AvailabilityBlockResponse)
async def update_availability_block(
    block_id: str,
    block_update: AvailabilityBlockCreate,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update an availability block"""
    if current_user.role != 'volunteer_physician':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only volunteers can update availability blocks"
        )
    
    repo = SchedulingRepository(db)
    block = repo.get_availability_block(block_id)
    
    if not block:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Availability block not found"
        )
    
    # Verify ownership
    if str(block.volunteer_id) != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only update your own availability blocks"
        )
    
    # Update block
    update_data = {
        "start_time": block_update.start_time,
        "end_time": block_update.end_time,
        "timezone": block_update.timezone,
        "slot_duration_minutes": block_update.slot_duration_minutes,
        "is_recurring": block_update.is_recurring,
        "recurrence_pattern": block_update.recurrence_pattern,
    }
    
    updated_block = repo.update_availability_block(block, update_data)
    
    return AvailabilityBlockResponse(
        id=str(updated_block.id),
        volunteer_id=str(updated_block.volunteer_id),
        start_time=updated_block.start_time,
        end_time=updated_block.end_time,
        timezone=updated_block.timezone,
        slot_duration_minutes=updated_block.slot_duration_minutes,
        is_recurring=updated_block.is_recurring,
        recurrence_pattern=updated_block.recurrence_pattern,
        status=updated_block.status,
        created_at=updated_block.created_at,
        updated_at=updated_block.updated_at
    )


@router.get("/slots", response_model=AppointmentSlotListResponse)
async def get_available_slots(
    volunteer_id: Optional[str] = Query(None),
    start_date: Optional[datetime] = Query(None),
    end_date: Optional[datetime] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=100),
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get available appointment slots"""
    # Only requesting doctors can view available slots
    if current_user.role != 'requesting_doctor':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only requesting doctors can view available slots"
        )
    
    repo = SchedulingRepository(db)
    slots, total = repo.get_available_slots(
        volunteer_id=volunteer_id,
        start_date=start_date,
        end_date=end_date,
        page=page,
        page_size=page_size
    )
    
    slot_responses = [
        AppointmentSlotResponse(
            id=str(s.id),
            availability_block_id=str(s.availability_block_id) if s.availability_block_id else None,
            volunteer_id=str(s.volunteer_id),
            start_time=s.start_time,
            end_time=s.end_time,
            timezone=s.timezone,
            status=s.status,
            consultation_id=str(s.consultation_id) if s.consultation_id else None,
            created_at=s.created_at
        )
        for s in slots
    ]
    
    return AppointmentSlotListResponse(
        slots=slot_responses,
        total=total,
        page=page,
        page_size=page_size
    )


@router.post("/appointments", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_appointment(
    appointment_data: BookAppointmentRequest,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Book an appointment (create consultation from slot)"""
    if current_user.role != 'requesting_doctor':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only requesting doctors can book appointments"
        )
    
    scheduling_repo = SchedulingRepository(db)
    slot = scheduling_repo.get_slot(appointment_data.slot_id)
    
    if not slot:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Appointment slot not found"
        )
    
    if slot.status != 'available':
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Slot is not available"
        )
    
    # Verify case exists and belongs to user
    case_repo = CaseRepository(db)
    case = case_repo.get_by_id(appointment_data.case_id, doctor_id=current_user.id)
    
    if not case:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Case not found"
        )
    
    # Check if consultation already exists for this case
    consultation_repo = ConsultationRepository(db)
    existing = consultation_repo.get_by_case(appointment_data.case_id)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Consultation already exists for this case"
        )
    
    # Create consultation
    consultation_dict = {
        "case_id": UUID(appointment_data.case_id),
        "volunteer_id": slot.volunteer_id,
        "requesting_doctor_id": UUID(current_user.id),
        "scheduled_start": slot.start_time,
        "scheduled_end": slot.end_time,
        "status": "scheduled"
    }
    
    if appointment_data.patient_id:
        try:
            consultation_dict["patient_id"] = UUID(appointment_data.patient_id)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid patient_id format"
            )
    
    consultation = consultation_repo.create(consultation_dict)
    
    # Book the slot
    scheduling_repo.book_slot(slot, str(consultation.id))
    
    # Update case status
    case_repo.update(case, {
        "status": "assigned",
        "assigned_volunteer_id": str(slot.volunteer_id)
    })
    
    return {
        "consultation_id": str(consultation.id),
        "slot_id": str(slot.id),
        "scheduled_start": slot.start_time.isoformat(),
        "scheduled_end": slot.end_time.isoformat(),
        "message": "Appointment booked successfully"
    }

