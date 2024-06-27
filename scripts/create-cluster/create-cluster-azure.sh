#####################################
# Set these variables before starting
#####################################
export AKS_QUICKSTART_REGION= # set your target region, e.g. westeurope

##################################
# Do not change anything from here
##################################
export AKS_RANDOM=$(openssl rand -hex 3)
export AKS_QUICKSTART_RESOURCE_GROUP_NAME=Quickstart-AKS-${AKS_RANDOM}
export AKS_QUICKSTART_CLUSTER_NAME=Quickstart-AKS-${AKS_RANDOM}

# Create a Resource Group
az group create --name ${AKS_QUICKSTART_RESOURCE_GROUP_NAME} --location ${AKS_QUICKSTART_REGION}

# Create the AKS cluster
az aks create \
  --resource-group ${AKS_QUICKSTART_RESOURCE_GROUP_NAME} \
  --name ${AKS_QUICKSTART_CLUSTER_NAME} \
  --node-count 2 \
  --enable-aad \
  --enable-azure-rbac \
  --generate-ssh-keys \
  --yes

# Add cluster credentials to kubeconfig
az aks get-credentials \
  --resource-group ${AKS_QUICKSTART_RESOURCE_GROUP_NAME} \
  --name ${AKS_QUICKSTART_CLUSTER_NAME} \
  --overwrite-existing

# Add role assignments for current user
export AZ_SIGNED_IN_USER_ID=$(az ad signed-in-user show --query id -o tsv)
export AKS_QUICKSTART_CLUSTER_ID=$(az aks show -n ${AKS_QUICKSTART_CLUSTER_NAME} -g ${AKS_QUICKSTART_RESOURCE_GROUP_NAME} --query id -o tsv)

az role assignment create \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope ${AKS_QUICKSTART_CLUSTER_ID} \
  --assignee ${AZ_SIGNED_IN_USER_ID}

az role assignment create \
  --role "Azure Kubernetes Service RBAC Cluster Admin" \
  --scope ${AKS_QUICKSTART_CLUSTER_ID} \
  --assignee ${AZ_SIGNED_IN_USER_ID}

# Results output
echo AKS cluster "${AKS_QUICKSTART_CLUSTER_NAME}" created in Resource Group "${AKS_QUICKSTART_RESOURCE_GROUP_NAME}"
