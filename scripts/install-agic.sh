#!/bin/bash
# Simple AGIC installation using Helm

set -e

echo "Installing AGIC via Helm..."

# Get values from Terraform
cd terraform
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)
APP_GATEWAY_NAME="${{ secrets.TF_PROJECT_NAME }}-app-gateway"
cd ..

# Install AGIC using Helm
helm repo add application-gateway-kubernetes-ingress https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/
helm repo update

helm install ingress-azure application-gateway-kubernetes-ingress/ingress-azure \
     --namespace agic-system \
     --create-namespace \
     --set appgw.subscriptionId=$SUBSCRIPTION_ID \
     --set appgw.resourceGroup=$RESOURCE_GROUP \
     --set appgw.name=$APP_GATEWAY_NAME \
     --set appgw.usePrivateIP=false \
     --set kubernetes.watchNamespace=easyshop \
     --set armAuth.type=workloadIdentity

echo "AGIC installed successfully!"