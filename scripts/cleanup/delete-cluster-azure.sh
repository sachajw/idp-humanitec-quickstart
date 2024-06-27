# Delete the Resource Group with the cluster in it
az group delete \
  --name ${AKS_QUICKSTART_RESOURCE_GROUP_NAME} \
  --yes --no-wait