"""
Scheduling Repository
Database operations for availability and appointment slots
"""

from sqlalchemy.orm import Session
from sqlalchemy import select, and_, or_, desc, func
from typing import Optional, List
from uuid import UUID
from datetime import datetime, timezone, timedelta
from app.models.availability import AvailabilityBlock, AppointmentSlot


class SchedulingRepository:
    def __init__(self, db: Session):
        self.db = db
    
    # Availability Block Operations
    def create_availability_block(self, block_data: dict) -> AvailabilityBlock:
        """Create a new availability block"""
        block = AvailabilityBlock(**block_data)
        self.db.add(block)
        self.db.commit()
        self.db.refresh(block)
        return block
    
    def get_availability_block(self, block_id: str) -> Optional[AvailabilityBlock]:
        """Get availability block by ID"""
        try:
            uuid_id = UUID(block_id)
        except ValueError:
            return None
        stmt = select(AvailabilityBlock).where(AvailabilityBlock.id == uuid_id)
        result = self.db.execute(stmt)
        return result.scalar_one_or_none()
    
    def list_availability_blocks(
        self,
        volunteer_id: str,
        status: Optional[str] = None
    ) -> List[AvailabilityBlock]:
        """List availability blocks for a volunteer"""
        try:
            volunteer_uuid = UUID(volunteer_id)
        except ValueError:
            return []
        
        stmt = select(AvailabilityBlock).where(AvailabilityBlock.volunteer_id == volunteer_uuid)
        
        if status:
            stmt = stmt.where(AvailabilityBlock.status == status)
        else:
            stmt = stmt.where(AvailabilityBlock.status == 'active')
        
        stmt = stmt.order_by(AvailabilityBlock.start_time)
        result = self.db.execute(stmt)
        return list(result.scalars().all())
    
    def update_availability_block(self, block: AvailabilityBlock, update_data: dict) -> AvailabilityBlock:
        """Update availability block"""
        for key, value in update_data.items():
            if value is not None:
                setattr(block, key, value)
        self.db.commit()
        self.db.refresh(block)
        return block
    
    def delete_availability_block(self, block: AvailabilityBlock) -> None:
        """Delete availability block"""
        self.db.delete(block)
        self.db.commit()
    
    # Appointment Slot Operations
    def generate_slots_from_block(self, block: AvailabilityBlock) -> List[AppointmentSlot]:
        """Generate appointment slots from an availability block"""
        slots = []
        current_time = block.start_time
        slot_duration = timedelta(minutes=block.slot_duration_minutes)
        
        while current_time + slot_duration <= block.end_time:
            slot = AppointmentSlot(
                availability_block_id=block.id,
                volunteer_id=block.volunteer_id,
                start_time=current_time,
                end_time=current_time + slot_duration,
                timezone=block.timezone,
                status='available'
            )
            self.db.add(slot)
            slots.append(slot)
            current_time += slot_duration
        
        self.db.commit()
        for slot in slots:
            self.db.refresh(slot)
        return slots
    
    def get_available_slots(
        self,
        volunteer_id: Optional[str] = None,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        page: int = 1,
        page_size: int = 50
    ) -> tuple[List[AppointmentSlot], int]:
        """Get available appointment slots"""
        now = datetime.now(timezone.utc)
        start_date = start_date or now
        
        stmt = select(AppointmentSlot).where(
            and_(
                AppointmentSlot.status == 'available',
                AppointmentSlot.start_time >= start_date
            )
        )
        
        if volunteer_id:
            try:
                volunteer_uuid = UUID(volunteer_id)
                stmt = stmt.where(AppointmentSlot.volunteer_id == volunteer_uuid)
            except ValueError:
                return [], 0
        
        if end_date:
            stmt = stmt.where(AppointmentSlot.start_time <= end_date)
        
        # Get total count
        count_stmt = select(func.count()).select_from(stmt.subquery())
        total = self.db.execute(count_stmt).scalar() or 0
        
        # Apply pagination and ordering
        stmt = stmt.order_by(AppointmentSlot.start_time)
        stmt = stmt.offset((page - 1) * page_size).limit(page_size)
        
        result = self.db.execute(stmt)
        slots = result.scalars().all()
        
        return list(slots), total
    
    def get_slot(self, slot_id: str) -> Optional[AppointmentSlot]:
        """Get appointment slot by ID"""
        try:
            uuid_id = UUID(slot_id)
        except ValueError:
            return None
        stmt = select(AppointmentSlot).where(AppointmentSlot.id == uuid_id)
        result = self.db.execute(stmt)
        return result.scalar_one_or_none()
    
    def book_slot(self, slot: AppointmentSlot, consultation_id: str) -> AppointmentSlot:
        """Book an appointment slot"""
        try:
            consultation_uuid = UUID(consultation_id)
        except ValueError:
            raise ValueError("Invalid consultation_id format")
        
        if slot.status != 'available':
            raise ValueError("Slot is not available")
        
        slot.status = 'booked'
        slot.consultation_id = consultation_uuid
        self.db.commit()
        self.db.refresh(slot)
        return slot
    
    def cancel_slot(self, slot: AppointmentSlot) -> AppointmentSlot:
        """Cancel a booked slot"""
        slot.status = 'available'
        slot.consultation_id = None
        self.db.commit()
        self.db.refresh(slot)
        return slot

