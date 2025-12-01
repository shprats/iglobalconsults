"""
Availability Models
SQLAlchemy models for scheduling tables
"""

from sqlalchemy import Column, String, Integer, Boolean, DateTime, JSON
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func
from app.core.database import Base
import uuid


class AvailabilityBlock(Base):
    __tablename__ = "availability_blocks"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    volunteer_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    start_time = Column(DateTime(timezone=True), nullable=False, index=True)
    end_time = Column(DateTime(timezone=True), nullable=False)
    timezone = Column(String(50), nullable=False)
    slot_duration_minutes = Column(Integer, default=10)
    is_recurring = Column(Boolean, default=False)
    recurrence_pattern = Column(JSONB)
    status = Column(String(50), default='active', index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())


class AppointmentSlot(Base):
    __tablename__ = "appointment_slots"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    availability_block_id = Column(UUID(as_uuid=True), index=True)
    volunteer_id = Column(UUID(as_uuid=True), nullable=False, index=True)
    start_time = Column(DateTime(timezone=True), nullable=False, index=True)
    end_time = Column(DateTime(timezone=True), nullable=False)
    timezone = Column(String(50), nullable=False)
    status = Column(String(50), default='available', index=True)
    consultation_id = Column(UUID(as_uuid=True), index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

