# GlobalHealth Connect - Mobile App

Flutter mobile application for Requesting Doctors and Patients.

## Setup Instructions

### Prerequisites

1. **Install Flutter:**
   - Download from https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH
   - Verify: `flutter doctor`

2. **Install Dependencies:**
   ```bash
   cd mobile
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── config/
│   ├── constants/
│   ├── errors/
│   └── utils/
├── features/
│   ├── auth/
│   ├── case_builder/
│   ├── scheduling/
│   ├── consultation/
│   └── history/
├── shared/
│   ├── widgets/
│   ├── services/
│   └── models/
└── offline/
    ├── queue/
    └── sync/
```

## Features

- Offline-first case creation
- TUS protocol for resumable file uploads
- Image quality checking
- Video consultations (Agora.io)
- Offline queue synchronization
- Push notifications

## Development

See [Technical Specification](../docs/TECHNICAL_SPECIFICATION.md) for detailed architecture.

