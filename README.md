# Akeyless Secrets Injection Automation

This repository contains scripts and Kubernetes manifests to automate the deployment of the Akeyless Secrets Injection Webhook and demonstrate secret consumption.

### 🎯 Project Goal
**The primary goal of this project is to automate the preparation of Akeyless resources and the installation of the Mutation Webhook for transparent secret injection into Kubernetes pods.**

## 📂 Core Components
| File | Function |
| :--- | :--- |
| injector_preparation.sh | **Setup**: Validates Akeyless Auth/Roles, creates test secrets, and prepares Helm values. |
| values.yaml | **Configuration**: Helm chart values for the Akeyless Secrets Injection Webhook. |
| env.yaml | **Example**: Deployment using Akeyless secrets as environment variables. |
| access_db.yaml | **Example**: Advanced usage parsing JSON secrets for PostgreSQL authentication. |
| .gitignore | **Maintenance**: Prevents tracking of local logs (`pf.log`) and backup files. |

## 🛠️ Prerequisites
Before starting this demo, you must have a functional **Akeyless Kubernetes Auth Method** configured in your Gateway. If you haven't set this up yet, you can use this automation tool:
- **K8s Auth Setup Tool**: [Kubernetes-Authentication](https://github.com/leon-maister/Kubernetes-Authentication)

## ⚙️ Configuration
Before running the setup or building images, you must configure the following parameters:

### 1. Akeyless Script Parameters (`injector_preparation.sh`)
- **`AUTH_METHOD_NAME`**: The full path to your Kubernetes Authentication Method.
- **`ROLE_NAME`**: The Akeyless Role that will be associated with the Auth Method.
- **`SECRET_NAME`**: The path where the test secret will be checked or created.
- **`SECRET_VALUE`**: The initial value to be used if the secret does not exist.

### 2. Helm & Environment Variables (`values.yaml`)
- **`AKEYLESS_GATEWAY_URL`**: Your Akeyless Gateway address (e.g., `https://your-gw.akeyless.fans`).
- **`ACCESS_ID`**: The Access ID of your **Kubernetes Auth Method**.
- **`K8S_AUTH_CONFIG_NAME`**: The name of the K8s Auth configuration on the Gateway.
- **`SECRET_NAME`**: The full path of the secret you want to retrieve.

## 🛠️ Usage Examples
This project demonstrates two primary ways to consume secrets:

### 1. Environment Variable Injection (`env.yaml`)
- Secrets are injected directly into container environment variables using the `akeyless/enabled: "true"` annotation.

### 2. Dynamic DB Credentials (`access_db.yaml`)
- Injects a JSON secret containing database credentials and uses `jq` for runtime parsing.

## 🚀 Quick Start
1. Ensure you are logged into Akeyless CLI and have kubectl access.
2. Open `injector_preparation.sh` and set your specific variables.
3. Run the preparation script:
```bash
chmod +x injector_preparation.sh
./injector_preparation.sh
```
4. Install the injector using Helm:
```bash
helm install akeyless-secrets-injection akeyless/akeyless-secrets-injection -f values.yaml -n akeyless
```

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)

<small><sub>/home/keyless/akeyless-injector-script</sub></small>
