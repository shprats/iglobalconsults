"""
Notification Repository
Database operations for notifications
"""

from sqlalchemy.orm import Session
from sqlalchemy import select, and_, desc, func
from typing import Optional, List, Tuple
from uuid import UUID
from datetime import datetime, timezone

from app.models.notification import Notification


class NotificationRepository:
    def __init__(self, db: Session):
        self.db = db
    
    def create(self, notification_data: dict) -> Notification:
        """Create a new notification"""
        notification = Notification(**notification_data)
        self.db.add(notification)
        self.db.commit()
        self.db.refresh(notification)
        return notification
    
    def get_by_id(self, notification_id: str) -> Optional[Notification]:
        """Get notification by ID"""
        try:
            uuid_id = UUID(notification_id)
        except ValueError:
            return None
        stmt = select(Notification).where(Notification.id == uuid_id)
        result = self.db.execute(stmt)
        return result.scalar_one_or_none()
    
    def list_notifications(
        self,
        user_id: str,
        is_read: Optional[bool] = None,
        page: int = 1,
        page_size: int = 20
    ) -> Tuple[List[Notification], int]:
        """List notifications for a user"""
        try:
            user_uuid = UUID(user_id)
        except ValueError:
            return [], 0
        
        stmt = select(Notification).where(Notification.user_id == user_uuid)
        
        if is_read is not None:
            if is_read:
                stmt = stmt.where(Notification.read_at.isnot(None))
            else:
                stmt = stmt.where(Notification.read_at.is_(None))
        
        # Get total count
        count_stmt = select(func.count()).select_from(
            stmt.subquery()
        )
        total = self.db.execute(count_stmt).scalar() or 0
        
        # Apply pagination and ordering
        stmt = stmt.order_by(desc(Notification.created_at))
        stmt = stmt.offset((page - 1) * page_size).limit(page_size)
        
        result = self.db.execute(stmt)
        notifications = result.scalars().all()
        
        return list(notifications), total
    
    def mark_as_read(self, notification: Notification) -> Notification:
        """Mark notification as read"""
        notification.is_read = True
        notification.read_at = datetime.now(timezone.utc)
        self.db.commit()
        self.db.refresh(notification)
        return notification
    
    def mark_all_as_read(self, user_id: str) -> int:
        """Mark all notifications as read for a user"""
        try:
            user_uuid = UUID(user_id)
        except ValueError:
            return 0
        
        stmt = select(Notification).where(
            and_(
                Notification.user_id == user_uuid,
                Notification.is_read == False
            )
        )
        result = self.db.execute(stmt)
        notifications = result.scalars().all()
        
        count = 0
        for notification in notifications:
            notification.is_read = True
            notification.read_at = datetime.now(timezone.utc)
            count += 1
        
        self.db.commit()
        return count
    
    def delete(self, notification: Notification) -> None:
        """Delete a notification"""
        self.db.delete(notification)
        self.db.commit()

