"""
Agora.io Service
Handles Agora video call token generation
"""

from typing import Optional
from app.core.config import settings
import logging
import hmac
import hashlib
import time
import base64
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)


class AgoraService:
    """Generate Agora.io tokens for video calls"""
    
    @staticmethod
    def generate_token(
        channel_name: str,
        user_id: str,
        role: str = "publisher",  # "publisher" or "subscriber"
        expiration: int = 3600  # 1 hour default
    ) -> Optional[str]:
        """
        Generate Agora RTC token
        Note: This is a simplified version. For production, use Agora's official SDK
        """
        if not settings.AGORA_APP_ID or not settings.AGORA_APP_CERTIFICATE:
            logger.warning("Agora credentials not configured")
            return None
        
        app_id = settings.AGORA_APP_ID
        app_certificate = settings.AGORA_APP_CERTIFICATE
        
        # Calculate expiration timestamp
        expire_time = int(time.time()) + expiration
        
        # Build token content
        token_content = {
            "app_id": app_id,
            "channel_name": channel_name,
            "uid": user_id,
            "role": role,
            "expire": expire_time
        }
        
        # For production, use Agora's official token generation
        # This is a placeholder - you should use agora-python-sdk
        try:
            # Simplified token generation (not production-ready)
            # In production, use: from agora_token_builder import RtcTokenBuilder
            token_string = f"{app_id}:{channel_name}:{user_id}:{expire_time}"
            signature = hmac.new(
                app_certificate.encode(),
                token_string.encode(),
                hashlib.sha256
            ).hexdigest()
            
            token = base64.b64encode(f"{token_string}:{signature}".encode()).decode()
            return token
        except Exception as e:
            logger.error(f"Error generating Agora token: {e}")
            return None
    
    @staticmethod
    def generate_channel_name(consultation_id: str) -> str:
        """Generate unique channel name for consultation"""
        return f"consultation_{consultation_id}"

