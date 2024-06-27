# These steps reiterate the commands seen at https://developer.humanitec.com/platform-orchestrator/security/cloud-accounts/gcp/

export GCP_PROJECT_ID=$(gcloud config get project)
# Create a new WIF pool name. Names cannot be reused for 30 days even after deleting a pool
# See https://cloud.google.com/iam/docs/manage-workload-identity-pools-providers#delete-pool
export WIF_POOL_NAME=humanitec-quickstart-$(openssl rand -hex 3)

# Create a workload identity pool
gcloud iam workload-identity-pools create ${WIF_POOL_NAME} \
--location="global" \
--project ${GCP_PROJECT_ID}

# Create a new OIDC workload identity pool provider in that pool
gcloud iam workload-identity-pools providers create-oidc humanitec-wif \
    --location="global" \
    --workload-identity-pool="${WIF_POOL_NAME}"  \
    --issuer-uri="https://idtoken.humanitec.io" \
    --attribute-mapping="google.subject=assertion.sub" \
    --project=${GCP_PROJECT_ID}

# Create a GCP service account to be used by the Humanitec Cloud Account
export SERVICE_ACCOUNT_NAME=quickstart-gcp-cloud-account
gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} \
    --description="Used by Humanitec Platform Orchestrator Cloud Account" \
    --display-name=${SERVICE_ACCOUNT_NAME} \
    --project=${GCP_PROJECT_ID}

# Define the naming of the new Cloud Account
export CLOUD_ACCOUNT_NAME="Quickstart GCP"
export CLOUD_ACCOUNT_ID=quickstart-gcp

#Add this policy binding between the service account and workload identity federation principal to enable it for service account impersonation
export GCP_PROJECT_NUMBER=$(gcloud projects describe ${GCP_PROJECT_ID} --format='get(projectNumber)')

gcloud iam service-accounts add-iam-policy-binding \
    ${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com \
    --member=principal://iam.googleapis.com/projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL_NAME}/subject/${HUMANITEC_ORG}/${CLOUD_ACCOUNT_ID} \
    --role=roles/iam.workloadIdentityUser \
    --format=json

# Create a file defining the Cloud Account you want to create
cat << EOF > gcp-identity-cloudaccount.yaml
apiVersion: entity.humanitec.io/v1b1
kind: Account
metadata:
  id: ${CLOUD_ACCOUNT_ID}
entity:
  name: ${CLOUD_ACCOUNT_NAME}
  type: gcp-identity
  credentials:
    gcp_service_account: ${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com
    gcp_audience: //iam.googleapis.com/projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${WIF_POOL_NAME}/providers/humanitec-wif
EOF

# Use the humctl create command to create the Cloud Account in the Organization defined by your configured context
humctl apply -f gcp-identity-cloudaccount.yaml
