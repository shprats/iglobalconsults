# GlobalHealth Connect - Application Overview

## Table of Contents
1. [What Does This App Do?](#what-does-this-app-do)
2. [User Roles](#user-roles)
3. [Functions by Role](#functions-by-role)
4. [Technology Stack](#technology-stack)
5. [Development Tools](#development-tools)
6. [Major Technical Components](#major-technical-components)
7. [Why Is This App Needed?](#why-is-this-app-needed)
8. [Database and File Storage](#database-and-file-storage)
9. [Frontend Applications](#frontend-applications)

---

## What Does This App Do?

**GlobalHealth Connect** is a humanitarian telehealth platform that connects doctors in underserved areas with volunteer physicians around the world. The app enables remote medical consultations, case management, and medical image sharing to provide quality healthcare to patients who might not otherwise have access to specialized medical expertise.

### Key Capabilities:
- **Medical Case Management**: Doctors can create, manage, and track medical cases with patient information, symptoms, and medical history
- **Remote Consultations**: Real-time video consultations between requesting doctors and volunteer physicians
- **Medical Image Sharing**: Secure upload and sharing of medical images (X-rays, scans, photos) for diagnosis
- **Appointment Scheduling**: Volunteers can set their availability, and doctors can book consultation appointments
- **Push Notifications**: Real-time alerts for new cases, scheduled consultations, and important updates
- **Offline Support**: Works even with limited internet connectivity, syncing data when connection is restored

---

## User Roles

The app supports four distinct user roles, each with specific permissions and capabilities:

### 1. **Requesting Doctor**
- Doctors working in underserved or remote areas
- Need expert medical consultation for their patients
- Can create cases, upload medical images, and schedule consultations

### 2. **Requesting Patient**
- Patients who need medical consultation
- Can view their own cases and consultation history
- (Note: Currently focused on doctor-to-doctor consultations)

### 3. **Volunteer Physician**
- Licensed physicians volunteering their time and expertise
- Provide free medical consultations to help underserved communities
- Can view available cases, accept cases, set availability, and conduct video consultations

### 4. **Site Administrator**
- Platform administrators who manage the system
- Handle user management, system configuration, and platform oversight

---

## Functions by Role

### Requesting Doctor Functions

#### Case Management
- ✅ **Create Medical Cases**: Add new cases with patient information, chief complaint, urgency level, medical history, medications, allergies, and vital signs
- ✅ **View All Cases**: See a list of all cases they've created with filtering by status (pending, assigned, in progress, completed)
- ✅ **View Case Details**: Access complete case information including all uploaded files and consultation history
- ✅ **Edit Cases**: Update case information as needed
- ✅ **Delete Cases**: Remove cases that are no longer needed

#### File Management
- ✅ **Upload Medical Images**: Upload X-rays, scans, photos, and other medical images to cases
- ✅ **View Uploaded Files**: See all files associated with a case
- ✅ **Image Quality Analysis**: Automatic quality assessment of uploaded images

#### Consultation Management
- ✅ **Book Appointments**: Select available time slots from volunteer physicians and book consultations
- ✅ **View Consultations**: See all scheduled and completed consultations
- ✅ **Join Video Calls**: Participate in real-time video consultations with volunteer physicians
- ✅ **View Consultation Notes**: Access diagnosis and treatment recommendations from volunteers

#### Notifications
- ✅ **Receive Notifications**: Get alerts for case updates, consultation reminders, and new messages
- ✅ **View Notification History**: See all past notifications

---

### Volunteer Physician Functions

#### Availability Management
- ✅ **Set Availability**: Define time blocks when they're available for consultations
- ✅ **View Availability**: See all their scheduled availability blocks
- ✅ **Edit Availability**: Modify existing availability blocks
- ✅ **Delete Availability**: Remove availability blocks
- ✅ **Recurring Availability**: Set up repeating availability schedules

#### Case Management
- ✅ **View Available Cases**: Browse cases that need volunteer consultation
- ✅ **Accept Cases**: Accept cases they want to help with
- ✅ **Filter Cases**: Filter by urgency, specialty, or other criteria

#### Consultation Management
- ✅ **View Consultations**: See all consultations they're scheduled for
- ✅ **Start Consultations**: Begin video consultations at scheduled times
- ✅ **End Consultations**: Complete consultations and add notes
- ✅ **Add Consultation Notes**: Record diagnosis, treatment plan, and recommendations
- ✅ **Join Video Calls**: Participate in real-time video consultations

#### Notifications
- ✅ **Receive Notifications**: Get alerts for new cases, consultation reminders, and case updates
- ✅ **View Notification History**: See all past notifications

---

### Requesting Patient Functions

- ✅ **View Own Cases**: See cases created on their behalf
- ✅ **View Consultation History**: Access past consultations and recommendations
- (Note: Patient features are currently limited as the platform focuses on doctor-to-doctor consultations)

---

### Site Administrator Functions

- ✅ **User Management**: Manage all users on the platform
- ✅ **System Configuration**: Configure platform settings
- ✅ **Platform Oversight**: Monitor system health and usage
- (Note: Admin features are in development)

---

## Technology Stack

### Backend (Server-Side)

#### **Python FastAPI**
- Modern, high-performance web framework for building APIs
- Automatic API documentation
- Type validation and serialization
- Asynchronous request handling

#### **PostgreSQL Database**
- Relational database for storing all application data
- ACID compliance for data integrity
- Advanced indexing for performance
- Support for complex queries and relationships

#### **SQLAlchemy ORM**
- Object-Relational Mapping for database operations
- Type-safe database queries
- Automatic relationship management
- Database migration support

#### **JWT Authentication**
- Secure token-based authentication
- Access and refresh tokens
- Stateless authentication (no server-side sessions)

#### **AWS S3**
- Cloud storage for medical images and files
- Scalable and reliable file storage
- Transfer Acceleration for faster uploads
- Secure access control

#### **Agora.io**
- Real-time video calling infrastructure
- Low-bandwidth optimized for poor connections
- High-quality video and audio
- Cross-platform support

#### **Firebase Cloud Messaging (FCM)**
- Push notification service
- Reliable message delivery
- Background notification handling
- Cross-platform support

---

### Frontend (Client-Side)

#### **Flutter (Dart)**
- Cross-platform mobile app framework
- Single codebase for iOS and Android
- Native performance
- Rich UI components

#### **React/Next.js** (Web Dashboard - Planned)
- Web-based image viewer
- Server-side rendering
- Modern web UI framework

---

## Development Tools

### **Version Control**
- **Git**: Source code version control
- **GitHub**: Code repository and collaboration

### **IDE/Editors**
- **VS Code**: Primary development environment
- **Xcode**: iOS development and testing
- **Android Studio**: Android development and testing

### **Package Management**
- **pip**: Python package manager
- **pub**: Flutter/Dart package manager
- **CocoaPods**: iOS dependency manager

### **Database Tools**
- **psql**: PostgreSQL command-line client
- **pgAdmin**: PostgreSQL administration tool (optional)

### **API Testing**
- **curl**: Command-line API testing
- **FastAPI Docs**: Built-in API documentation and testing interface

### **Build Tools**
- **Flutter CLI**: Build and run Flutter apps
- **uvicorn**: ASGI server for FastAPI

---

## Major Technical Components

### 1. **Authentication System**
- **Purpose**: Secure user login and session management
- **Technology**: JWT tokens, bcrypt password hashing
- **Features**: 
  - User registration and login
  - Token refresh mechanism
  - Role-based access control
  - Secure password storage

### 2. **Case Management System**
- **Purpose**: Manage medical cases from creation to completion
- **Technology**: RESTful API, PostgreSQL
- **Features**:
  - CRUD operations for cases
  - Status tracking (pending → assigned → in progress → completed)
  - Case filtering and search
  - Patient information management

### 3. **File Upload System**
- **Purpose**: Secure upload and storage of medical images
- **Technology**: TUS Protocol (resumable uploads), AWS S3
- **Features**:
  - Resumable file uploads (handles poor connections)
  - Image quality analysis
  - Secure file access
  - Progress tracking

### 4. **Video Consultation System**
- **Purpose**: Real-time video consultations between doctors
- **Technology**: Agora.io SDK, WebRTC
- **Features**:
  - High-quality video calls
  - Low-bandwidth optimization
  - Screen sharing capability
  - Call recording (planned)

### 5. **Scheduling System**
- **Purpose**: Manage volunteer availability and appointments
- **Technology**: PostgreSQL, timezone-aware scheduling
- **Features**:
  - Availability block management
  - Appointment slot generation
  - Timezone handling
  - Recurring availability

### 6. **Notification System**
- **Purpose**: Real-time alerts and updates
- **Technology**: Firebase Cloud Messaging, in-app notifications
- **Features**:
  - Push notifications
  - In-app notification center
  - Notification preferences
  - Delivery tracking

### 7. **Offline Support System** (In Development)
- **Purpose**: Work without internet connection
- **Technology**: Local database (SQLite), sync queue
- **Features**:
  - Offline data storage
  - Action queue for offline operations
  - Automatic sync when online
  - Conflict resolution

### 8. **API Layer**
- **Purpose**: Communication between frontend and backend
- **Technology**: RESTful API, FastAPI
- **Features**:
  - Standardized endpoints
  - Request validation
  - Error handling
  - API versioning

---

## Why Is This App Needed?

### The Problem

Millions of people around the world live in areas with limited access to quality healthcare:
- **Rural and Remote Areas**: Many communities lack access to specialized medical expertise
- **Resource Constraints**: Local clinics may not have the equipment or expertise for complex cases
- **Geographic Barriers**: Patients cannot easily travel to see specialists
- **Cost Barriers**: Specialized consultations can be expensive and unaffordable

### The Solution

GlobalHealth Connect bridges this gap by:
- **Connecting Communities**: Links doctors in underserved areas with volunteer specialists worldwide
- **Free Consultations**: Volunteer physicians provide their expertise at no cost
- **Real-Time Communication**: Video consultations enable face-to-face interaction despite distance
- **Medical Image Sharing**: Allows specialists to review X-rays, scans, and photos remotely
- **24/7 Availability**: Volunteers can set their own schedules, increasing accessibility

### Impact

- **Improved Patient Outcomes**: Access to expert medical opinions leads to better diagnoses and treatments
- **Knowledge Transfer**: Local doctors learn from specialists, building local capacity
- **Cost Savings**: Reduces need for expensive travel and specialized equipment
- **Scalability**: Can serve unlimited patients without geographic constraints

---

## Database and File Storage

### Database: PostgreSQL

**What is stored in the database:**
- **User Accounts**: Email, password (hashed), role, profile information
- **Medical Cases**: Case details, patient information, status, timestamps
- **Consultations**: Scheduled consultations, video call information, notes
- **Availability Blocks**: Volunteer availability schedules
- **Appointments**: Booked appointment slots
- **Notifications**: In-app notifications and delivery status
- **File Metadata**: Information about uploaded files (name, size, location, upload status)
- **Audit Logs**: System activity and access logs

**Database Features:**
- **Relational Structure**: Tables are connected (e.g., cases belong to users, files belong to cases)
- **Data Integrity**: Foreign keys ensure data consistency
- **Indexing**: Fast searches and queries
- **Timezone Support**: Handles different timezones for global users
- **UUID Primary Keys**: Secure, unique identifiers for all records

### File Storage: AWS S3

**What is stored in S3:**
- **Medical Images**: X-rays, CT scans, MRI images, photos of conditions
- **Medical Documents**: PDFs, reports, lab results
- **Consultation Recordings**: Video call recordings (planned)

**Storage Features:**
- **Scalability**: Can store unlimited files
- **Security**: Encrypted storage with access control
- **Reliability**: 99.99% uptime guarantee
- **Transfer Acceleration**: Faster uploads from anywhere in the world
- **Cost-Effective**: Pay only for storage used

**File Upload Process:**
1. User selects file in mobile app
2. File is uploaded using TUS Protocol (resumable)
3. Upload progress is tracked
4. File is stored in S3 with unique identifier
5. File metadata is saved in database
6. Image quality is analyzed (for images)

---

## Frontend Applications

### Mobile App (Flutter)

**Platforms**: iOS and Android

**Key Features:**
- **Native Performance**: Fast and responsive
- **Offline Support**: Works without internet (syncs when online)
- **Push Notifications**: Real-time alerts
- **Video Calls**: Integrated video consultation
- **File Upload**: Camera and gallery integration
- **Responsive Design**: Works on phones and tablets

**Screens:**
- Login/Registration
- Home Dashboard (role-specific)
- Case List and Details
- Create/Edit Case
- File Upload
- Availability Management
- Consultation List and Details
- Video Call Screen
- Notifications Center
- Settings

**State Management:**
- **Riverpod**: Manages app state and data
- **Local Storage**: SQLite for offline data
- **Shared Preferences**: User settings and tokens

### Web Dashboard (React/Next.js) - Planned

**Purpose**: Image viewer and administrative tools

**Features:**
- High-resolution image viewing
- Zoom and pan capabilities
- Administrative dashboard
- Analytics and reporting

---

## Technical Architecture Summary

```
┌─────────────────────────────────────────────────────────┐
│                    Mobile App (Flutter)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │   iOS App    │  │ Android App  │  │  Web App     │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
└──────────────────────┬──────────────────────────────────┘
                       │
                       │ REST API / WebSocket
                       │
┌──────────────────────▼──────────────────────────────────┐
│              Backend API (FastAPI)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Auth Service │  │ Case Service │  │ File Service │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │Consultation  │  │ Scheduling   │  │ Notification │  │
│  │   Service    │  │   Service    │  │   Service    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└──────────┬──────────────────┬──────────────────┬────────┘
           │                  │                  │
    ┌──────▼──────┐    ┌──────▼──────┐    ┌──────▼──────┐
    │ PostgreSQL  │    │   AWS S3    │    │   Agora.io  │
    │  Database   │    │ File Storage │    │ Video Calls │
    └─────────────┘    └──────────────┘    └─────────────┘
           │
    ┌──────▼──────┐
    │  Firebase   │
    │   FCM Push  │
    │Notifications│
    └─────────────┘
```

---

## Summary

**GlobalHealth Connect** is a comprehensive telehealth platform that enables doctors in underserved areas to connect with volunteer specialists worldwide. Built with modern technologies (Flutter, FastAPI, PostgreSQL, AWS S3), the app provides secure, scalable, and user-friendly tools for case management, video consultations, medical image sharing, and appointment scheduling. The platform serves a critical humanitarian need by breaking down geographic and economic barriers to quality healthcare.

---

*Last Updated: [Current Date]*
*Version: 1.0*

