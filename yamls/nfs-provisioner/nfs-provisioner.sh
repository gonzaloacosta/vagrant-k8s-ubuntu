helm repo add nfs-subdir-external-provisioner \
  https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm install nfs-provisioner \
  nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --set nfs.server=172.42.42.100 \
  --set nfs.path=/srv/nfs4/kubedata \
  --set storageClass.name=nfs-provisioner
