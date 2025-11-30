"""
Case Repository
Database operations for cases
"""

from sqlalchemy.orm import Session
from sqlalchemy import select, and_, or_, desc, func
from typing import Optional, List
from uuid import UUID
from app.models.case import Case


class CaseRepository:
    def __init__(self, db: Session):
        self.db = db
    
    def create(self, case_data: dict) -> Case:
        """Create a new case"""
        case = Case(**case_data)
        self.db.add(case)
        self.db.commit()
        self.db.refresh(case)
        return case
    
    def get_by_id(self, case_id: str, doctor_id: Optional[str] = None) -> Optional[Case]:
        """Get case by ID, optionally filtered by doctor"""
        try:
            uuid_id = UUID(case_id)
        except ValueError:
            return None
        
        stmt = select(Case).where(Case.id == uuid_id)
        
        if doctor_id:
            try:
                doctor_uuid = UUID(doctor_id)
                stmt = stmt.where(Case.requesting_doctor_id == doctor_uuid)
            except ValueError:
                return None
        
        result = self.db.execute(stmt)
        return result.scalar_one_or_none()
    
    def list_by_doctor(
        self, 
        doctor_id: str, 
        status: Optional[str] = None,
        page: int = 1,
        page_size: int = 20
    ) -> tuple[List[Case], int]:
        """List cases for a doctor with pagination"""
        try:
            doctor_uuid = UUID(doctor_id)
        except ValueError:
            return [], 0
        
        stmt = select(Case).where(Case.requesting_doctor_id == doctor_uuid)
        
        if status:
            stmt = stmt.where(Case.status == status)
        
        # Get total count
        count_stmt = select(func.count()).select_from(stmt.subquery())
        total = self.db.execute(count_stmt).scalar() or 0
        
        # Apply pagination and ordering
        stmt = stmt.order_by(desc(Case.created_at))
        stmt = stmt.offset((page - 1) * page_size).limit(page_size)
        
        result = self.db.execute(stmt)
        cases = result.scalars().all()
        
        return list(cases), total
    
    def update(self, case: Case, update_data: dict) -> Case:
        """Update case"""
        for key, value in update_data.items():
            if value is not None:
                setattr(case, key, value)
        self.db.commit()
        self.db.refresh(case)
        return case
    
    def delete(self, case: Case) -> None:
        """Delete case"""
        self.db.delete(case)
        self.db.commit()

