"""
User Profile Model
SQLAlchemy model for user_profiles table
"""

from sqlalchemy import Column, String, Integer, Text, ARRAY, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.core.database import Base
import uuid


class UserProfile(Base):
    __tablename__ = "user_profiles"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), unique=True, nullable=False, index=True)
    bio = Column(Text)
    specialization = Column(String(255))
    languages_spoken = Column(ARRAY(String))
    profile_image_url = Column(Text)
    organization_name = Column(String(255))
    organization_address = Column(Text)
    years_of_experience = Column(Integer)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

