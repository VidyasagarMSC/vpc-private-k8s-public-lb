#!/bin/bash
set -e
set -o pipefail


export KUBERNETES_NAMESPACE=$(terraform output -raw kubernetes_namespace)
export BASENAME=$TF_VAR_basename
export MYPROJECT=${BASENAME}-kube-node-app

rm -rf app
if kubectl get deployment $MYPROJECT-deployment ; then
   kubectl delete deployment $MYPROJECT-deployment
fi

ibmcloud logout

echo "#### Destroy all the resources"
# Delete all the resources
cd terraform
terraform destroy -auto-approve