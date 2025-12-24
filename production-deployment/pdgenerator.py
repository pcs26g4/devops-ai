import os
import time
import json
import requests

# =====================================================
# 1. API KEY
# =====================================================
API_KEY = os.getenv("GEMINI_API_KEY")
if not API_KEY:
    raise Exception("GEMINI_API_KEY environment variable not set")

# =====================================================
# 2. SERVICE DESCRIPTION
# =====================================================
service_description = """
Python Flask REST API
Stateless service
Runs on Kubernetes
Uses PostgreSQL (managed cloud database)
Deployed using GitOps
Production environment
"""

# =====================================================
# 3. PROMPTS
# =====================================================
terraform_prompt = f"""
You are a senior DevOps engineer.

Generate a Terraform module for deploying infrastructure for this service:

{service_description}

Requirements:
- Managed Kubernetes cluster (abstracted, cloud-agnostic)
- Kubernetes namespace for the application
- Labels/tags for environment and owner
- Variables for environment and region
- Outputs for namespace name
- Include BOTH main.tf and variables.tf content

Output ONLY Terraform code.
"""

argocd_prompt = f"""
You are a senior DevOps engineer.

Generate an ArgoCD Application YAML for this service:

{service_description}

Requirements:
- GitOps style deployment
- Source from a Git repository
- Target Kubernetes namespace
- Automated sync enabled
- Self-heal enabled
- Prune enabled

Output ONLY valid YAML.
"""

cost_prompt = f"""
You are a cloud cost optimization expert.

Estimate infrastructure cost considerations for this service:

{service_description}

Include:
- Major cost drivers
- Kubernetes resource cost factors
- Cost optimization recommendations
- Right-sizing suggestions

Output clear bullet points.
"""

# =====================================================
# 4. GEMINI ENDPOINT
# =====================================================
GEMINI_URL = (
    "https://generativelanguage.googleapis.com/v1beta/"
    "models/gemini-2.5-flash:generateContent"
    f"?key={API_KEY}"
)

# =====================================================
# 5. AI CALL FUNCTION (TIMEOUT + RETRY)
# =====================================================
def call_ai(prompt, retries=3, timeout=120):
    payload = {
        "contents": [
            {
                "parts": [
                    {"text": prompt}
                ]
            }
        ]
    }

    for attempt in range(1, retries + 1):
        try:
            print(f"\n[INFO] Calling Gemini API (attempt {attempt})...")
            response = requests.post(
                GEMINI_URL,
                headers={"Content-Type": "application/json"},
                data=json.dumps(payload),
                timeout=timeout
            )

            if response.status_code != 200:
                raise Exception(response.text)

            result = response.json()
            return result["candidates"][0]["content"]["parts"][0]["text"]

        except requests.exceptions.ReadTimeout:
            print("[WARN] Gemini response timed out, retrying...")
            time.sleep(5)

        except requests.exceptions.RequestException as e:
            print(f"[WARN] Network error: {e}")
            time.sleep(5)

    raise Exception("Gemini API failed after multiple retries")

# =====================================================
# 6. GENERATE ARTIFACTS
# =====================================================
print("\n=== Generating Terraform module ===")
terraform_code = call_ai(terraform_prompt)

print("\n=== Generating ArgoCD Application YAML ===")
argocd_yaml = call_ai(argocd_prompt)

print("\n=== Generating cost optimization notes ===")
cost_notes = call_ai(cost_prompt)

# =====================================================
# 7. WRITE FILES
# =====================================================
with open("main.tf", "w") as f:
    f.write(terraform_code)

with open("argocd-app.yaml", "w") as f:
    f.write(argocd_yaml)

with open("COST_NOTES.txt", "w") as f:
    f.write(cost_notes)

# =====================================================
# 8. README
# =====================================================
readme_content = """
# Production Deployment Patterns (AI Generated)

## Overview
This project demonstrates AI-assisted generation of production deployment artifacts.

## Generated Artifacts
- main.tf: Terraform infrastructure module
- argocd-app.yaml: ArgoCD GitOps application manifest
- COST_NOTES.txt: Cost optimization analysis

## What This Does
- Generates Infrastructure as Code
- Generates GitOps deployment configuration
- Provides cost awareness early in design

## What This Does NOT Do
- Does NOT apply Terraform
- Does NOT deploy to Kubernetes
- Does NOT create real cloud resources

## Why This Matters
In real-world DevOps, templates and generators speed up
delivery while keeping human review in control.
"""

with open("README.md", "w") as f:
    f.write(readme_content)

print("\n✅ Production deployment artifacts generated successfully")
print("Files created:")
print("- main.tf")
print("- argocd-app.yaml")
print("- COST_NOTES.txt")
print("- README.md")
