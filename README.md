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
| access_db.yaml | **Example**: Advanced usage parsing JSON secrets for PostgreSQL authentication and connection testing. |

## 🏗️ Module Environment Preparation
Once configured, execute the preparation script:
```bash
chmod +x injector_preparation.sh
./injector_preparation.sh
```

## 🚀 Module Injector Configuration and Start UP
### 🚀 Deployment
```bash
helm install injector akeyless/akeyless-secrets-injection --namespace akeyless -f values.yaml
```

## 🛠️ How the Secret Injection Works
Before diving into examples, it's important to understand the automation logic:
1. **Mutation**: When you apply a YAML with the `akeyless/enabled: "true"` annotation, the Akeyless Webhook intercepts the request.
2. **Sidecar & Init**: The webhook automatically injects an **init-container** and a **sidecar container** into your pod.
3. **Transparent Injection**: The init-container authenticates with Akeyless, fetches the secret, and provides it to your main container.
4. **No Code Changes**: Your application simply reads a standard environment variable (like `$DB_ACCESS`). It doesn't need Akeyless SDKs or API calls—the infrastructure handles everything.

## 🛠️ Usage Examples

### 1. Secret Injection (basic scenario)
- Deploy using `akeyless/enabled: "true"` annotation.
```bash
kubectl apply -f env.yaml
```
- Check the logs to see the injected value:
```bash
kubectl logs -l app=hello-secrets
```

### 2. Inject DB secret (complicated scenario)
#### 🏗️ Preparation
**Install PostgreSQL:**
```bash
helm install my-postgres bitnami/postgresql --set auth.postgresPassword=postgrespass --set auth.username=myuser --set auth.password=mypassword --set auth.database=mydb
```

#### 🧪 Demo Flow (Manual Validation)
1. **Port Forward**: `kubectl port-forward svc/my-postgres-postgresql 5432:5432 > /dev/null 2>&1 &`
2. **Manage Demo User**:
   - Check/Remove/Create `demouser` via psql (as shown in the provided demo scripts).
3. **Populate Secret**: 
   ```bash
   akeyless create-secret --name /K8s/InjectorDemo/DB-Secret --value '{"user_name":"demouser","password":"qwertyQWERTY1@"}' --json
   ```
4. **Apply & Verify Connection**:
   - Deploy/Force-Replace:
     ```bash
     kubectl replace --force -f access_db.yaml
     ```
   - **Check logs** (The pod will parse JSON and attempt a real DB connection):
     ```bash
     kubectl logs -l app=hello-db-secrets
     ```
5. **Cleanup**: `pkill -f "kubectl port-forward svc/my-postgres-postgresql"`

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)

<small><sub>/home/keyless/akeyless-injector-script</sub></small>
