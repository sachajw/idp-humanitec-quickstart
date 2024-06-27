# These steps reiterate the commands seen at https://developer.humanitec.com/integration-and-extensions/containerization/kubernetes/#2-configure-eks-cluster-access

# Prepare an IAM policy defining the required permissions
cat <<EOF > role-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeNodegroup",
        "eks:ListNodegroups",
        "eks:AccessKubernetesApi",
        "eks:DescribeCluster",
        "eks:ListClusters"
      ],
      "Resource": "${EKS_CLUSTER_ARN}"
    }
  ]
}
EOF

# Define the name of the new IAM policy:
export POLICY_NAME=Humanitec_Access_EKS_Quickstart

# Create the IAM policy and capture its ARN
export POLICY_ARN=$(aws iam create-policy \
  --policy-name ${POLICY_NAME} \
  --policy-document file://role-policy.json \
  | jq .Policy.Arn | tr -d "\"")
echo ${POLICY_ARN}

# Read the region from the cluster and use the same region throughout
export EKS_CLUSTER_REGION=$(echo ${EKS_CLUSTER_ARN} | cut -d':' -f4)

# Attach the IAM policy to the IAM role used in the Cloud Account
aws iam attach-role-policy \
  --role-name ${ROLE_NAME} \
  --policy-arn ${POLICY_ARN} \
  --region ${EKS_CLUSTER_REGION}

# Create an access entry of type STANDARD for the role
export EKS_CLUSTER_NAME=$(echo ${EKS_CLUSTER_ARN} | cut -d'/' -f2)

aws eks create-access-entry \
  --cluster-name ${EKS_CLUSTER_NAME} \
  --region ${EKS_CLUSTER_REGION} \
  --principal-arn ${ROLE_ARN} \
  --type STANDARD

# Associate an access policy
aws eks associate-access-policy \
  --cluster-name ${EKS_CLUSTER_NAME} \
  --region ${EKS_CLUSTER_REGION} \
  --principal-arn ${ROLE_ARN} \
  --policy-arn "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy" \
  --access-scope "type=cluster"
