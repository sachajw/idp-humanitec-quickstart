# These steps reiterate the commands seen at https://developer.humanitec.com/platform-orchestrator/security/cloud-accounts/azure/

# Define the naming of the managed identity you are going to create for the Cloud Account
export MANAGED_IDENTITY_NAME=quickstart-azure-cloudaccount

# Define the naming of the new Cloud Account
export CLOUD_ACCOUNT_NAME="Quickstart Azure"
export CLOUD_ACCOUNT_ID=quickstart-azure

# Create a managed identity and capture its client ID
export MANAGED_IDENTITY_CLIENT_ID=$(az identity create \
  --name ${MANAGED_IDENTITY_NAME} \
  --resource-group ${MANAGED_IDENTITY_RESOURCE_GROUP} \
  --query clientId -o tsv)

# Configure a federated credential for the Humanitec OIDC Provider on this managed identity
az identity federated-credential create \
  --name AccessFromHumanitec \
  --identity-name ${MANAGED_IDENTITY_NAME} \
  --resource-group ${MANAGED_IDENTITY_RESOURCE_GROUP} \
  --issuer https://idtoken.humanitec.io \
  --subject ${HUMANITEC_ORG}/${CLOUD_ACCOUNT_ID} \
  --audience api://AzureADTokenExchange

# Create a Cloud Account in the Platform Orchestrator
export AZURE_TENANT_ID=$(az account show --query tenantId -o tsv)

cat << EOF > azure-identity-cloudaccount.yaml
apiVersion: entity.humanitec.io/v1b1
kind: Account
metadata:
  id: ${CLOUD_ACCOUNT_ID}
entity:
  name: ${CLOUD_ACCOUNT_NAME}
  type: azure-identity
  credentials:
    azure_identity_tenant_id: ${AZURE_TENANT_ID}
    azure_identity_client_id: ${MANAGED_IDENTITY_CLIENT_ID}
EOF

# Use the humctl create command to create the Cloud Account
humctl apply -f azure-identity-cloudaccount.yaml
