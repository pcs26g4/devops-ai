import os
import requests
import json

# =========================
# 1. API KEY (SECRET)
# =========================
API_KEY = os.getenv("GEMINI_API_KEY")

if not API_KEY:
    raise Exception("GEMINI_API_KEY environment variable not set")

# =========================
# 2. SERVICE DESCRIPTION
# =========================
service_description = """
Python Flask REST API
Stateless application
Runs on port 5000
Uses PostgreSQL (external database)
Containerized and deployed on Kubernetes
"""

# =========================
# 3. DOCKERFILE PROMPT
# =========================
docker_prompt = f"""
You are a senior DevOps engineer.

Generate a production-ready Dockerfile for the following service:

{service_description}

Requirements:
- Use python:3.10-slim
- Set a working directory
- Copy requirements.txt and install dependencies
- Copy application source code
- Expose port 5000
- Use gunicorn to run the app
- Follow Docker best practices

Output ONLY the Dockerfile content.
"""

# =========================
# 4. KUBERNETES PROMPT
# =========================
k8s_prompt = f"""
You are a senior DevOps engineer.

Generate Kubernetes YAML manifests for the following service:

{service_description}

Requirements:
- Use Deployment (stateless app)
- 2 replicas
- Container port 5000
- Reasonable CPU and memory requests/limits
- Service of type ClusterIP
- Output valid YAML
- Include Deployment and Service

Output ONLY YAML.
"""

# =========================
# 5. GEMINI ENDPOINT
# =========================
url = (
    "https://generativelanguage.googleapis.com/v1beta/"
    "models/gemini-2.5-flash:generateContent"
    f"?key={API_KEY}"
)

# =========================
# 6. AI CALL FUNCTION
# =========================
def call_ai(prompt):
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
        data=json.dumps(payload),
	timeout=30
    )

    if response.status_code != 200:
        raise Exception(f"AI call failed: {response.text}")

    result = response.json()
    return result["candidates"][0]["content"]["parts"][0]["text"]

# =========================
# 7. GENERATE DOCKERFILE
# =========================
dockerfile_content = call_ai(docker_prompt)

with open("Dockerfile", "w") as f:
    f.write(dockerfile_content)

print("Dockerfile generated successfully")

# =========================
# 8. GENERATE K8s MANIFESTS
# =========================
k8s_yaml = call_ai(k8s_prompt)

with open("deployment.yaml", "w") as f:
    f.write(k8s_yaml)

print("Kubernetes manifests generated successfully")

print("\nDONE ✅")
print("Generated files:")
print("- Dockerfile")
print("- deployment.yaml")
