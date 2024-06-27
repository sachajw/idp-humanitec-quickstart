# These steps reiterate the commands seen at https://developer.humanitec.com/integration-and-extensions/containerization/kubernetes/#2-configure-gke-cluster-access

# Assign the required role to the service account
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
  --member "serviceAccount:${SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
  --role "roles/container.admin"