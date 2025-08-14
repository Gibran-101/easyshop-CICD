#!/bin/bash
set -e

STATIC_IP=$1
RESOURCE_GROUP=$2
CLUSTER_NAME=$3

echo "🚀 Installing Traefik Ingress Controller (faster than NGINX)..."
echo "Static IP: $STATIC_IP"
echo "Resource Group: $RESOURCE_GROUP"
echo "Cluster: $CLUSTER_NAME"

# Wait for AKS to be ready
echo "⏳ Waiting 30 seconds for AKS to be fully ready..."
sleep 30

# Login to Azure using service principal (for GitHub Actions)
if [ ! -z "$ARM_CLIENT_ID" ] && [ ! -z "$ARM_CLIENT_SECRET" ] && [ ! -z "$ARM_TENANT_ID" ]; then
    echo "🔐 Logging in with service principal..."
    az login --service-principal \
        --username "$ARM_CLIENT_ID" \
        --password "$ARM_CLIENT_SECRET" \
        --tenant "$ARM_TENANT_ID"
    
    if [ ! -z "$ARM_SUBSCRIPTION_ID" ]; then
        az account set --subscription "$ARM_SUBSCRIPTION_ID"
    fi
else
    echo "ℹ️  Using existing Azure authentication..."
fi

# Get AKS credentials
echo "🔑 Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing

# Test kubectl connection
echo "🔗 Testing kubectl connection..."
kubectl get nodes

# Add Traefik Helm repository
echo "📦 Adding Traefik Helm repository..."
helm repo add traefik https://traefik.github.io/charts
helm repo update

# Install Traefik with Azure LoadBalancer
echo "🚀 Installing Traefik Ingress Controller..."
helm upgrade --install traefik traefik/traefik \
    --namespace traefik-system \
    --create-namespace \
    --set service.type=LoadBalancer \
    --set service.spec.loadBalancerIP=$STATIC_IP \
    --set service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"=$RESOURCE_GROUP \
    --set service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"="/ping" \
    --set ports.web.port=80 \
    --set ports.websecure.port=443 \
    --set globalArguments[0]="--global.checknewversion=false" \
    --set globalArguments[1]="--global.sendanonymoususage=false" \
    --wait \
    --timeout=5m

echo "✅ Traefik installation completed successfully!"

# Verify installation
echo "🔍 Verifying Traefik installation..."
kubectl get svc -n traefik-system
kubectl get pods -n traefik-system

# Show LoadBalancer IP
echo "🌐 LoadBalancer details:"
kubectl get svc traefik -n traefik-system -o wide

echo "🎉 Traefik is ready! Much faster than NGINX! 🚀"