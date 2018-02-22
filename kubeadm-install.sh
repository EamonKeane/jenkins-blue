# Commands taken from: https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
apt-get update
apt-get install -y docker.io
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

kubeadm init

export KUBECONFIG=/etc/kubernetes/admin.conf

# Untainting the master so that the master node can be used for jenkins jobs
kubectl taint nodes --all node-role.kubernetes.io/master-

# Adding the calico CNI add-on for pod networking
kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml