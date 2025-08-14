#!/bin/bash
set -e

STATIC_IP=$1
RESOURCE_GROUP=$2
CLUSTER_NAME=$3

echo "Installing NGINX Ingress Controller..."
echo "Static IP: $STATIC_IP"
echo "Resource Group: $RESOURCE_GROUP"
echo "Cluster: $CLUSTER_NAME"

# Wait for AKS to be fully ready
echo "Waiting 60 seconds for AKS to be fully ready..."
sleep 60

# Login to Azure using service principal (for GitHub Actions)
if [ ! -z "$ARM_CLIENT_ID" ] && [ ! -z "$ARM_CLIENT_SECRET" ] && [ ! -z "$ARM_TENANT_ID" ]; then
    echo "Logging in with service principal for GitHub Actions..."
    az login --service-principal \
        --username "$ARM_CLIENT_ID" \
        --password "$ARM_CLIENT_SECRET" \
        --tenant "$ARM_TENANT_ID"
    
    # Set the subscription
    if [ ! -z "$ARM_SUBSCRIPTION_ID" ]; then
        az account set --subscription "$ARM_SUBSCRIPTION_ID"
    fi
else
    echo "No service principal credentials found, assuming already logged in..."
fi

# Get AKS credentials
echo "Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing

# Check if kubectl is working
echo "Testing kubectl connection..."
kubectl get nodes

# Install NGINX Ingress Controller
echo "Installing NGINX Ingress Controller via Helm..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install or upgrade NGINX Ingress
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --create-namespace \
    --set controller.service.loadBalancerIP=$STATIC_IP \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"=$RESOURCE_GROUP \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"="/healthz" \
    --set controller.service.type=LoadBalancer \
    --wait \
    --timeout=10m

echo "NGINX Ingress Controller installation completed!"

# Verify the installation
echo "Verifying installation..."
kubectl get svc -n ingress-nginx
kubectl get pods -n ingress-nginx

echo "Done!"