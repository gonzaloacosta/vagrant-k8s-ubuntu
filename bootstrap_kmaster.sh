#!/bin/bash

# Initialize Kubernetes
echo "[TASK 1] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=172.42.42.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null

# Copy Kube admin config
echo "[TASK 2] Copy kube admin config to Vagrant user .kube directory"
mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# Deploy calico network
# https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart
echo "[TASK 3] Deploy Calico network"
su - vagrant -c "kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml"
su - vagrant -c "kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml"
su - vagrant -c "kubectl taint nodes --all node-role.kubernetes.io/master-"

# Generate Cluster join command
echo "[TASK 4] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh
