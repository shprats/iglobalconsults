#!/usr/bin/env python3
"""
Test Authentication Endpoints
"""

import requests
import json

BASE_URL = "http://localhost:8000/api/v1/auth"

def test_register():
    """Test user registration"""
    print("📝 Testing user registration...")
    
    user_data = {
        "email": "test@example.com",
        "password": "testpassword123",
        "role": "requesting_doctor",
        "first_name": "Test",
        "last_name": "User",
        "timezone": "UTC"
    }
    
    response = requests.post(f"{BASE_URL}/register", json=user_data)
    print(f"   Status: {response.status_code}")
    
    if response.status_code == 201:
        data = response.json()
        print(f"   ✅ User created: {data['email']} (ID: {data['id']})")
        return data
    else:
        print(f"   ❌ Error: {response.text}")
        return None

def test_login(email: str, password: str):
    """Test user login"""
    print("\n🔐 Testing user login...")
    
    data = {
        "username": email,  # OAuth2 uses 'username' field
        "password": password
    }
    
    response = requests.post(f"{BASE_URL}/login", data=data)
    print(f"   Status: {response.status_code}")
    
    if response.status_code == 200:
        token_data = response.json()
        print(f"   ✅ Login successful!")
        print(f"   Access token: {token_data['access_token'][:50]}...")
        return token_data
    else:
        print(f"   ❌ Error: {response.text}")
        return None

def test_get_me(access_token: str):
    """Test getting current user"""
    print("\n👤 Testing get current user...")
    
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(f"{BASE_URL}/me", headers=headers)
    print(f"   Status: {response.status_code}")
    
    if response.status_code == 200:
        user_data = response.json()
        print(f"   ✅ User data retrieved: {user_data['email']}")
        return user_data
    else:
        print(f"   ❌ Error: {response.text}")
        return None

def main():
    print("=" * 60)
    print("Authentication API Test")
    print("=" * 60)
    print()
    
    # Test registration
    user = test_register()
    if not user:
        print("\n⚠️  Registration failed. User may already exist.")
        print("   Trying login with existing user...")
        email = "test@example.com"
        password = "testpassword123"
    else:
        email = user["email"]
        password = "testpassword123"
    
    # Test login
    token_data = test_login(email, password)
    if not token_data:
        print("\n❌ Login failed. Cannot continue tests.")
        return
    
    # Test get current user
    test_get_me(token_data["access_token"])
    
    print("\n" + "=" * 60)
    print("✅ Authentication tests complete!")
    print("=" * 60)

if __name__ == "__main__":
    try:
        main()
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to server. Make sure it's running:")
        print("   cd backend && source venv/bin/activate && python -m app.main")
    except Exception as e:
        print(f"❌ Error: {e}")

