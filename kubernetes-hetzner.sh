#!/usr/bin/env bash

SERVER_NAME=starfish-ci-cd-5
SSH_KEY=7170
SERVER_TYPE=cx41
#hcloud ssh-key create --name Eamon@EamonMacBookPro --public-key-from-file ~/.ssh/id_rsa.pub
hcloud server create --name $SERVER_NAME --image ubuntu-16.04 --type $SERVER_TYPE --ssh-key $SSH_KEY
# grep for IP Address
hcloud server list | grep -E $SERVER_NAME | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"

JENKINS_IP=$(hcloud server list | grep -E $SERVER_NAME | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
echo $JENKINS_IP

sleep 10

ssh root@$JENKINS_IP

ssh -o StrictHostKeyChecking=no root@$JENKINS_IP "bash -s" < kubeadm/kubeadm-install.sh

scp root@$JENKINS_IP:/etc/kubernetes/admin.conf .

KUBECONFIG=admin.conf

kubectl create -f kubernetes-yaml/rbac-tiller.yaml

helm init --service-account tiller


