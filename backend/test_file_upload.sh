#!/bin/bash

# Test File Upload Endpoints
# This script tests the TUS protocol file upload endpoints

echo "🧪 Testing File Upload Endpoints"
echo "================================"
echo ""

# Get authentication token
echo "1. Authenticating..."
TOKEN=$(curl -s -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=test@example.com&password=testpass123" | \
  python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")

if [ -z "$TOKEN" ]; then
    echo "❌ Authentication failed. Make sure server is running and user exists."
    exit 1
fi

echo "✅ Authenticated"
echo ""

# Get a case ID
echo "2. Getting case ID..."
CASE_ID=$(curl -s http://localhost:8000/api/v1/cases/ \
  -H "Authorization: Bearer $TOKEN" | \
  python3 -c "import sys, json; data=json.load(sys.stdin); print(data['cases'][0]['id'] if data.get('cases') else '')")

if [ -z "$CASE_ID" ]; then
    echo "⚠️  No cases found. Creating a test case..."
    CASE_ID=$(curl -s -X POST http://localhost:8000/api/v1/cases/ \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"title":"Test Case for File Upload","chief_complaint":"Testing file uploads","urgency":"routine"}' | \
      python3 -c "import sys, json; print(json.load(sys.stdin)['id'])")
    echo "✅ Created case: $CASE_ID"
fi

echo "Case ID: $CASE_ID"
echo ""

# Test TUS Create Upload
echo "3. Testing TUS Create Upload (POST)..."
RESPONSE=$(curl -s -X POST http://localhost:8000/api/v1/files/upload \
  -H "Authorization: Bearer $TOKEN" \
  -H "Upload-Length: 1024" \
  -H "Upload-Metadata: filename dGVzdC5qcGc=,filetype image/jpeg,case_id $CASE_ID" \
  -i)

HTTP_CODE=$(echo "$RESPONSE" | head -1 | grep -oP '\d{3}')
LOCATION=$(echo "$RESPONSE" | grep -i "Location:" | sed 's/.*Location: //' | tr -d '\r')

if [ "$HTTP_CODE" = "201" ]; then
    echo "✅ Upload session created"
    echo "   Location: $LOCATION"
    UPLOAD_ID=$(echo "$LOCATION" | sed 's/.*\/\([^/]*\)$/\1/')
    echo "   Upload ID: $UPLOAD_ID"
else
    echo "❌ Failed to create upload session"
    echo "$RESPONSE" | head -10
    exit 1
fi
echo ""

# Test TUS HEAD
echo "4. Testing TUS HEAD request..."
HEAD_RESPONSE=$(curl -s -X HEAD "http://localhost:8000/api/v1/files/upload/$UPLOAD_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -i)

HEAD_CODE=$(echo "$HEAD_RESPONSE" | head -1 | grep -oP '\d{3}')
if [ "$HEAD_CODE" = "200" ]; then
    echo "✅ HEAD request successful"
    echo "$HEAD_RESPONSE" | grep -E "(Upload-Offset|Upload-Length|Tus-Resumable)"
else
    echo "❌ HEAD request failed"
    echo "$HEAD_RESPONSE" | head -5
fi
echo ""

# Test Get File Metadata
echo "5. Getting file metadata..."
# First, we need to get the file ID from the upload
# For now, let's test listing files for the case
echo "   Listing files for case..."
FILES=$(curl -s "http://localhost:8000/api/v1/files/case/$CASE_ID" \
  -H "Authorization: Bearer $TOKEN")

echo "$FILES" | python3 -m json.tool 2>/dev/null || echo "$FILES"
echo ""

echo "✅ File upload endpoints test complete!"
echo ""
echo "📝 Note: Full TUS upload requires actual file chunks via PATCH request"
echo "   This is typically done by the mobile app using a TUS client library"

