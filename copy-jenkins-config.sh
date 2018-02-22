#!/usr/bin/env bash

JENKINS_MASTER=$(kubectl get pods -n jenkins --selector=component=jenkins-jenkins-master -o json | jq -r '.items[0].metadata.name')

# Go to jenkins dashboard and create pipeline

kubectl cp jenkins/$JENKINS_MASTER:/var/jenkins_home/secrets/hudson.util.Secret jenkins-secrets/
kubectl cp jenkins/$JENKINS_MASTER:/var/jenkins_home/secrets/master.key jenkins-secrets/
kubectl cp jenkins/$JENKINS_MASTER:/var/jenkins_home/users/admin/config.xml jenkins-secrets/
kubectl cp jenkins/$JENKINS_MASTER:/var/jenkins_home/jobs/ jenkins-jobs/

# Create secrets to allow for decrypting stored configuration in the future (e.g. the Github API token)
kubectl create secret generic jenkins-secrets --namespace jenkins --from-file=jenkins-secrets/master.key --from-file=jenkins-secrets/hudson.util.Secret
