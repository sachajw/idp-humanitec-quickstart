export SUBSCRIPTION_ID=$(az account show --query id -o tsv)

cat << EOF > resdef-azure.yaml
# Connect to an AKS cluster using temporary credentials defined via a Cloud Account
apiVersion: entity.humanitec.io/v1b1
kind: Definition
metadata:
  id: ${CLOUD}-quickstart
entity:
  name: ${CLOUD}-quickstart
  type: k8s-cluster
  # The driver_account references a Cloud Account of type "azure-identity"
  # which needs to be configured for your Organization.
  driver_account: ${CLOUD_ACCOUNT_ID}
  driver_type: humanitec/k8s-cluster-aks
  driver_inputs:
    values:
      name: ${AKS_CLUSTER_NAME}
      resource_group: ${AKS_RESOURCE_GROUP_NAME}
      subscription_id: ${SUBSCRIPTION_ID}
      # Add this exact server_app_id for a cluster using AKS-managed Entra ID integration
      server_app_id: 6dae42f8-4368-4678-94ff-3960e28e3630
  criteria:
  - app_id: quickstart
EOF

echo "AKS Resource Definition prepared at resdef-azure.yaml"