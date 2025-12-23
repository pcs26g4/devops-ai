import os
import requests
import json

API_KEY = os.getenv("GEMINI_API_KEY")

if not API_KEY:
    raise Exception("GEMINI_API_KEY environment variable not set")

service_description = """
Node.js backend service using PostgreSQL database.
"""

url = (
    "https://generativelanguage.googleapis.com/v1beta/"
    "models/gemini-2.5-flash:generateContent"
    f"?key={API_KEY}"
)

prompt = f"""
You are a Site Reliability Engineer.

Suggest Prometheus alert rules for a REST API service.

Requirements:
- High error rate alert
- High latency alert
- Pod restart alert
- Use PromQL
- Production-ready thresholds
"""

payload = {
    "contents": [
        {
            "parts": [
                {"text": prompt}
            ]
        }
    ]
}

response = requests.post(
    url,
    headers={"Content-Type": "application/json"},
    data=json.dumps(payload)
)

if response.status_code != 200:
    raise Exception(f"API call failed: {response.text}")

result = response.json()
output_text = result["candidates"][0]["content"]["parts"][0]["text"]

with open("generated-ci.yml", "w") as f:
    f.write(output_text)

print("CI pipeline generated and saved to generated-ci.yml")
