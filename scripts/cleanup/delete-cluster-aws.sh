# Delete the cluster
eksctl delete cluster \
  --name ${EKS_QUICKSTART_CLUSTER_NAME} \
  --region ${EKS_QUICKSTART_REGION}

aws iam detach-role-policy \
  --role-name ${EBS_CSI_DRIVER_ROLE_NAME} \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --region ${EKS_QUICKSTART_REGION}


aws iam delete-role \
  --role-name ${EBS_CSI_DRIVER_ROLE_NAME} \
  --region ${EKS_QUICKSTART_REGION}