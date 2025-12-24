```terraform
# variables.tf
#
# This file defines the input variables for the Terraform module.
# These variables allow customization of the infrastructure deployment.

variable "environment" {
  description = "The deployment environment (e.g., 'production', 'staging'). Used for naming and labels."
  type        = string
  default     = "production"
}

variable "region" {
  description = "The cloud region where the Kubernetes cluster exists. Used for tagging/metadata."
  type        = string
  # No default, as region is typically specific to the deployment location.
}

variable "owner" {
  description = "The owner or team responsible for this service infrastructure."
  type        = string
  default     = "devops-team"
}

variable "project_name" {
  description = "The base name for the project or service (e.g., 'flask-api'). Used for resource naming."
  type        = string
  default     = "flask-api"
}

variable "replica_count" {
  description = "Number of desired replicas for the Flask API deployment."
  type        = number
  default     = 3
}

variable "image_name" {
  description = "Docker image name for the Flask API application (e.g., 'mycompany/flask-rest-api:latest')."
  type        = string
  default     = "mycompany/flask-rest-api:latest" # Placeholder, update with actual image
}

variable "container_port" {
  description = "The port on which the Flask API application listens inside the container."
  type        = number
  default     = 5000 # Common default for Flask
}

variable "ingress_host" {
  description = "The hostname for the Kubernetes Ingress resource, making the API externally accessible."
  type        = string
  default     = "api.example.com" # Placeholder, MUST be updated for production
}

variable "ingress_class_name" {
  description = "The name of the IngressClass to use for the Ingress resource (e.g., 'nginx')."
  type        = string
  default     = "nginx"
}

variable "cert_manager_cluster_issuer" {
  description = "The name of the Cert-Manager ClusterIssuer to use for TLS certificates (e.g., 'letsencrypt-prod')."
  type        = string
  default     = "letsencrypt-prod" # Placeholder, adjust if using cert-manager or different issuer
}
```

