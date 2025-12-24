import os
import requests
import json

API_KEY = os.getenv("GEMINI_API_KEY")

if not API_KEY:
    raise Exception("GEMINI_API_KEY environment variable not set")

logs = """
ERROR database connection timeout
ERROR database connection timeout
WARN retrying connection
ERROR database connection timeout
INFO service restarted
"""

prompt = f"""
You are a Site Reliability Engineer.

Analyze the following application logs:

{logs}

Tasks:
1. Identify anomalies or unusual patterns
2. Summarize the root cause
3. Suggest alert rules with thresholds
4. Indicate alert severity (low/medium/high)

Output in clear bullet points.
"""

url = (
    "https://generativelanguage.googleapis.com/v1beta/"
    "models/gemini-2.5-flash:generateContent"
    f"?key={API_KEY}"
)

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
    raise Exception(f"AI call failed: {response.text}")

result = response.json()
analysis = result["candidates"][0]["content"]["parts"][0]["text"]

with open("anomaly-summary.txt", "w") as f:
    f.write(analysis)

print("AI Anomaly Analysis:\n")
print(analysis)

webhook_payload = {
    "alert_analysis": analysis
}

print("\nSimulating webhook POST with payload:")
print(json.dumps(webhook_payload, indent=2))
