#####################################
# Set these variables before starting
#####################################
export GKE_QUICKSTART_REGION= # set your target region, e.g. europe-west3

##################################
# Do not change anything from here
##################################
export GKE_RANDOM=$(openssl rand -hex 3)
export GKE_QUICKSTART_CLUSTER_NAME=quickstart-gke-${GKE_RANDOM}
export GCP_PROJECT_ID=$(gcloud config get project)

# Create the GKE cluster
gcloud container clusters create-auto ${GKE_QUICKSTART_CLUSTER_NAME} \
    --region=${GKE_QUICKSTART_REGION} \
    --project=${GCP_PROJECT_ID}

# Add cluster credentials to kubeconfig
gcloud container clusters get-credentials ${GKE_QUICKSTART_CLUSTER_NAME} \
    --region=${GKE_QUICKSTART_REGION} \
    --project=${GCP_PROJECT_ID}

# Results output
echo GKE cluster "${GKE_QUICKSTART_CLUSTER_NAME}" created in location "${GKE_QUICKSTART_REGION}"
