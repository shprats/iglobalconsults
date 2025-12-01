"""
Consultations API Endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from datetime import datetime, timezone
from typing import Optional
from uuid import UUID

from app.core.database import get_db
from app.api.v1.auth import get_current_user
from app.schemas.auth import UserResponse
from app.schemas.consultation import (
    ConsultationCreate,
    ConsultationUpdate,
    ConsultationResponse,
    ConsultationStartResponse,
    ConsultationListResponse
)
from app.repositories.consultation_repository import ConsultationRepository
from app.repositories.case_repository import CaseRepository
from app.services.agora_service import AgoraService

router = APIRouter()
agora_service = AgoraService()


@router.post("/", response_model=ConsultationResponse, status_code=status.HTTP_201_CREATED)
async def create_consultation(
    consultation_data: ConsultationCreate,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new consultation (assign volunteer to case)"""
    # Only volunteers or admins can create consultations
    if current_user.role not in ['volunteer_physician', 'site_admin']:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only volunteers can create consultations"
        )
    
    case_repo = CaseRepository(db)
    case = case_repo.get_by_id(consultation_data.case_id)
    
    if not case:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Case not found"
        )
    
    # Check if consultation already exists for this case
    consultation_repo = ConsultationRepository(db)
    existing = consultation_repo.get_by_case(consultation_data.case_id)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Consultation already exists for this case"
        )
    
    # Validate scheduled times
    if consultation_data.scheduled_end <= consultation_data.scheduled_start:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="scheduled_end must be after scheduled_start"
        )
    
    # Create consultation
    consultation_dict = {
        "case_id": UUID(consultation_data.case_id),
        "volunteer_id": UUID(current_user.id),
        "requesting_doctor_id": UUID(case.requesting_doctor_id),
        "scheduled_start": consultation_data.scheduled_start,
        "scheduled_end": consultation_data.scheduled_end,
        "status": "scheduled"
    }
    
    if consultation_data.patient_id:
        try:
            consultation_dict["patient_id"] = UUID(consultation_data.patient_id)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid patient_id format"
            )
    
    consultation = consultation_repo.create(consultation_dict)
    
    # Update case status
    case_repo.update(case, {
        "status": "assigned",
        "assigned_volunteer_id": current_user.id
    })
    
    return ConsultationResponse(
        id=str(consultation.id),
        case_id=str(consultation.case_id),
        volunteer_id=str(consultation.volunteer_id),
        patient_id=str(consultation.patient_id) if consultation.patient_id else None,
        requesting_doctor_id=str(consultation.requesting_doctor_id),
        scheduled_start=consultation.scheduled_start,
        scheduled_end=consultation.scheduled_end,
        actual_start=consultation.actual_start,
        actual_end=consultation.actual_end,
        duration_minutes=consultation.duration_minutes,
        status=consultation.status,
        agora_channel_name=consultation.agora_channel_name,
        connection_quality=consultation.connection_quality,
        fallback_mode=consultation.fallback_mode,
        volunteer_notes=consultation.volunteer_notes,
        diagnosis=consultation.diagnosis,
        treatment_plan=consultation.treatment_plan,
        follow_up_required=consultation.follow_up_required,
        follow_up_notes=consultation.follow_up_notes,
        recording_url=consultation.recording_url,
        recording_consent_given=consultation.recording_consent_given,
        created_at=consultation.created_at,
        updated_at=consultation.updated_at,
        cancelled_at=consultation.cancelled_at
    )


