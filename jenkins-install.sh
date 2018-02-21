#!/usr/bin/env bash


kubectl create -f kubernetes-yaml/jenkins-pv.yaml
kubectl create -f kubernetes-yaml/jenkins-pvc.yaml


kubectl get secret jenkins-jenkins --namespace jenkins -o jsonpath='{.data.jenkins-admin-password}' | base64 --decode | pbcopy

JENKINS_MASTER=$(kubectl get po -n jenkins --namespace jenkins -o json | jq -r '.items[0].metadata.name')

# Go to jenkins dashboard and create pipeline


kubectl cp $JENKINS_MASTER:/var/jenkins_home/secrets/hudson.util.Secret jenkins-secrets/
kubectl cp $JENKINS_MASTER:/var/jenkins_home/secrets/master.key jenkins-secrets/
kubectl cp $JENKINS_MASTER:/var/jenkins_home/users/admin/config.xml jenkins-secrets/
kubectl cp $JENKINS_MASTER:/var/jenkins_home/jobs/ jenkins-jobs/


kubectl create secret generic jenkins-secrets --namespace jenkins --from-file=jenkins-secrets/master.key --from-file=jenkins-secrets/hudson.util.Secret
kubectl create secret generic admin-user-config --namespace jenkins --from-file=jenkins-secrets/config.xml

#Copy and paste blue_ocean_credentials.xml into the config.yaml
#Add these to the config.sh
    mkdir -p /var/jenkins_home/users/admin/;
    cp -n /var/jenkins_config/blue_ocean_credentials.xml /var/jenkins_home/users/admin/config.xml;

helm del --purge jenkins

helm install --name jenkins --namespace jenkins --values jenkins-values.yaml --values jenkins-jobs.yaml jenkins/

# Copy jenkins-job yaml to jenkins-jobs.yaml

# create the github webhook
github-webhook/create-github-webhook.sh --auth_token="" --service_url="https://cicd4.squareroute.io" --organisation=EamonKeane --repository=croc-hunter
