# Kubernetes Secrets Rotation with AWS Secrets Manager

This repo demonstrates how to manage secrets in Kubernetes using AWS Secrets Manager, External Secrets Operator, and Stakater Reloader.

## 🔐 Secrets Management Flow

This architecture securely syncs secrets from AWS Secrets Manager into Kubernetes and ensures applications reload when secrets are updated.

### 📊 Architecture Diagram

```text
+---------------------+
| AWS Secrets Manager |
+---------------------+
          |
          v
+----------------------------+
| External Secrets Operator |
|   (Running in K8s)        |
+----------------------------+
          |
          v
+---------------------------+       +------------------+
| Kubernetes Secret         | <---> | Stakater Reloader|
+---------------------------+       +------------------+
          |
          v
+---------------------------+
| Applications using secret |
+---------------------------+

```



## Components
- **AWS Secrets Manager** for storing and rotating secrets.
- **External Secrets Operator** to sync secrets into Kubernetes.
- **Stakater Reloader** to restart pods on secret changes.

## Quick Start

```bash
cd scripts
./deploy.sh
```
