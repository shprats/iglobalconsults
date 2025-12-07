"""
Notifications API Endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime, timezone

from app.core.database import get_db
from app.api.v1.auth import get_current_user
from app.schemas.auth import UserResponse
from app.repositories.notification_repository import NotificationRepository

router = APIRouter()


@router.post("/register-device")
async def register_device_token(
    device_token: str,
    platform: str,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Register device token for push notifications"""
    # TODO: Store device token in database
    # For now, just acknowledge the registration
    return {"message": "Device token registered", "device_token": device_token[:20] + "..."}


@router.get("/")
async def list_notifications(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    is_read: Optional[bool] = Query(None),
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """List notifications for current user"""
    repo = NotificationRepository(db)
    notifications, total = repo.list_notifications(
        user_id=current_user.id,
        is_read=is_read,
        page=page,
        page_size=page_size
    )
    
    return {
        "notifications": [
            {
                "id": str(n.id),
                "user_id": str(n.user_id),
                "message": n.message,
                "type": n.type,
                "is_read": n.is_read,
                "created_at": n.created_at.isoformat(),
            }
            for n in notifications
        ],
        "total": total,
        "page": page,
        "page_size": page_size,
    }


@router.put("/{notification_id}/read")
async def mark_notification_as_read(
    notification_id: str,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark a notification as read"""
    repo = NotificationRepository(db)
    notification = repo.get_by_id(notification_id)
    
    if not notification or str(notification.user_id) != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )
    
    repo.mark_as_read(notification)
    return {"message": "Notification marked as read"}


@router.post("/mark-all-read")
async def mark_all_as_read(
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark all notifications as read for current user"""
    repo = NotificationRepository(db)
    repo.mark_all_as_read(user_id=current_user.id)
    return {"message": "All notifications marked as read"}


@router.delete("/{notification_id}")
async def delete_notification(
    notification_id: str,
    current_user: UserResponse = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a notification"""
    repo = NotificationRepository(db)
    notification = repo.get_by_id(notification_id)
    
    if not notification or str(notification.user_id) != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )
    
    repo.delete(notification)
    return Response(status_code=status.HTTP_204_NO_CONTENT)

