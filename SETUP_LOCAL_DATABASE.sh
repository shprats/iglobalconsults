#!/bin/bash

# GlobalHealth Connect - Local Database Setup Script
# This script sets up PostgreSQL locally for development

set -e  # Exit on error

echo "🚀 Setting up GlobalHealth Connect Database..."
echo ""

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL not found. Installing..."
    echo ""
    echo "Installing PostgreSQL via Homebrew (ARM64)..."
    
    # Detect architecture and use appropriate brew command
    if [[ $(uname -m) == "arm64" ]]; then
        # Apple Silicon - use native ARM
        arch -arm64 brew install postgresql@15
        BREW_CMD="arch -arm64 brew"
    else
        # Intel Mac
        brew install postgresql@15
        BREW_CMD="brew"
    fi
    
    echo ""
    echo "✅ PostgreSQL installed!"
    echo ""
    echo "Starting PostgreSQL service..."
    $BREW_CMD services start postgresql@15
    
    # Wait a moment for service to start
    sleep 3
else
    echo "✅ PostgreSQL is already installed"
    echo ""
    
    # Check if service is running
    if ! pg_isready -q; then
        echo "Starting PostgreSQL service..."
        brew services start postgresql@15
        sleep 3
    else
        echo "✅ PostgreSQL service is running"
    fi
fi

echo ""
echo "📦 Creating database 'globalhealth_connect'..."

# Create database (ignore error if it already exists)
psql -d postgres -c "CREATE DATABASE globalhealth_connect;" 2>/dev/null || echo "Database already exists (that's okay)"

echo "✅ Database created"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCHEMAS_DIR="$SCRIPT_DIR/database/schemas"

echo "📄 Running schema files..."
echo ""

# Run schema files in order
SCHEMA_FILES=(
    "00_init.sql"
    "01_users.sql"
    "02_cases.sql"
    "03_files.sql"
    "04_consultations.sql"
    "05_scheduling.sql"
    "06_audit_logs.sql"
    "07_notifications.sql"
    "08_offline_queue.sql"
)

for file in "${SCHEMA_FILES[@]}"; do
    if [ -f "$SCHEMAS_DIR/$file" ]; then
        echo "  Running $file..."
        psql -d globalhealth_connect -f "$SCHEMAS_DIR/$file" > /dev/null 2>&1
        echo "  ✅ $file completed"
    else
        echo "  ⚠️  $file not found, skipping..."
    fi
done

echo ""
echo "🔍 Verifying database setup..."

# Check if tables were created
TABLE_COUNT=$(psql -d globalhealth_connect -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" | xargs)

echo ""
echo "✅ Database setup complete!"
echo ""
echo "📊 Statistics:"
echo "   - Tables created: $TABLE_COUNT"
echo "   - Database: globalhealth_connect"
echo "   - Host: localhost"
echo "   - Port: 5432"
echo ""

# List all tables
echo "📋 Created tables:"
psql -d globalhealth_connect -c "\dt" | tail -n +4 | head -n -2

echo ""
echo "🎉 Setup complete! Your database is ready for development."
echo ""
echo "💡 Connection string for backend/.env:"
echo "   DATABASE_URL=postgresql://$(whoami)@localhost:5432/globalhealth_connect"
echo ""
echo "📝 Next steps:"
echo "   1. Update backend/.env with the connection string above"
echo "   2. Test connection: psql -d globalhealth_connect"
echo "   3. Start building your backend API!"

