#####################################
# Set these variables before starting
#####################################
# Set your target region, e.g. us-east-1
export EKS_QUICKSTART_REGION=

##################################
# Do not change anything from here
##################################
export EKS_RANDOM=$(openssl rand -hex 3)
export EKS_QUICKSTART_CLUSTER_NAME=quickstart-EKS-${EKS_RANDOM}

# Error out if EKS_QUICKSTART_REGION not set
if [[ -z "$EKS_QUICKSTART_REGION" ]]; then
    echo "Please specify EKS_QUICKSTART_REGION to proceed" 1>&2
    exit 1
fi

# Create the EKS cluster
eksctl create cluster \
  --name ${EKS_QUICKSTART_CLUSTER_NAME} \
  --region ${EKS_QUICKSTART_REGION} \
  --with-oidc

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

# Prepare storage for PostgreSQL example
# Set default storage class
kubectl annotate storageclass gp2 storageclass.kubernetes.io/is-default-class=true

# Create IAM role for CSI Driver. See https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
export EBS_CSI_DRIVER_ROLE_NAME=AmazonEKS_EBS_CSI_DriverRole-${EKS_RANDOM}

export EKS_OIDC_ISSUER=$(aws eks describe-cluster \
  --name ${EKS_QUICKSTART_CLUSTER_NAME} \
  --region ${EKS_QUICKSTART_REGION} \
  --query "cluster.identity.oidc.issuer" \
  --output text | sed -E 's/^\s*.*:\/\///g')

cat <<EOF > aws-ebs-csi-driver-trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${EKS_OIDC_ISSUER}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${EKS_OIDC_ISSUER}:aud": "sts.amazonaws.com",
          "${EKS_OIDC_ISSUER}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF

aws iam create-role \
  --role-name ${EBS_CSI_DRIVER_ROLE_NAME} \
  --region ${EKS_QUICKSTART_REGION} \
  --assume-role-policy-document file://"aws-ebs-csi-driver-trust-policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --region ${EKS_QUICKSTART_REGION} \
  --role-name ${EBS_CSI_DRIVER_ROLE_NAME}

# Create EBS CSI Driver addon
eksctl create addon --name aws-ebs-csi-driver \
  --cluster ${EKS_QUICKSTART_CLUSTER_NAME} \
  --service-account-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/${EBS_CSI_DRIVER_ROLE_NAME} \
  --region ${EKS_QUICKSTART_REGION} \
  --force

# Add cluster credentials to kubeconfig: done automatically by eksctl

# Results output
echo EKS cluster "${EKS_QUICKSTART_CLUSTER_NAME}" created in region "${EKS_QUICKSTART_REGION}"
echo Cluster ARN: $(eksctl get cluster -n ${EKS_QUICKSTART_CLUSTER_NAME} -r ${EKS_QUICKSTART_REGION} -o json | jq .[0].Arn | tr -d "\"")
