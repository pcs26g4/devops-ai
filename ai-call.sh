#!/bin/bash

# Load environment variables
export $(cat .env | xargs)

# Safety check
if [ -z "$GEMINI_API_KEY" ]; then
  echo "ERROR: GEMINI_API_KEY not set"
  exit 1
fi

# Sample logs to summarize
LOGS="ERROR: Database connection timeout
WARN: Retrying connection
INFO: Service restarted successfully"

# Gemini API endpoint
URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY"




# Request payload
read -r -d '' PAYLOAD << EOM
{
  "contents": [
    {
      "parts": [
        {
          "text": "Summarize the following logs and identify the main issue:\n\n$LOGS"
        }
      ]
    }
  ]
}
EOM

# Call Gemini API
curl -s -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  -o response.json

echo "Raw response saved to response.json"