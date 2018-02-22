#!/usr/bin/env bash

# Set the kubectl variable to point to the kubeconfig copied from the ubuntu machine
export KUBECONFIG=admin.conf

# Kubeadm comes with RBAC turned on by default, so creating tiller RBAC account (cluster-admin)
kubectl create -f kubernetes-yaml/rbac-tiller.yaml

helm init --wait --service-account tiller

echo "waiting 10 seconds for helm to initialise"

secs=$((10))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done

# Copy the chart into the current working directory
helm fetch stable/jenkins --version 0.13.2
# Unzip the chart
tar -xvzf jenkins-0.13.2.tgz

# Update the master deployment to apps/v1 to allow helm --wait to work correctly. https://github.com/kubernetes/helm/issues/3173
sed -i "" -E 's#extensions/v1beta1#apps/v1#g' jenkins/templates/jenkins-master-deployment.yaml

# Install nginx ingress with settings for bare metal. See for more detail: https://github.com/kubernetes/charts/tree/master/stable/nginx-ingress
echo "installing nginx-ingress"
helm install --name nginx-ingress --namespace nginx-ingress stable/nginx-ingress --set controller.hostNetwork=true,controller.service.type=NodePort,controller.service.nodePorts.http=32080,controller.service.nodePorts.https=32443,controller.service.externalTrafficPolicy=Local,rbac.create=true

# Install cert-manager with settings for automatically adding tls-acme certs. See for more detail: https://github.com/kubernetes/charts/tree/master/stable/cert-manager
helm install --name cert-manager --namespace cert-manager stable/cert-manager --set ingressShim.extraArgs='{--default-issuer-name=letsencrypt-prod,--default-issuer-kind=ClusterIssuer}'
# Create the default cluster issuer which will be automatically provision certs
kubectl create -f kubernetes-yaml/acme-prod-cluster-issuer.yaml

echo "waiting for helm to install jenkins, takes approximately 120 seconds"
helm install --wait --timeout 300 --name jenkins --namespace jenkins --values jenkins-values-initial.yaml jenkins/