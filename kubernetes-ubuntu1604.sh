#!/usr/bin/env bash

SSH_USER=""
JENKINS_IP=""

for i in "$@"
do
case ${i} in
    -SSH_USER=*|--SSH_USER=*)
    SSH_USER="${i#*=}"
    ;;
    -JENKINS_IP=*|--JENKINS_IP=*)
    JENKINS_IP="${i#*=}"
    ;;
esac
done

ssh -o StrictHostKeyChecking=no $SSH_USER@$JENKINS_IP "bash -s" < kubeadm-install.sh

scp -o StrictHostKeyChecking=no $SSH_USER@$JENKINS_IP:/etc/kubernetes/admin.conf $PWD