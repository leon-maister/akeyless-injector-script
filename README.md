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

### 🔍 Verify Installation
```bash
kubectl get all -n akeyless
```

## 🛠️ Usage Examples

### 1. Secret Injection (basic scenario)
- Deploy using `akeyless/enabled: "true"` annotation.
```bash
kubectl apply -f env.yaml
```
- Check the logs:
```bash
kubectl logs -l app=hello-secrets
```

### 2. Inject DB secret (complicated scenario)
#### 🏗️ Preparation
**Install PostgreSQL:**
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install my-postgres bitnami/postgresql --set auth.postgresPassword=postgrespass --set auth.username=myuser --set auth.password=mypassword --set auth.database=mydb
```

#### 🧪 Demo Flow (Manual Validation)
1. **Port Forward**: `kubectl port-forward svc/my-postgres-postgresql 5432:5432 > /dev/null 2>&1 &`
2. **Manage Demo User**:
   - Check if exists: `PGPASSWORD='mypassword' psql -h localhost -U myuser -d mydb -c "\du"`
   - Remove if needed: `PGPASSWORD='mypassword' psql -h localhost -U myuser -d mydb -c "DROP ROLE demouser;"`
   - Create for demo: `PGPASSWORD='mypassword' psql -h localhost -U myuser -d mydb -c "CREATE ROLE demouser WITH LOGIN SUPERUSER PASSWORD 'qwertyQWERTY1@';"`
3. **Populate Secret**: 
   ```bash
   akeyless create-secret --name /K8s/InjectorDemo/DB-Secret --value '{"user_name":"demouser","password":"qwertyQWERTY1@"}' --json
   ```
4. **Apply & Verify Connection**:
   - Check `access_db.yaml` for correct path and `akeyless/enabled: "true"` annotation.
   - Deploy/Force-Replace:
     ```bash
     kubectl replace --force -f access_db.yaml
     ```
   - **Check logs (using the correct plural label)**:
     ```bash
     kubectl logs -l app=hello-db-secrets
     ```
5. **Cleanup**: `pkill -f "kubectl port-forward svc/my-postgres-postgresql"`

---
**Maintained by**: [leon-maister](https://github.com/leon-maister)
