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
| .gitignore | **Maintenance**: Prevents tracking of local logs (`pf.log`) and backup files. |

## 🏗️ Module Environment Preparation
The purpose of this module is to handle all necessary preparations and resource validations required to successfully run and deploy the Akeyless Injector.

### ⚙️ Configuration
Before running the setup, configure the parameters in `injector_preparation.sh`:
- **`AUTH_METHOD_NAME`**, **`ROLE_NAME`**, **`SECRET_NAME`**, **`SECRET_VALUE`**.

## 🚀 Run Preparation
```bash
chmod +x injector_preparation.sh
./injector_preparation.sh
```

## 🚀 Module Injector Configuration and Start UP
### 🚀 Deployment
Once the configuration is verified, install the injector:
```bash
helm install injector akeyless/akeyless-secrets-injection --namespace akeyless -f values.yaml
```

### 🔍 Verify Installation
```bash
kubectl get all -n akeyless
```

## 🛠️ How the Secret Injection Works
Before diving into examples, it's important to understand the automation logic:
1. **Mutation**: When you apply a YAML with the `akeyless/enabled: "true"` annotation, the Akeyless Webhook intercepts the request.
2. **Sidecar & Init**: The webhook automatically injects an **init-container** and a **sidecar container** into your pod.
3. **Transparent Injection**: The init-container authenticates with Akeyless, fetches the secret, and provides it to your main container.
4. **No Code Changes**: Your application simply reads a standard environment variable (like `$DB_ACCESS`). It doesn't need Akeyless SDKs—the infrastructure handles everything.

## 🛠️ Usage Examples

### 1. Secret Injection (basic scenario)
- Ensure `env.yaml` points to a valid secret.
- Deploy using `akeyless/enabled: "true"` annotation:
```bash
kubectl apply -f env.yaml
```
- Check the logs to verify injection:
```bash
kubectl logs -l app=hello-secrets
```

### 2. Inject DB secret (complicated scenario)
#### 🏗️ Preparation
**Install PostgreSQL via Helm:**
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-postgres bitnami/postgresql --set auth.postgresPassword=postgrespass --set auth.username=myuser --set auth.password=mypassword --set auth.database=mydb
```
> **Note:** This creates **postgres** (superuser, pass: `postgrespass`) and **myuser** (app user, pass: `mypassword`).

#### 🧪 Demo Flow (Manual Validation)
1. **Clean Up Akeyless**: `akeyless delete-item --name /Path/To/Json/Secret`
2. **Enable Database Access**: 
   ```bash
   kubectl port-forward svc/my-postgres-postgresql 5432:5432 > /dev/null 2>&1 &
   ```
3. **Verify/Create Demo User**:
   - **Show that the demouser does not exist**:
     ```bash
     PGPASSWORD='mypassword' psql -h localhost -U myuser -d mydb -c "\du"
     ```
   - **In case it exists - remove it**:
     ```bash
     PGPASSWORD='mypassword' psql -h localhost -U myuser -d mydb -c "DROP ROLE demouser;"
     ```
   - **Create the demouser** for the demo:
     ```bash
     PGPASSWORD='mypassword' psql -h localhost -U myuser -d mydb -c "CREATE ROLE demouser WITH LOGIN SUPERUSER PASSWORD 'qwertyQWERTY1@';"
     ```
4. **Populate Akeyless Secret**: 
   ```bash
   akeyless create-secret --name /Path/To/Json/Secret --value '{"user_name":"demouser","password":"qwertyQWERTY1@"}' --json
   ```
   > **Note:** Variable must be in **JSON format**.
5. **Apply & Verify Connection**:
   - Ensure `access_db.yaml` points to `akeyless:/Path/To/Json/Secret`.
   - Deploy/Force-Replace:
     ```bash
     kubectl replace --force -f access_db.yaml
     ```
   - **Check logs (using the correct plural label)**:
     ```bash
     kubectl logs -l app=hello-db-secrets
     ```
6. **Cleanup**: `pkill -f "kubectl port-forward svc/my-postgres-postgresql"`

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)

<small><sub>/home/keyless/akeyless-injector-script</sub></small>
