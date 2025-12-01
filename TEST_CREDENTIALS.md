# Test Credentials

## Quick Test Account

You can either **register a new account** in the app, or use these test credentials if they exist:

### Option 1: Register New Account (Recommended)
1. Open the app
2. Tap "Don't have an account? Register"
3. Fill in:
   - **Email**: `doctor@test.com` (or any email)
   - **Password**: `test123456` (min 6 characters)
   - **Role**: Select "Requesting Doctor" or "Volunteer Physician"
   - **First Name**: (optional)
   - **Last Name**: (optional)
4. Tap "Register"
5. You'll be automatically logged in

### Option 2: Use Existing Test Account
If a test account exists, try:

**Email**: `test@example.com`  
**Password**: `testpass123`

**OR**

**Email**: `doctor@test.com`  
**Password**: `test123456`

## Creating Test Users via API

If you want to create test users via API (for testing):

```bash
# Create a requesting doctor
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "doctor@test.com",
    "password": "test123456",
    "role": "requesting_doctor",
    "first_name": "Test",
    "last_name": "Doctor"
  }'

# Create a volunteer physician
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "volunteer@test.com",
    "password": "test123456",
    "role": "volunteer_physician",
    "first_name": "Test",
    "last_name": "Volunteer"
  }'
```

## Testing Flow

1. **Register** → Create your account
2. **Login** → Use your credentials
3. **Home** → See welcome screen
4. **Cases** → Tap "View Cases"
5. **Create Case** → Tap "+" button
6. **View Details** → Tap any case

## Notes

- Password must be at least 6 characters
- Email must be valid format
- Role determines what features you can access:
  - **Requesting Doctor**: Can create cases, view cases, book consultations
  - **Volunteer Physician**: Can view available cases, schedule consultations

---

**Easiest**: Just register a new account in the app! It takes 30 seconds.

