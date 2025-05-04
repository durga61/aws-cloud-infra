#!/bin/bash

set -e

# Create namespaces
kubectl create ns external-secrets || true
kubectl create ns reloader || true
kubectl create ns demo || true

# Install External Secrets Operator
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm upgrade --install external-secrets external-secrets/external-secrets -n external-secrets -f values/external-secrets-values.yaml


# Install Reloader
helm repo add stakater https://stakater.github.io/stakater-charts
helm repo update
helm upgrade --install reloader stakater/reloader -n reloader -f values/reloader-values.yaml

# Apply manifests
kubectl apply -f manifests/external-secrets
kubectl apply -f manifests/sample-app
