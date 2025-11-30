#!/usr/bin/env python3
"""
Test Database Connection Script
Tests the PostgreSQL database connection for GlobalHealth Connect
"""

import sys
import os

# Add backend to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'backend'))

try:
    import psycopg2
    from psycopg2 import sql
except ImportError:
    print("❌ psycopg2 not installed. Install it with:")
    print("   pip install psycopg2-binary")
    sys.exit(1)

# Database connection string
DATABASE_URL = "postgresql://pratik@localhost:5432/globalhealth_connect"

def test_connection():
    """Test basic database connection"""
    print("🔌 Testing database connection...")
    try:
        conn = psycopg2.connect(DATABASE_URL)
        print("✅ Connection successful!")
        return conn
    except psycopg2.OperationalError as e:
        print(f"❌ Connection failed: {e}")
        return None

def test_tables(conn):
    """Test that all tables exist"""
    print("\n📊 Checking tables...")
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_type = 'BASE TABLE'
            ORDER BY table_name;
        """)
        tables = cur.fetchall()
        print(f"✅ Found {len(tables)} tables:")
        for table in tables:
            print(f"   - {table[0]}")
        cur.close()
        return len(tables)
    except Exception as e:
        print(f"❌ Error checking tables: {e}")
        return 0

def test_extensions(conn):
    """Test that required extensions are installed"""
    print("\n🔧 Checking extensions...")
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT extname, extversion 
            FROM pg_extension 
            ORDER BY extname;
        """)
        extensions = cur.fetchall()
        print(f"✅ Found {len(extensions)} extensions:")
        for ext in extensions:
            print(f"   - {ext[0]} (v{ext[1]})")
        cur.close()
        return extensions
    except Exception as e:
        print(f"❌ Error checking extensions: {e}")
        return []

def test_insert_select(conn):
    """Test INSERT and SELECT operations"""
    print("\n✍️  Testing INSERT and SELECT...")
    try:
        cur = conn.cursor()
        
        # Insert test user
        cur.execute("""
            INSERT INTO users (email, password_hash, role, first_name, last_name)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id, email, role;
        """, ('test_connection@example.com', 'test_hash', 'requesting_doctor', 'Test', 'Connection'))
        
        result = cur.fetchone()
        user_id = result[0]
        print(f"✅ Insert successful: User ID {user_id}, Email: {result[1]}")
        
        # Select the user
        cur.execute("""
            SELECT id, email, role, created_at 
            FROM users 
            WHERE id = %s;
        """, (user_id,))
        
        user = cur.fetchone()
        print(f"✅ Select successful: {user[1]} ({user[2]}) created at {user[3]}")
        
        # Clean up
        cur.execute("DELETE FROM users WHERE id = %s;", (user_id,))
        conn.commit()
        print("✅ Cleanup successful: Test user deleted")
        
        cur.close()
        return True
    except Exception as e:
        print(f"❌ Error in INSERT/SELECT test: {e}")
        conn.rollback()
        return False

def test_foreign_keys(conn):
    """Test that foreign key relationships work"""
    print("\n🔗 Testing foreign key relationships...")
    try:
        cur = conn.cursor()
        
        # Test that we can't insert invalid foreign key
        try:
            cur.execute("""
                INSERT INTO cases (requesting_doctor_id, title, urgency)
                VALUES (%s, %s, %s);
            """, ('00000000-0000-0000-0000-000000000000', 'Test Case', 'routine'))
            print("❌ Foreign key constraint not working (this is bad)")
            conn.rollback()
            return False
        except psycopg2.IntegrityError:
            print("✅ Foreign key constraint working correctly")
            conn.rollback()
            return True
    except Exception as e:
        print(f"❌ Error testing foreign keys: {e}")
        return False

def main():
    print("=" * 60)
    print("GlobalHealth Connect - Database Connection Test")
    print("=" * 60)
    print()
    
    # Test connection
    conn = test_connection()
    if not conn:
        sys.exit(1)
    
    try:
        # Test tables
        table_count = test_tables(conn)
        if table_count < 17:
            print(f"⚠️  Warning: Expected 17 tables, found {table_count}")
        
        # Test extensions
        extensions = test_extensions(conn)
        required_exts = ['uuid-ossp', 'pgcrypto', 'pg_trgm']
        ext_names = [e[0] for e in extensions]
        for req_ext in required_exts:
            if req_ext not in ext_names:
                print(f"⚠️  Warning: Required extension '{req_ext}' not found")
        
        # Test INSERT/SELECT
        if not test_insert_select(conn):
            sys.exit(1)
        
        # Test foreign keys
        if not test_foreign_keys(conn):
            sys.exit(1)
        
        print("\n" + "=" * 60)
        print("✅ All tests passed! Database is ready for development.")
        print("=" * 60)
        print("\n💡 Connection string for backend/.env:")
        print(f"   DATABASE_URL={DATABASE_URL}")
        print()
        
    finally:
        conn.close()

if __name__ == "__main__":
    main()

