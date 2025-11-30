#!/usr/bin/env python3
"""
Test Database Connection from FastAPI Backend
Tests that the backend can connect to the database using SQLAlchemy
"""

import sys
import os

# Add app to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'app'))

from app.core.database import engine, SessionLocal
from app.core.config import settings
from sqlalchemy import text

def test_connection():
    """Test database connection"""
    print("🔌 Testing database connection from FastAPI backend...")
    print(f"   Database URL: {settings.DATABASE_URL.split('@')[1] if '@' in settings.DATABASE_URL else 'hidden'}")
    print()
    
    try:
        # Test connection using engine
        with engine.connect() as conn:
            result = conn.execute(text("SELECT version();"))
            version = result.fetchone()[0]
            print(f"✅ Connection successful!")
            print(f"   PostgreSQL version: {version.split(',')[0]}")
            print()
            
            # Test table count
            result = conn.execute(text("""
                SELECT COUNT(*) 
                FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_type = 'BASE TABLE';
            """))
            table_count = result.fetchone()[0]
            print(f"✅ Found {table_count} tables in database")
            print()
            
            # Test users table
            result = conn.execute(text("""
                SELECT COUNT(*) 
                FROM information_schema.columns 
                WHERE table_name = 'users';
            """))
            column_count = result.fetchone()[0]
            print(f"✅ Users table has {column_count} columns")
            print()
            
            # Test SessionLocal
            db = SessionLocal()
            try:
                result = db.execute(text("SELECT 1 as test;"))
                test_value = result.fetchone()[0]
                if test_value == 1:
                    print("✅ SessionLocal working correctly")
                else:
                    print("❌ SessionLocal test failed")
            finally:
                db.close()
            
            print()
            print("=" * 60)
            print("✅ All backend database tests passed!")
            print("=" * 60)
            print()
            print("💡 Your backend is ready to connect to the database.")
            print("   You can now start implementing API endpoints!")
            print()
            
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        print()
        print("Troubleshooting:")
        print("1. Make sure PostgreSQL is running: brew services start postgresql@15")
        print("2. Check DATABASE_URL in backend/.env")
        print("3. Verify database exists: psql -d globalhealth_connect")
        sys.exit(1)

if __name__ == "__main__":
    test_connection()

