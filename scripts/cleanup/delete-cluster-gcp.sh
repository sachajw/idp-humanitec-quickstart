# Delete the cluster
gcloud container clusters delete ${GKE_QUICKSTART_CLUSTER_NAME} \
    --region=${GKE_QUICKSTART_REGION} \
    --project=${GCP_PROJECT_ID} \
    --quiet
