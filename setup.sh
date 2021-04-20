#!/bin/bash
set -e
set -o pipefail

# Environment variables required for the script
export IBMCLOUD_API_KEY=$TF_VAR_ibmcloud_api_key
export BASENAME=$TF_VAR_basename
export RESOURCE_GROUP_NAME=$(terraform output -raw resource_group_name)
export MYPROJECT=${BASENAME}-kube-node-app
export MYREGISTRY=$(ibmcloud cr info | grep "Container Registry" | awk 'FNR==1 {print $3}')
export MYNAMESPACE=$(terraform output -raw registry_namespace)
export MYCLUSTER=$(terraform output -raw cluster_name)
export KUBERNETES_NAMESPACE=$(terraform output -raw kubernetes_namespace)
export SUBNET_ID=$(terraform output -raw loadbalancer_subnet_id)

echo "#### Log into IBM Cloud..."
ibmcloud login --apikey $IBMCLOUD_API_KEY -r $(terraform output -raw region) -g $(terraform output -raw resource_group_id)

echo "#### Step: Download the starter application"

#echo "MYPROJECT: $MYPROJECT"
#export RG_VALUE=$(echo -e "1\n4\n3\n$MYPROJECT" | ibmcloud dev create | grep $RESOURCE_GROUP_NAME | awk '{print $1; exit 0}')
#export RG_VALUE_NO_DOT=$(echo "${RG_VALUE//./}")
#echo -e "1\n4\n3\n$MYPROJECT\n$RG_VALUE_NO_DOT\nn\n3\n1" | ibmcloud dev create

rm -rf app
mkdir app

#curl -L https://github.com/IBM-Cloud/kubernetes-node-app/archive/refs/heads/master.zip -o app/kube-node-app.zip

curl -L https://github.com/IBM/container-service-getting-started-wt/archive/refs/heads/master.zip -o app/kube-node-app.zip
unzip -q app/kube-node-app.zip -d app

echo "#### Step: Deploy application to a cluster using helm chart"
echo ">>> Prepare the access to Container Registry..."
ibmcloud cr login 

echo "#### Step: Build and push the container image..."
cd "app/container-service-getting-started-wt-master/Lab 1"

#docker build -t $MYREGISTRY/$MYNAMESPACE/$MYPROJECT:v1.0.0 .
#docker push $MYREGISTRY/$MYNAMESPACE/$MYPROJECT:v1.0.0

ibmcloud cr build --tag $MYREGISTRY/$MYNAMESPACE/$MYPROJECT:v1.0.0 . || true

echo "#### Step: Deploy the application..."
ibmcloud ks cluster config --cluster $MYCLUSTER

if [[ "$KUBERNETES_NAMESPACE" != "default" ]];  then 
   kubectl get secret all-icr-io -n default -o yaml | sed "s/default/$KUBERNETES_NAMESPACE/g" | kubectl create -n $KUBERNETES_NAMESPACE -f - || true
   kubectl patch -n $KUBERNETES_NAMESPACE serviceaccount/default -p '{"imagePullSecrets":[{"name": "all-icr-io"}]}' || true
fi

#cd chart/kubernetesnodeapp
# Update the app name in the Helm chart 
#sed -i.bak -e "s/kubernetesnodeapp/$MYPROJECT/g" Chart.yaml
#helm install $MYPROJECT --namespace $KUBERNETES_NAMESPACE . --set image.repository=$MYREGISTRY/$MYNAMESPACE/$MYPROJECT || true

cd ../../../

kubectl create deployment $MYPROJECT-deployment --image=$MYREGISTRY/$MYNAMESPACE/$MYPROJECT:v1.0.0 || true

cat loadbalancer-template.yaml | \
        MYPROJECT=$MYPROJECT \
        SUBNET_ID=$SUBNET_ID \
        KUBERNETES_NAMESPACE=$KUBERNETES_NAMESPACE \
        envsubst > loadbalancer.yaml

kubectl apply -f loadbalancer.yaml

#sleep 20

#export CURL_HTTP_CODE=$(curl -sL -w "%{http_code}\\n" "https://$MYPROJECT.$INGRESS_SUBDOMAIN/" -o /dev/null)
#echo "CURL HTTP CODE: $CURL_HTTP_CODE"
#if [ $CURL_HTTP_CODE == "200" ]; then 
#    echo "The application is successfully running at https://$MYPROJECT.$INGRESS_SUBDOMAIN/"
#fi