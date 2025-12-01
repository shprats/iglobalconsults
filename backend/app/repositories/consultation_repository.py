"""
Consultation Repository
Database operations for consultations
"""

from sqlalchemy.orm import Session
from sqlalchemy import select, and_, desc, func
from typing import Optional, List
from uuid import UUID
from datetime import datetime, timezone
from app.models.consultation import Consultation


class ConsultationRepository:
    def __init__(self, db: Session):
        self.db = db
    
    def create(self, consultation_data: dict) -> Consultation:
        """Create a new consultation"""
        consultation = Consultation(**consultation_data)
        self.db.add(consultation)
        self.db.commit()
        self.db.refresh(consultation)
        return consultation
    
    def get_by_id(self, consultation_id: str) -> Optional[Consultation]:
        """Get consultation by ID"""
        try:
            uuid_id = UUID(consultation_id)
        except ValueError:
            return None
        stmt = select(Consultation).where(Consultation.id == uuid_id)
        result = self.db.execute(stmt)
        return result.scalar_one_or_none()
    
    def get_by_case(self, case_id: str) -> Optional[Consultation]:
        """Get consultation for a case"""
        try:
            uuid_id = UUID(case_id)
        except ValueError:
            return None
        stmt = select(Consultation).where(Consultation.case_id == uuid_id)
        result = self.db.execute(stmt)
        return result.scalar_one_or_none()
    
    def list_by_doctor(
        self,
        doctor_id: str,
        status: Optional[str] = None,
        page: int = 1,
        page_size: int = 20
    ) -> tuple[List[Consultation], int]:
        """List consultations for a requesting doctor"""
        try:
            doctor_uuid = UUID(doctor_id)
        except ValueError:
            return [], 0
        
        stmt = select(Consultation).where(Consultation.requesting_doctor_id == doctor_uuid)
        
        if status:
            stmt = stmt.where(Consultation.status == status)
        
        # Get total count
        count_stmt = select(func.count()).select_from(stmt.subquery())
        total = self.db.execute(count_stmt).scalar() or 0
        
        # Apply pagination and ordering
        stmt = stmt.order_by(desc(Consultation.scheduled_start))
        stmt = stmt.offset((page - 1) * page_size).limit(page_size)
        
        result = self.db.execute(stmt)
        consultations = result.scalars().all()
        
        return list(consultations), total
    
    def list_by_volunteer(
        self,
        volunteer_id: str,
        status: Optional[str] = None,
        page: int = 1,
        page_size: int = 20
    ) -> tuple[List[Consultation], int]:
        """List consultations for a volunteer"""
        try:
            volunteer_uuid = UUID(volunteer_id)
        except ValueError:
            return [], 0
        
        stmt = select(Consultation).where(Consultation.volunteer_id == volunteer_uuid)
        
        if status:
            stmt = stmt.where(Consultation.status == status)
        
        # Get total count
        count_stmt = select(func.count()).select_from(stmt.subquery())
        total = self.db.execute(count_stmt).scalar() or 0
        
        # Apply pagination and ordering
        stmt = stmt.order_by(desc(Consultation.scheduled_start))
        stmt = stmt.offset((page - 1) * page_size).limit(page_size)
        
        result = self.db.execute(stmt)
        consultations = result.scalars().all()
        
        return list(consultations), total
    
    def list_upcoming(
        self,
        user_id: str,
        role: str,
        limit: int = 10
    ) -> List[Consultation]:
        """List upcoming consultations for a user"""
        try:
            user_uuid = UUID(user_id)
        except ValueError:
            return []
        
        now = datetime.now(timezone.utc)
        
        if role == 'volunteer_physician':
            stmt = select(Consultation).where(
                and_(
                    Consultation.volunteer_id == user_uuid,
                    Consultation.status == 'scheduled',
                    Consultation.scheduled_start > now
                )
            )
        elif role == 'requesting_doctor':
            stmt = select(Consultation).where(
                and_(
                    Consultation.requesting_doctor_id == user_uuid,
                    Consultation.status == 'scheduled',
                    Consultation.scheduled_start > now
                )
            )
        else:
            return []
        
        stmt = stmt.order_by(Consultation.scheduled_start).limit(limit)
        result = self.db.execute(stmt)
        return list(result.scalars().all())
    
    def update(self, consultation: Consultation, update_data: dict) -> Consultation:
        """Update consultation"""
        for key, value in update_data.items():
            if value is not None:
                setattr(consultation, key, value)
        
        # Calculate duration if both start and end are provided
        if 'actual_start' in update_data and 'actual_end' in update_data:
            if update_data['actual_start'] and update_data['actual_end']:
                delta = update_data['actual_end'] - update_data['actual_start']
                consultation.duration_minutes = int(delta.total_seconds() / 60)
        
        self.db.commit()
        self.db.refresh(consultation)
        return consultation

