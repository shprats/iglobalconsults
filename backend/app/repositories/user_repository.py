"""
User Repository
Database operations for users
"""

from sqlalchemy.orm import Session
from typing import Optional
from sqlalchemy import select
from app.models.user import User
import uuid


class UserRepository:
    def __init__(self, db: Session):
        self.db = db
    
    def get_by_email(self, email: str) -> Optional[User]:
        """Get user by email"""
        stmt = select(User).where(User.email == email)
        result = self.db.execute(stmt)
        return result.scalar_one_or_none()
    
    def get_by_id(self, user_id: str) -> Optional[User]:
        """Get user by ID"""
        try:
            user_uuid = uuid.UUID(user_id)
        except ValueError:
            return None
        stmt = select(User).where(User.id == user_uuid)
        result = self.db.execute(stmt)
        return result.scalar_one_or_none()
    
    def create(self, user_data: dict) -> User:
        """Create new user"""
        user = User(**user_data)
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user
    
    def update_last_login(self, user: User):
        """Update user's last login timestamp"""
        from datetime import datetime, timezone
        user.last_login_at = datetime.now(timezone.utc)
        self.db.commit()
        self.db.refresh(user)

