# Testing Guide - See All Screens

## Quick Start

### 1. Start Backend Server
```bash
cd backend
source venv/bin/activate
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Keep this terminal open. The server should show:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### 2. Run Flutter App

**Option A: Using VS Code**
1. Open the `mobile` folder in VS Code
2. Press `F5` or click "Run and Debug"
3. Select your device (iOS Simulator, Android Emulator, or physical device)

**Option B: Using Terminal**
```bash
cd mobile
flutter run
```

**Option C: Using Android Studio**
1. Open Android Studio
2. Open the `mobile` folder
3. Click the green "Run" button

## Screen Tour

### 1. Login Screen
**What you'll see:**
- Email and password fields
- "Sign In" button
- "Don't have an account? Register" link

**To test:**
- If you have an account: Enter email and password, tap "Sign In"
- If you don't: Tap "Register" to create one

---

### 2. Register Screen
**What you'll see:**
- First Name (optional)
- Last Name (optional)
- Email field
- Role dropdown (Requesting Doctor / Volunteer Physician)
- Password field
- Confirm Password field
- "Register" button

**To test:**
- Fill in all required fields
- Select a role
- Tap "Register"
- You'll be automatically logged in

---

### 3. Home Screen
**What you'll see:**
- Welcome message with your name
- Your role displayed
- "View Cases" button
- Logout icon in top right

**To test:**
- Tap "View Cases" to go to cases list
- Tap logout icon to sign out

---

### 4. Cases List Screen
**What you'll see:**
- List of all your medical cases
- Each case shows:
  - Title
  - Chief Complaint
  - Urgency badge (Emergency/Urgent/Routine)
  - Status badge (Pending/Assigned/In Progress/Completed)
  - Creation date
- Filter icon in top right
- "+" floating button to create new case

**To test:**
- **Pull down** to refresh the list
- **Tap filter icon** to filter by status
- **Tap a case** to view details
- **Tap "+" button** to create a new case
- **Scroll down** to load more cases (infinite scroll)

---

### 5. Create Case Screen
**What you'll see:**
- Case Title field (required)
- Chief Complaint field (required)
- Urgency dropdown (required)
- Description field (optional)
- Patient History field (optional)
- Current Medications field (optional)
- Allergies field (optional)
- Vital Signs field (optional)
- "Create Case" button

**To test:**
- Fill in required fields (Title, Chief Complaint, Urgency)
- Optionally fill in other fields
- Tap "Create Case"
- You'll be taken back to the cases list
- Your new case will appear at the top

---

### 6. Case Detail Screen
**What you'll see:**
- Case title at the top
- Urgency and Status badges
- Chief Complaint section
- Description section (if provided)
- Patient History section (if provided)
- Current Medications section (if provided)
- Allergies section (if provided)
- Vital Signs section (if provided)
- Case Information card with:
  - Created date
  - Updated date
  - Assigned volunteer (if assigned)
- Delete icon in top right

**To test:**
- Scroll to see all sections
- Tap delete icon to delete the case (with confirmation)
- Tap back arrow to return to cases list

## Complete User Flow

### Flow 1: New User Registration
1. **Login Screen** → Tap "Register"
2. **Register Screen** → Fill form, tap "Register"
3. **Home Screen** → See welcome message
4. **Cases List** → Tap "View Cases" (empty list)
5. **Create Case** → Tap "+", fill form, create
6. **Cases List** → See your new case
7. **Case Detail** → Tap case to see details

### Flow 2: Existing User
1. **Login Screen** → Enter credentials, tap "Sign In"
2. **Home Screen** → See welcome
3. **Cases List** → See all your cases
4. **Filter Cases** → Tap filter, select status
5. **View Details** → Tap any case
6. **Create More** → Tap "+" to add cases

## Troubleshooting

### App won't connect to backend
- Make sure backend is running on port 8000
- Check `lib/core/config/app_config.dart` - base URL should be `http://localhost:8000`
- For Android Emulator, change to `http://10.0.2.2:8000`
- For iOS Simulator, `localhost` works fine

### Login fails
- Make sure you've registered first
- Check backend terminal for errors
- Verify email/password are correct

### Cases not showing
- Make sure you're logged in as a "requesting_doctor"
- Check backend is running
- Pull down to refresh

### Build errors
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

## Expected Behavior

✅ **Login** → Takes you to Home
✅ **Register** → Creates account, auto-login, goes to Home
✅ **Home** → Shows your name and role
✅ **Cases List** → Shows all your cases with badges
✅ **Create Case** → Creates case, returns to list
✅ **Case Detail** → Shows full case information
✅ **Filter** → Filters cases by status
✅ **Pull to Refresh** → Reloads cases
✅ **Infinite Scroll** → Loads more cases automatically
✅ **Delete** → Removes case with confirmation

## Visual Features to Notice

- **Color-coded badges**: 
  - Red = Emergency
  - Orange = Urgent
  - Green = Routine
- **Status colors**:
  - Orange = Pending
  - Blue = Assigned
  - Purple = In Progress
  - Green = Completed
- **Smooth animations**: Pull to refresh, loading states
- **Empty states**: Helpful messages when no data
- **Error handling**: Clear error messages

---

**Enjoy exploring all the screens!** 🎉

