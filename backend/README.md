# GlobalHealth Connect - Backend API

Python FastAPI backend for GlobalHealth Connect platform.

## Setup Instructions

### Prerequisites

1. **Python 3.11+**
2. **PostgreSQL** (running locally or remote)
3. **Redis** (for caching and sessions)

### Installation

1. **Create virtual environment:**
   ```bash
   cd backend
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Set up database:**
   ```bash
   # Create database
   createdb globalhealth_connect
   
   # Run migrations (once Alembic is set up)
   alembic upgrade head
   ```

5. **Run the server:**
   ```bash
   python -m app.main
   # Or
   uvicorn app.main:app --reload
   ```

## Project Structure

```
app/
├── main.py              # Application entry point
├── core/
│   ├── config.py        # Configuration
│   ├── database.py      # Database setup
│   └── security.py      # Security utilities
├── api/
│   └── v1/              # API v1 endpoints
├── models/              # SQLAlchemy models
├── schemas/             # Pydantic schemas
├── services/            # Business logic
└── repositories/        # Data access layer
```

## API Documentation

Once the server is running:
- Swagger UI: http://localhost:8000/api/docs
- ReDoc: http://localhost:8000/api/redoc

## Development

See [Technical Specification](../docs/TECHNICAL_SPECIFICATION.md) for detailed architecture.