@router.get("/", response_model=ConsultationListResponse)
async def list_consultations(
    status_filter: Optional[str] = Query(None, alias="status"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """List consultations for current user"""
    repo = ConsultationRepository(db)
    
    if current_user.role == 'volunteer_physician':
        consultations, total = repo.list_by_volunteer(
            volunteer_id=current_user.id,
            status=status_filter,
            page=page,
            page_size=page_size
        )
    elif current_user.role == 'requesting_doctor':
        consultations, total = repo.list_by_doctor(
            doctor_id=current_user.id,
            status=status_filter,
            page=page,
            page_size=page_size
        )
    else:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only doctors and volunteers can list consultations"
        )
    
    consultation_responses = [
        ConsultationResponse(
            id=str(c.id),
            case_id=str(c.case_id),
            volunteer_id=str(c.volunteer_id),
            patient_id=str(c.patient_id) if c.patient_id else None,
            requesting_doctor_id=str(c.requesting_doctor_id),
            scheduled_start=c.scheduled_start,
            scheduled_end=c.scheduled_end,
            actual_start=c.actual_start,
            actual_end=c.actual_end,
            duration_minutes=c.duration_minutes,
            status=c.status,
            agora_channel_name=c.agora_channel_name,
            connection_quality=c.connection_quality,
            fallback_mode=c.fallback_mode,
            volunteer_notes=c.volunteer_notes,
            diagnosis=c.diagnosis,
            treatment_plan=c.treatment_plan,
            follow_up_required=c.follow_up_required,
            follow_up_notes=c.follow_up_notes,
            recording_url=c.recording_url,
            recording_consent_given=c.recording_consent_given,
            created_at=c.created_at,
            updated_at=c.updated_at,
            cancelled_at=c.cancelled_at
        )
        for c in consultations
    ]
    
    return ConsultationListResponse(
        consultations=consultation_responses,
        total=total,
        page=page,
        page_size=page_size
    )


@router.get("/{consultation_id}", response_model=ConsultationResponse)
async def get_consultation(
    consultation_id: str,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get consultation by ID"""
    repo = ConsultationRepository(db)
    consultation = repo.get_by_id(consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Consultation not found"
        )
    
    # Verify access
    if current_user.role == 'requesting_doctor':
        if str(consultation.requesting_doctor_id) != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied"
            )
    elif current_user.role == 'volunteer_physician':
        if str(consultation.volunteer_id) != current_user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Access denied"
            )
    elif current_user.role != 'site_admin':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied"
        )
    
    return ConsultationResponse(
        id=str(consultation.id),
        case_id=str(consultation.case_id),
        volunteer_id=str(consultation.volunteer_id),
        patient_id=str(consultation.patient_id) if consultation.patient_id else None,
        requesting_doctor_id=str(consultation.requesting_doctor_id),
        scheduled_start=consultation.scheduled_start,
        scheduled_end=consultation.scheduled_end,
        actual_start=consultation.actual_start,
        actual_end=consultation.actual_end,
        duration_minutes=consultation.duration_minutes,
        status=consultation.status,
        agora_channel_name=consultation.agora_channel_name,
        connection_quality=consultation.connection_quality,
        fallback_mode=consultation.fallback_mode,
        volunteer_notes=consultation.volunteer_notes,
        diagnosis=consultation.diagnosis,
        treatment_plan=consultation.treatment_plan,
        follow_up_required=consultation.follow_up_required,
        follow_up_notes=consultation.follow_up_notes,
        recording_url=consultation.recording_url,
        recording_consent_given=consultation.recording_consent_given,
        created_at=consultation.created_at,
        updated_at=consultation.updated_at,
        cancelled_at=consultation.cancelled_at
    )


@router.post("/{consultation_id}/start", response_model=ConsultationStartResponse)
async def start_consultation(
    consultation_id: str,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Start a consultation and generate Agora token"""
    repo = ConsultationRepository(db)
    consultation = repo.get_by_id(consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Consultation not found"
        )
    
    # Verify access
    if current_user.role == 'requesting_doctor':
        if str(consultation.requesting_doctor_id) != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
    elif current_user.role == 'volunteer_physician':
        if str(consultation.volunteer_id) != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
    else:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
    
    # Check if consultation is scheduled
    if consultation.status != 'scheduled':
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot start consultation with status: {consultation.status}"
        )
    
    # Generate Agora channel name and token
    channel_name = agora_service.generate_channel_name(str(consultation.id))
    agora_token = agora_service.generate_token(
        channel_name=channel_name,
        user_id=current_user.id,
        role="publisher"
    )
    
    if not agora_token:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate Agora token"
        )
    
    # Update consultation
    from app.core.config import settings
    repo.update(consultation, {
        "status": "in_progress",
        "actual_start": datetime.now(timezone.utc),
        "agora_channel_name": channel_name,
        "agora_app_id": settings.AGORA_APP_ID
    })
    
    return ConsultationStartResponse(
        consultation_id=str(consultation.id),
        agora_channel_name=channel_name,
        agora_app_id=settings.AGORA_APP_ID or "",
        agora_token=agora_token
    )


