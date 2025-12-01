"""
Consultation Model
SQLAlchemy model for consultations table
"""

from sqlalchemy import Column, String, Integer, Boolean, Text, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.core.database import Base
import uuid


class Consultation(Base):
    __tablename__ = "consultations"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    case_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    volunteer_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    patient_id = Column(UUID(as_uuid=True), index=True)
    requesting_doctor_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    scheduled_start = Column(DateTime(timezone=True), nullable=False, index=True)
    scheduled_end = Column(DateTime(timezone=True), nullable=False)
    actual_start = Column(DateTime(timezone=True))
    actual_end = Column(DateTime(timezone=True))
    duration_minutes = Column(Integer)
    status = Column(String(50), default='scheduled', index=True)
    agora_channel_name = Column(String(255))
    agora_app_id = Column(String(255))
    connection_quality = Column(String(20))
    fallback_mode = Column(String(50))
    volunteer_notes = Column(Text)
    diagnosis = Column(Text)
    treatment_plan = Column(Text)
    follow_up_required = Column(Boolean, default=False)
    follow_up_notes = Column(Text)
    recording_url = Column(Text)
    recording_consent_given = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    cancelled_at = Column(DateTime(timezone=True))
    cancelled_by = Column(UUID(as_uuid=True))
    cancellation_reason = Column(Text)

