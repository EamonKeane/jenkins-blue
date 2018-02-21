#!/usr/bin/env bash

# Add ip address to DNS record
#use blue ocean to create job

export JENKINS_URL=cicd4.squareroute.io

export KUBECONFIG=admin.conf

kubectl create -f kubernetes-yaml/rbac-tiller.yaml

helm init --service-account tiller

helm fetch stable/jenkins --version 0.13.2
tar -xvzf jenkins-0.13.2.tgz

helm install --name nginx-ingress --namespace nginx-ingress stable/nginx-ingress --set controller.hostNetwork=true,controller.service.type=NodePort,controller.service.nodePorts.http=32080,controller.service.nodePorts.https=32443,controller.service.externalTrafficPolicy=Local,rbac.create=true

helm install --name cert-manager --namespace cert-manager stable/cert-manager --set ingressShim.extraArgs='{--default-issuer-name=letsencrypt-prod,--default-issuer-kind=ClusterIssuer}'
kubectl create -f kubernetes-yaml/acme-prod-cluster-issuer.yaml

helm install --name jenkins --namespace jenkins --values jenkins-values-initial.yaml jenkins/

# go to
JENKINS_URL=https://JENKINS_URL
kubectl get secret jenkins-jenkins --namespace jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 --decode | pbcopy