```terraform
# main.tf
#
# This file contains the main Terraform resources for deploying the Python Flask REST API
# infrastructure on Kubernetes, following GitOps principles for a production environment.

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20" # Ensure compatibility with Kubernetes API
    }
  }
}

# The Kubernetes provider configuration.
# It is assumed that 'kubeconfig' is configured externally (e.g., via KUBECONFIG env var,
# default kubeconfig file, or in-cluster configuration) as the cluster is managed and abstracted.
provider "kubernetes" {}

# 1. Kubernetes Namespace
# Creates a dedicated namespace for the Flask API application.
resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = "${var.project_name}-${var.environment}"

    labels = {
      environment = var.environment
      owner       = var.owner
      project     = var.project_name
      # Labels for GitOps tools can be added here, e.g.,
      # "gitops.fluxcd.io/tenant" = "my-team"
    }

    annotations = {
      "linkerd.io/inject" = "enabled" # Example for Linkerd service mesh injection
    }
  }
}

# 2. Kubernetes Service Account
# Creates a service account for the application pods to use.
resource "kubernetes_service_account" "app_service_account" {
  metadata {
    name      = "${var.project_name}-sa"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name

    labels = {
      environment = var.environment
      owner       = var.owner
      project     = var.project_name
    }
  }
}

# 3. Kubernetes Secret for Database Credentials (Placeholder)
# In a robust GitOps workflow for production, sensitive secrets like database credentials
# should NOT be stored directly in Terraform code or Git in plain text.
# Instead, they are typically managed by:
# - External Secrets Operator (fetching from AWS Secrets Manager, Vault, Azure Key Vault, GCP Secret Manager)
# - Sealed Secrets (encrypting secrets into Git)
# - HashiCorp Vault Agent Injector
# This resource is included as a placeholder to demonstrate where it would be referenced
# by the application deployment. It creates an empty secret, assuming its data will be populated
# by a GitOps secret management tool.
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "${var.project_name}-db-credentials"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name

    labels = {
      environment = var.environment
      owner       = var.owner
      project     = var.project_name
    }
  }

  type = "Opaque" # Standard secret type

  # No 'data' block here for sensitive values in GitOps.
  # Example if *not* using a GitOps secret manager (NOT recommended for production):
  # data = {
  #   DB_HOST     = base64encode("your-db-host.example.com")
  #   DB_NAME     = base64encode("flaskdb")
  #   DB_USER     = base64encode("flaskuser")
  #   DB_PASSWORD = base64encode("supersecretpassword")
  # }
}

# 4. Kubernetes Deployment for the Python Flask API
# Defines the desired state for the stateless Flask API application pods.
resource "kubernetes_deployment_v1" "flask_api_deployment" {
  metadata {
    name      = "${var.project_name}-deployment"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name

    labels = {
      app                         = var.project_name
      environment                 = var.environment
      owner                       = var.owner
      "app.kubernetes.io/name"    = var.project_name
      "app.kubernetes.io/instance" = "${var.project_name}-${var.environment}" # Instance name for GitOps
      "app.kubernetes.io/component" = "api"
      "app.kubernetes.io/part-of" = var.project_name
      "app.kubernetes.io/managed-by" = "terraform" # Indicates managed by Terraform
    }
  }

  spec {
    replicas = var.replica_count

    selector {
      match_labels = {
        app = var.project_name
      }
    }

    template {
      metadata {
        labels = {
          app                         = var.project_name
          environment                 = var.environment
          owner                       = var.owner
          "app.kubernetes.io/name"    = var.project_name
          "app.kubernetes.io/instance" = "${var.project_name}-${var.environment}"
          "app.kubernetes.io/component" = "api"
          "app.kubernetes.io/part-of" = var.project_name
          "app.kubernetes.io/managed-by" = "terraform"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.app_service_account.metadata[0].name

        container {
          name  = var.project_name
          image = var.image_name
          port {
            container_port = var.container_port
            name           = "http"
            protocol       = "TCP"
          }
          resources {
            limits = {
              cpu    = "500m"  # Max CPU usage of 0.5 cores
              memory = "512Mi" # Max memory usage of 512 MiB
            }
            requests = {
              cpu    = "250m"  # Guaranteed CPU usage of 0.25 cores
              memory = "256Mi" # Guaranteed memory usage of 256 MiB
            }
          }
          # Inject database credentials as environment variables from the secret
          env_from {
            secret_ref {
              name = kubernetes_secret.db_credentials.metadata[0].name
            }
          }
          # Health checks are crucial for production readiness
          liveness_probe {
            http_get {
              path = "/health" # Assumes a /health endpoint in the Flask app
              port = var.container_port
            }
            initial_delay_seconds = 10 # Wait 10s before first probe
            period_seconds        = 10 # Probe every 10s
            timeout_seconds       = 5  # Timeout after 5s
            failure_threshold     = 3  # After 3 failures, restart container
          }
          readiness_probe {
            http_get {
              path = "/health" # Assumes a /health endpoint in the Flask app
              port = var.container_port
            }
            initial_delay_seconds = 5  # Wait 5s before first probe
            period_seconds        = 5  # Probe every 5s
            timeout_seconds       = 3  # Timeout after 3s
            failure_threshold     = 1  # After 1 failure, remove from service endpoints
          }
        }
        # Pod anti-affinity for better high availability across nodes
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_labels = {
                    app = var.project_name
                  }
                }
                topology_key = "kubernetes.io/hostname" # Spread pods across different nodes
              }
            }
          }
        }
      }
    }
  }
}

# 5. Kubernetes Service to expose the Deployment internally
# Provides a stable internal IP address and DNS name for the Flask API.
resource "kubernetes_service_v1" "flask_api_service" {
  metadata {
    name      = "${var.project_name}-service"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name

    labels = {
      app                         = var.project_name
      environment                 = var.environment
      owner                       = var.owner
      "app.kubernetes.io/name"    = var.project_name
      "app.kubernetes.io/instance" = "${var.project_name}-${var.environment}"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    selector = {
      app = var.project_name
    }
    port {
      port        = var.container_port
      target_port = var.container_port
      protocol    = "TCP"
      name        = "http"
    }
    type = "ClusterIP" # Internal service, exposed externally via Ingress
  }
}

# 6. Kubernetes Ingress for external access
# Configures external access to the Flask API using a managed Ingress Controller (e.g., Nginx).
# Also sets up TLS termination using Cert-Manager.
resource "kubernetes_ingress_v1" "flask_api_ingress" {
  metadata {
    name      = "${var.project_name}-ingress"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name

    annotations = {
      # Ingress controller class annotation
      "kubernetes.io/ingress.class"                = var.ingress_class_name
      "nginx.ingress.kubernetes.io/rewrite-target" = "/" # Example: rewrite target to root path
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true" # Always redirect to HTTPS

      # Cert-Manager annotations for automatic TLS certificate provisioning
      "cert-manager.io/cluster-issuer" = var.cert_manager_cluster_issuer
    }

    labels = {
      app                         = var.project_name
      environment                 = var.environment
      owner                       = var.owner
      "app.kubernetes.io/name"    = var.project_name
      "app.kubernetes.io/instance" = "${var.project_name}-${var.environment}"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    rule {
      host = var.ingress_host
      http {
        path {
          path      = "/"
          path_type = "Prefix" # Matches all paths under the host
          backend {
            service {
              name = kubernetes_service_v1.flask_api_service.metadata[0].name
              port {
                number = var.container_port
              }
            }
          }
        }
      }
    }
    # TLS configuration for HTTPS. Cert-Manager will populate this secret.
    tls {
      hosts       = [var.ingress_host]
      secret_name = "${var.project_name}-tls-secret" # Name of the secret Cert-Manager will create/manage
    }
  }
}

# Outputs from the module
# These values can be used by other Terraform configurations or for informational purposes.

output "namespace_name" {
  description = "The name of the Kubernetes namespace created for the application."
  value       = kubernetes_namespace.app_namespace.metadata[0].name
}

output "service_name" {
  description = "The name of the Kubernetes ClusterIP service for the application."
  value       = kubernetes_service_v1.flask_api_service.metadata[0].name
}

output "ingress_host_url" {
  description = "The URL where the Flask API is externally accessible via Ingress (HTTPS)."
  value       = "https://${var.ingress_host}"
}

output "owner_email" {
  description = "The email contact for the owner of this infrastructure."
  value       = "${var.owner}@example.com" # Example, adapt to your organization's email format
}
```