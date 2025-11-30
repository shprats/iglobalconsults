"""
Case Model
SQLAlchemy model for cases table
"""

from sqlalchemy import Column, String, Text, Integer, Boolean, DateTime, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.core.database import Base
import uuid


class Case(Base):
    __tablename__ = "cases"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    requesting_doctor_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    patient_id = Column(UUID(as_uuid=True), index=True)
    title = Column(String(255), nullable=False)
    chief_complaint = Column(Text)
    history = Column(Text)
    physical_exam_notes = Column(Text)
    urgency = Column(String(20), nullable=False, index=True)
    status = Column(String(50), default='draft', index=True)
    assigned_volunteer_id = Column(UUID(as_uuid=True), index=True)
    scheduled_consultation_id = Column(UUID(as_uuid=True))
    priority_score = Column(Integer, default=0, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    submitted_at = Column(DateTime(timezone=True))
    synced_at = Column(DateTime(timezone=True))
    is_offline = Column(Boolean, default=False, index=True)
    device_id = Column(String(255))
    case_metadata = Column("metadata", JSON)  # Use case_metadata as attribute name, but "metadata" as column name
