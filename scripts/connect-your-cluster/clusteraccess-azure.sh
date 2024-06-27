# These steps reiterate the commands seen at https://developer.humanitec.com/integration-and-extensions/containerization/kubernetes/#2-configure-aks-cluster-access

export AKS_CLUSTER_ID=$(az aks show -n ${AKS_CLUSTER_NAME} -g ${AKS_RESOURCE_GROUP_NAME} --query id -o tsv)

# Assign required roles for cluster access with AKS-managed Microsoft Entra integration
export MANAGED_IDENTITY_PRINCIPAL_ID=$(az identity show \
  -n ${MANAGED_IDENTITY_NAME} -g ${MANAGED_IDENTITY_RESOURCE_GROUP} \
  --query principalId -o tsv)

az role assignment create \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope ${AKS_CLUSTER_ID} \
  --assignee ${MANAGED_IDENTITY_PRINCIPAL_ID}

az role assignment create \
  --role "Azure Kubernetes Service RBAC Cluster Admin" \
  --scope ${AKS_CLUSTER_ID} \
  --assignee ${MANAGED_IDENTITY_PRINCIPAL_ID}