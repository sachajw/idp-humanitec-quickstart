export GKE_CLUSTER_ZONE=$(gcloud container clusters describe ${GKE_CLUSTER_NAME} --region ${GKE_CLUSTER_REGION} --format="get(zone)")

cat << EOF > resdef-gcp.yaml
# Connect to a GKE cluster using temporary credentials defined via a Cloud Account
apiVersion: entity.humanitec.io/v1b1
kind: Definition
metadata:
  id: ${CLOUD}-quickstart
entity:
  name: ${CLOUD}-quickstart
  type: k8s-cluster
  # The driver_account references a Cloud Account of type "gcp-identity"
  # which needs to be configured for your Organization.
  driver_account: ${CLOUD_ACCOUNT_ID}
  driver_type: humanitec/k8s-cluster-gke
  driver_inputs:
    values:
      name: ${GKE_CLUSTER_NAME}
      zone: ${GKE_CLUSTER_ZONE}
      project_id: ${GCP_PROJECT_ID}
  criteria:
  - app_id: quickstart
EOF

echo "GKE Resource Definition prepared at resdef-gcp.yaml"