@router.post("/{consultation_id}/end", response_model=ConsultationResponse)
async def end_consultation(
    consultation_id: str,
    consultation_update: Optional[ConsultationUpdate] = None,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """End a consultation"""
    repo = ConsultationRepository(db)
    consultation = repo.get_by_id(consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Consultation not found"
        )
    
    # Verify access
    if current_user.role == 'requesting_doctor':
        if str(consultation.requesting_doctor_id) != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
    elif current_user.role == 'volunteer_physician':
        if str(consultation.volunteer_id) != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
    else:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
    
    # Check if consultation is in progress
    if consultation.status != 'in_progress':
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Cannot end consultation with status: {consultation.status}"
        )
    
    # Update consultation
    update_data = {
        "status": "completed",
        "actual_end": datetime.now(timezone.utc)
    }
    
    if consultation_update:
        update_data.update(consultation_update.model_dump(exclude_unset=True))
    
    # Calculate duration
    if consultation.actual_start and update_data.get("actual_end"):
        delta = update_data["actual_end"] - consultation.actual_start
        update_data["duration_minutes"] = int(delta.total_seconds() / 60)
    
    updated = repo.update(consultation, update_data)
    
    # Update case status
    case_repo = CaseRepository(db)
    case = case_repo.get_by_id(str(consultation.case_id))
    if case:
        case_repo.update(case, {"status": "completed"})
    
    return ConsultationResponse(
        id=str(updated.id),
        case_id=str(updated.case_id),
        volunteer_id=str(updated.volunteer_id),
        patient_id=str(updated.patient_id) if updated.patient_id else None,
        requesting_doctor_id=str(updated.requesting_doctor_id),
        scheduled_start=updated.scheduled_start,
        scheduled_end=updated.scheduled_end,
        actual_start=updated.actual_start,
        actual_end=updated.actual_end,
        duration_minutes=updated.duration_minutes,
        status=updated.status,
        agora_channel_name=updated.agora_channel_name,
        connection_quality=updated.connection_quality,
        fallback_mode=updated.fallback_mode,
        volunteer_notes=updated.volunteer_notes,
        diagnosis=updated.diagnosis,
        treatment_plan=updated.treatment_plan,
        follow_up_required=updated.follow_up_required,
        follow_up_notes=updated.follow_up_notes,
        recording_url=updated.recording_url,
        recording_consent_given=updated.recording_consent_given,
        created_at=updated.created_at,
        updated_at=updated.updated_at,
        cancelled_at=updated.cancelled_at
    )


@router.put("/{consultation_id}", response_model=ConsultationResponse)
async def update_consultation(
    consultation_id: str,
    consultation_update: ConsultationUpdate,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update consultation details"""
    repo = ConsultationRepository(db)
    consultation = repo.get_by_id(consultation_id)
    
    if not consultation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Consultation not found"
        )
    
    # Verify access
    if current_user.role == 'requesting_doctor':
        if str(consultation.requesting_doctor_id) != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
    elif current_user.role == 'volunteer_physician':
        if str(consultation.volunteer_id) != current_user.id:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
    else:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied")
    
    updated = repo.update(consultation, consultation_update.model_dump(exclude_unset=True))
    
    return ConsultationResponse(
        id=str(updated.id),
        case_id=str(updated.case_id),
        volunteer_id=str(updated.volunteer_id),
        patient_id=str(updated.patient_id) if updated.patient_id else None,
        requesting_doctor_id=str(updated.requesting_doctor_id),
        scheduled_start=updated.scheduled_start,
        scheduled_end=updated.scheduled_end,
        actual_start=updated.actual_start,
        actual_end=updated.actual_end,
        duration_minutes=updated.duration_minutes,
        status=updated.status,
        agora_channel_name=updated.agora_channel_name,
        connection_quality=updated.connection_quality,
        fallback_mode=updated.fallback_mode,
        volunteer_notes=updated.volunteer_notes,
        diagnosis=updated.diagnosis,
        treatment_plan=updated.treatment_plan,
        follow_up_required=updated.follow_up_required,
        follow_up_notes=updated.follow_up_notes,
        recording_url=updated.recording_url,
        recording_consent_given=updated.recording_consent_given,
        created_at=updated.created_at,
        updated_at=updated.updated_at,
        cancelled_at=updated.cancelled_at
    )


@router.get("/upcoming/list", response_model=list[ConsultationResponse])
async def list_upcoming_consultations(
    limit: int = Query(10, ge=1, le=50),
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """List upcoming consultations for current user"""
    repo = ConsultationRepository(db)
    
    if current_user.role not in ['volunteer_physician', 'requesting_doctor']:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only doctors and volunteers can view upcoming consultations"
        )
    
    consultations = repo.list_upcoming(
        user_id=current_user.id,
        role=current_user.role,
        limit=limit
    )
    
    return [
        ConsultationResponse(
            id=str(c.id),
            case_id=str(c.case_id),
            volunteer_id=str(c.volunteer_id),
            patient_id=str(c.patient_id) if c.patient_id else None,
            requesting_doctor_id=str(c.requesting_doctor_id),
            scheduled_start=c.scheduled_start,
            scheduled_end=c.scheduled_end,
            actual_start=c.actual_start,
            actual_end=c.actual_end,
            duration_minutes=c.duration_minutes,
            status=c.status,
            agora_channel_name=c.agora_channel_name,
            connection_quality=c.connection_quality,
            fallback_mode=c.fallback_mode,
            volunteer_notes=c.volunteer_notes,
            diagnosis=c.diagnosis,
            treatment_plan=c.treatment_plan,
            follow_up_required=c.follow_up_required,
            follow_up_notes=c.follow_up_notes,
            recording_url=c.recording_url,
            recording_consent_given=c.recording_consent_given,
            created_at=c.created_at,
            updated_at=c.updated_at,
            cancelled_at=c.cancelled_at
        )
        for c in consultations
    ]

