#!/usr/bin/env bash

SERVER_NAME=starfish-ci-cd-5
SSH_KEY=7170
SERVER_TYPE=cx41

for i in "$@"
do
case ${i} in
    -SERVER_NAME=*|--SERVER_NAME=*)
    SERVER_NAME="${i#*=}"
    ;;
    -SERVER_TYPE=*|--SERVER_TYPE=*)
    SERVER_TYPE="${i#*=}"
    ;;
    -SSH_KEY=*|--SSH_KEY=*)
    SSH_KEY="${i#*=}"
    ;;
esac
done


hcloud server create --name $SERVER_NAME --image ubuntu-16.04 --type $SERVER_TYPE --ssh-key $SSH_KEY
# grep for IP Address
hcloud server list | grep -E $SERVER_NAME | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b"

export JENKINS_IP=$(hcloud server list | grep -E $SERVER_NAME | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

echo "waiting 60 seconds for hetzner to release lock on /var/lib/dpkg/lock due to fresh VM creation"

secs=$((60))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done

ssh -o StrictHostKeyChecking=no root@$JENKINS_IP "bash -s" < kubeadm-install.sh

scp -o StrictHostKeyChecking=no root@$JENKINS_IP:/etc/kubernetes/admin.conf $PWD


