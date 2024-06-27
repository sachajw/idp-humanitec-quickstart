set -eo pipefail

export CURRENT_CONTEXT=$(kubectl config current-context)
export GENERIC_CLUSTER_NAME=$(kubectl config view | yq '.contexts[] | select(.name == "'${CURRENT_CONTEXT}'") | .context.cluster')
export GENERIC_CLUSTER_USER=$(kubectl config view | yq '.contexts[] | select(.name == "'${CURRENT_CONTEXT}'") | .context.user')

echo "Reading credentials for user ${GENERIC_CLUSTER_USER} on cluster ${GENERIC_CLUSTER_NAME} from kubeconfig.."

export GENERIC_CLUSTER_DATA=$(kubectl config view --raw | yq '.clusters[] | select(.name == "'${GENERIC_CLUSTER_NAME}'") | .cluster')

if [[ -z "$GENERIC_CLUSTER_DATA" ]]; then
  echo "⚡Could not retrieve cluster data from current context"
  return
fi

export GENERIC_CLUSTER_CREDENTIALS=$(kubectl config view --raw | yq '.users[] | select(.name == "'${GENERIC_CLUSTER_USER}'") | .user')

if [[ -z "$GENERIC_CLUSTER_CREDENTIALS" ]]; then
  echo "⚡Could not retrieve cluster credentials from current context"
  return
fi

cat << EOF > resdef-generic.yaml
apiVersion: entity.humanitec.io/v1b1
kind: Definition
metadata:
  id: ${CLOUD}-quickstart
entity:
  name: ${CLOUD}-quickstart
  type: k8s-cluster
  driver_type: humanitec/k8s-cluster
  driver_inputs:
    values:
      cluster_data:
$(echo "${GENERIC_CLUSTER_DATA}" | sed 's/^/        /')
    secrets:
      credentials:
$(echo "${GENERIC_CLUSTER_CREDENTIALS}" | sed 's/^/        /')
  criteria:
  - app_id: quickstart
EOF

echo "Generic cluster Resource Definition prepared at resdef-generic.yaml"