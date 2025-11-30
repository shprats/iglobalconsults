# Next Steps - Development Roadmap

## Current Status ✅

- [x] Project structure created
- [x] Database schemas designed (9 SQL files)
- [x] Flutter mobile app structure set up
- [x] FastAPI backend skeleton created
- [x] Development environment configured (VS Code, Flutter)
- [x] Git repository initialized and pushed to GitHub

## Recommended Next Steps (Priority Order)

### Phase 1: Foundation Setup (Week 1-2)

#### 1. Set Up Backend Database ⚡ **START HERE**
**Why:** The mobile app needs a backend to connect to.

**Tasks:**
- [ ] Install PostgreSQL locally or set up cloud database
- [ ] Run database schema files to create tables
- [ ] Set up database connection in FastAPI backend
- [ ] Test database connection

**Commands:**
```bash
# Install PostgreSQL (if not installed)
brew install postgresql@15
brew services start postgresql@15

# Create database
createdb globalhealth_connect

# Run schema files
cd database/schemas
psql -d globalhealth_connect -f 00_init.sql
psql -d globalhealth_connect -f 01_users.sql
# ... (run all schema files in order)
```

**Time:** 2-3 hours

---

#### 2. Implement Authentication (Backend + Mobile) 🔐
**Why:** Users need to log in before using the app.

**Backend Tasks:**
- [ ] Complete `UserRepository` implementation
- [ ] Implement JWT token generation/validation
- [ ] Create authentication endpoints (register, login, refresh)
- [ ] Add password hashing
- [ ] Test with Postman/curl

**Mobile Tasks:**
- [ ] Create authentication UI (login/signup screens)
- [ ] Implement API client for auth endpoints
- [ ] Add token storage (secure storage)
- [ ] Create auth state management (Riverpod)
- [ ] Test login flow

**Time:** 1-2 days

---

#### 3. Set Up Backend Environment & Run Server 🚀
**Why:** Need a running backend for mobile app to connect to.

**Tasks:**
- [ ] Create `.env` file with database credentials
- [ ] Install Python dependencies: `pip install -r requirements.txt`
- [ ] Set up Alembic for database migrations
- [ ] Run FastAPI server locally
- [ ] Test health endpoint
- [ ] Configure CORS for mobile app

**Commands:**
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your database URL
python -m app.main
```

**Time:** 1-2 hours

---

### Phase 2: Core Features (Week 2-4)

#### 4. Case Builder Feature (Mobile) 📝
**Why:** This is the core feature - requesting doctors create cases.

**Tasks:**
- [ ] Create case builder UI (forms for chief complaint, history, etc.)
- [ ] Implement offline storage (SQLite/Hive)
- [ ] Create case model and repository
- [ ] Add case creation API endpoint (backend)
- [ ] Implement offline queue for case sync
- [ ] Test case creation and sync

**Time:** 3-5 days

---

#### 5. File Upload System (TUS Protocol) 📸
**Why:** Doctors need to upload medical images.

**Backend Tasks:**
- [ ] Implement TUS protocol endpoints (POST, HEAD, PATCH)
- [ ] Set up AWS S3 integration
- [ ] Add file metadata storage
- [ ] Implement image quality checking

**Mobile Tasks:**
- [ ] Add image picker integration
- [ ] Implement TUS client for resumable uploads
- [ ] Add upload progress UI
- [ ] Handle offline upload queue

**Time:** 4-6 days

---

#### 6. Scheduling System 📅
**Why:** Volunteers need to set availability and book appointments.

**Backend Tasks:**
- [ ] Implement availability block creation
- [ ] Generate appointment slots from blocks
- [ ] Handle timezone conversions
- [ ] Create booking endpoints

**Mobile Tasks:**
- [ ] Create availability calendar UI
- [ ] Implement slot selection
- [ ] Add appointment booking flow
- [ ] Show upcoming appointments

**Time:** 3-4 days

---

### Phase 3: Advanced Features (Week 4-6)

#### 7. Video Consultations (Agora.io) 🎥
**Why:** Core feature - live video consultations.

**Tasks:**
- [ ] Set up Agora.io account
- [ ] Implement Agora token generation (backend)
- [ ] Add Agora SDK to Flutter app
- [ ] Create video call UI
- [ ] Handle connection quality monitoring
- [ ] Implement fallback modes (audio-only, text)

**Time:** 5-7 days

---

#### 8. Offline Sync System 🔄
**Why:** App must work in low-bandwidth environments.

**Tasks:**
- [ ] Implement offline queue (already in database schema)
- [ ] Create sync service
- [ ] Handle conflict resolution
- [ ] Add sync status UI
- [ ] Test offline scenarios

**Time:** 3-4 days

---

## Immediate Next Step: Set Up Database

**I recommend starting with Step 1: Set Up Backend Database**

This is the foundation - everything else depends on it.

### Quick Start Guide:

1. **Install PostgreSQL:**
   ```bash
   brew install postgresql@15
   brew services start postgresql@15
   ```

2. **Create database:**
   ```bash
   createdb globalhealth_connect
   ```

3. **Run schema files:**
   ```bash
   cd /Users/pratik/Documents/iglobalconsults/database/schemas
   for file in 00_init.sql 01_users.sql 02_cases.sql 03_files.sql 04_consultations.sql 05_scheduling.sql 06_audit_logs.sql 07_notifications.sql 08_offline_queue.sql; do
     psql -d globalhealth_connect -f $file
   done
   ```

4. **Verify:**
   ```bash
   psql -d globalhealth_connect -c "\dt"
   ```
   Should show all tables.

---

## Development Workflow

1. **Backend First:** Set up database → Implement API endpoints → Test with Postman
2. **Mobile Second:** Create UI → Connect to API → Test integration
3. **Iterate:** Build feature by feature, test thoroughly

---

## Questions to Consider

- **Do you want to use a cloud database** (AWS RDS, Google Cloud SQL) or local PostgreSQL?
- **Do you have AWS credentials** for S3 file storage?
- **Do you have Agora.io account** for video calls?
- **What's your priority:** Get a working prototype fast, or build it properly from the start?

---

## Need Help?

- Check `docs/TECHNICAL_SPECIFICATION.md` for detailed architecture
- Check `database/README.md` for database setup
- Check `backend/README.md` for backend setup
- Check `mobile/README.md` for mobile setup

Let me know which step you'd like to start with!

