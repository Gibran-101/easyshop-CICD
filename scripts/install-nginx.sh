#!/bin/bash
# scripts/install-nginx.sh - NGINX Ingress Controller Installation

set -e

STATIC_IP="$1"
RESOURCE_GROUP="$2"
CLUSTER_NAME="$3"

echo " Installing NGINX Ingress Controller..."
echo " Static IP: $STATIC_IP"
echo " Resource Group: $RESOURCE_GROUP"
echo " Cluster: $CLUSTER_NAME"

# Wait for AKS to be fully ready
echo " Waiting 60 seconds for AKS to be fully ready..."
sleep 60

# Get AKS credentials
echo " Getting AKS credentials..."
az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --overwrite-existing

# Add Helm repository
echo " Adding Helm repository..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install NGINX Ingress Controller
echo " Installing NGINX Ingress Controller..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.loadBalancerIP="$STATIC_IP" \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"="$RESOURCE_GROUP" \
  --wait --timeout=10m

# Verify installation
echo " Verifying installation..."
kubectl get svc -n ingress-nginx

echo " NGINX Ingress Controller installed successfully!"