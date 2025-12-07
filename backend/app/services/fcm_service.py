"""
Firebase Cloud Messaging Service
Sends push notifications via FCM
"""

import os
from typing import Optional, Dict, Any, List
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

try:
    import firebase_admin
    from firebase_admin import credentials, messaging
    FIREBASE_AVAILABLE = True
except ImportError:
    FIREBASE_AVAILABLE = False
    logger.warning("Firebase Admin SDK not installed. Push notifications disabled.")


class FCMService:
    """Service for sending FCM push notifications"""
    
    _initialized = False
    
    @classmethod
    def initialize(cls) -> bool:
        """Initialize Firebase Admin SDK"""
        if not FIREBASE_AVAILABLE:
            logger.error("Firebase Admin SDK not available")
            return False
        
        if cls._initialized:
            return True
        
        try:
            # Option 1: Use service account file (recommended)
            if settings.FIREBASE_CREDENTIALS_PATH and os.path.exists(settings.FIREBASE_CREDENTIALS_PATH):
                cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
                firebase_admin.initialize_app(cred)
                logger.info(f"Firebase initialized with service account: {settings.FIREBASE_CREDENTIALS_PATH}")
            # Option 2: Use default credentials (for Cloud Run, GCP, etc.)
            elif settings.FIREBASE_PROJECT_ID:
                firebase_admin.initialize_app()
                logger.info(f"Firebase initialized with default credentials for project: {settings.FIREBASE_PROJECT_ID}")
            else:
                logger.warning("Firebase credentials not configured. Push notifications will not work.")
                return False
            
            cls._initialized = True
            return True
        except Exception as e:
            logger.error(f"Failed to initialize Firebase: {e}")
            return False
    
    @classmethod
    def send_notification(
        cls,
        device_token: str,
        title: str,
        body: str,
        data: Optional[Dict[str, Any]] = None
    ) -> bool:
        """
        Send a push notification to a single device
        
        Args:
            device_token: FCM device token
            title: Notification title
            body: Notification body
            data: Optional data payload (dict of string keys/values)
        
        Returns:
            True if sent successfully, False otherwise
        """
        if not cls._initialized:
            if not cls.initialize():
                return False
        
        try:
            # Convert data values to strings (FCM requirement)
            fcm_data = {}
            if data:
                for key, value in data.items():
                    fcm_data[str(key)] = str(value)
            
            message = messaging.Message(
                token=device_token,
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=fcm_data,
            )
            
            response = messaging.send(message)
            logger.info(f"Successfully sent FCM message: {response}")
            return True
        except messaging.UnregisteredError:
            logger.warning(f"Device token is unregistered: {device_token[:20]}...")
            return False
        except Exception as e:
            logger.error(f"Error sending FCM notification: {e}")
            return False
    
    @classmethod
    def send_multicast(
        cls,
        device_tokens: List[str],
        title: str,
        body: str,
        data: Optional[Dict[str, Any]] = None
    ) -> Dict[str, int]:
        """
        Send notification to multiple devices
        
        Args:
            device_tokens: List of FCM device tokens
            title: Notification title
            body: Notification body
            data: Optional data payload
        
        Returns:
            Dict with 'success' and 'failure' counts
        """
        if not device_tokens:
            return {"success": 0, "failure": 0}
        
        if not cls._initialized:
            if not cls.initialize():
                return {"success": 0, "failure": len(device_tokens)}
        
        try:
            # Convert data values to strings (FCM requirement)
            fcm_data = {}
            if data:
                for key, value in data.items():
                    fcm_data[str(key)] = str(value)
            
            message = messaging.MulticastMessage(
                tokens=device_tokens,
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=fcm_data,
            )
            
            response = messaging.send_multicast(message)
            logger.info(f"Sent multicast: {response.success_count} success, {response.failure_count} failure")
            
            return {
                "success": response.success_count,
                "failure": response.failure_count,
            }
        except Exception as e:
            logger.error(f"Error sending multicast FCM notification: {e}")
            return {"success": 0, "failure": len(device_tokens)}
    
    @classmethod
    def send_to_topic(
        cls,
        topic: str,
        title: str,
        body: str,
        data: Optional[Dict[str, Any]] = None
    ) -> bool:
        """
        Send notification to a topic (e.g., all volunteers, all doctors)
        
        Args:
            topic: FCM topic name
            title: Notification title
            body: Notification body
            data: Optional data payload
        
        Returns:
            True if sent successfully, False otherwise
        """
        if not cls._initialized:
            if not cls.initialize():
                return False
        
        try:
            # Convert data values to strings (FCM requirement)
            fcm_data = {}
            if data:
                for key, value in data.items():
                    fcm_data[str(key)] = str(value)
            
            message = messaging.Message(
                topic=topic,
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=fcm_data,
            )
            
            response = messaging.send(message)
            logger.info(f"Successfully sent FCM message to topic '{topic}': {response}")
            return True
        except Exception as e:
            logger.error(f"Error sending FCM notification to topic: {e}")
            return False

