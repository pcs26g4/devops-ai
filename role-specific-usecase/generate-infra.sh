<<<<<<< HEAD
#!/bin/bash

# ----------------------------
# Safety check: API key
# ----------------------------
if [ -z "$GEMINI_API_KEY" ]; then
  echo "ERROR: GEMINI_API_KEY not set"
  exit 1
fi

# ----------------------------
# Argument parsing
# ----------------------------
if [ "$1" != "--type" ] || [ -z "$2" ]; then
  echo "Usage: ./generate-infra.sh --type [ci|docker]"
  exit 1
fi

TYPE=$2

# ----------------------------
# Prompts based on type
# ----------------------------
if [ "$TYPE" = "ci" ]; then

  PROMPT="
You are a senior DevOps engineer.

Generate a GitHub Actions CI pipeline for:
- Python Flask application
- Uses PostgreSQL
- Install dependencies
- Run tests
- Follow best practices

Output ONLY valid YAML.
"

  OUTPUT_FILE="ci-pipeline.yml"

elif [ "$TYPE" = "docker" ]; then

  PROMPT="
You are a senior DevOps engineer.

Generate a Dockerfile for:
- Python Flask application
- Use Python 3.10 slim image
- Use best practices
- Expose port 5000

Output ONLY Dockerfile content.
"

  OUTPUT_FILE="Dockerfile"

else
  echo "Invalid type. Use ci or docker."
  exit 1
fi

# ----------------------------
# Gemini API endpoint
# ----------------------------
URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY"

# ----------------------------
# Request payload
# ----------------------------
read -r -d '' PAYLOAD << EOM
{
  "contents": [
    {
      "parts": [
        {
          "text": "$PROMPT"
        }
      ]
    }
  ]
}
EOM

# ----------------------------
# Call AI and save output
# ----------------------------
curl -s -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq -r '.candidates[0].content.parts[0].text' \
  > "$OUTPUT_FILE"

echo "$OUTPUT_FILE generated successfully"
=======
#!/bin/bash

# ----------------------------
# Safety check: API key
# ----------------------------
if [ -z "$GEMINI_API_KEY" ]; then
  echo "ERROR: GEMINI_API_KEY not set"
  exit 1
fi

# ----------------------------
# Argument parsing
# ----------------------------
if [ "$1" != "--type" ] || [ -z "$2" ]; then
  echo "Usage: ./generate-infra.sh --type [ci|docker]"
  exit 1
fi

TYPE=$2

# ----------------------------
# Prompts based on type
# ----------------------------
if [ "$TYPE" = "ci" ]; then

  PROMPT="
You are a senior DevOps engineer.

Generate a GitHub Actions CI pipeline for:
- Python Flask application
- Uses PostgreSQL
- Install dependencies
- Run tests
- Follow best practices

Output ONLY valid YAML.
"

  OUTPUT_FILE="ci-pipeline.yml"

elif [ "$TYPE" = "docker" ]; then

  PROMPT="
You are a senior DevOps engineer.

Generate a Dockerfile for:
- Python Flask application
- Use Python 3.10 slim image
- Use best practices
- Expose port 5000

Output ONLY Dockerfile content.
"

  OUTPUT_FILE="Dockerfile"

else
  echo "Invalid type. Use ci or docker."
  exit 1
fi

# ----------------------------
# Gemini API endpoint
# ----------------------------
URL="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$GEMINI_API_KEY"

# ----------------------------
# Request payload
# ----------------------------
read -r -d '' PAYLOAD << EOM
{
  "contents": [
    {
      "parts": [
        {
          "text": "$PROMPT"
        }
      ]
    }
  ]
}
EOM

# ----------------------------
# Call AI and save output
# ----------------------------
curl -s -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  | jq -r '.candidates[0].content.parts[0].text' \
  > "$OUTPUT_FILE"

echo "$OUTPUT_FILE generated successfully"
>>>>>>> 915394f6a783e1daa8111e12a6419de7ee3fca4c
