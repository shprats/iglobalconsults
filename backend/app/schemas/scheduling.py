"""
Scheduling Schemas
Pydantic models for scheduling request/response validation
"""

from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime


class AvailabilityBlockCreate(BaseModel):
    start_time: datetime
    end_time: datetime
    timezone: str = "UTC"
    slot_duration_minutes: int = 10
    is_recurring: bool = False
    recurrence_pattern: Optional[Dict[str, Any]] = None


class AvailabilityBlockResponse(BaseModel):
    id: str
    volunteer_id: str
    start_time: datetime
    end_time: datetime
    timezone: str
    slot_duration_minutes: int
    is_recurring: bool
    recurrence_pattern: Optional[Dict[str, Any]]
    status: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class AppointmentSlotResponse(BaseModel):
    id: str
    availability_block_id: Optional[str]
    volunteer_id: str
    start_time: datetime
    end_time: datetime
    timezone: str
    status: str
    consultation_id: Optional[str]
    created_at: datetime
    
    class Config:
        from_attributes = True


class AppointmentSlotListResponse(BaseModel):
    slots: List[AppointmentSlotResponse]
    total: int
    page: int
    page_size: int


class BookAppointmentRequest(BaseModel):
    slot_id: str
    case_id: str
    patient_id: Optional[str] = None

