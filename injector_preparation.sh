#!/bin/bash

set -e

# --- Variables ---
SECRET_NAME="/K8s/Citi_of_M/my_k8s_secret"
SECRET_VALUE="superSecret123!"

ROLE_NAME="/FullAccess"
AUTH_METHOD_NAME="/K8s/k8s-auth-leon-test"

echo "--- Creating Akeyless secret ---"

akeyless create-secret \
  --name "$SECRET_NAME" \
  --value "$SECRET_VALUE"

echo "Secret created successfully"

# --- Installing Akeyless Injector using Helm ---

helm repo add akeyless https://akeylesslabs.github.io/helm-charts --force-update
helm repo update

helm upgrade --install akeyless-injector akeyless/akeyless-injector \
  --namespace akeyless \
  --create-namespace