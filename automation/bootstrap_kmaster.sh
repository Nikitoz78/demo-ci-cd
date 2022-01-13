#!/bin/bash

# Initialize Kubernetes
echo "[TASK 1] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=172.42.42.100 --pod-network-cidr=172.16.0.0/16 >> /root/kubeinit.log 2>/dev/null
# install the network as in Calico (Flannel)

# Copy Kube admin config
echo "[TASK 2] Copy kube admin config to Vagrant user .kube directory"
mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

# Deploy Calico (Flannel) network
echo "[TASK 3] Deploy Calico (Flannel) network"
# su - vagrant -c "kubectl create -f /vagrant/kube-flannel.yml"
su - vagrant -c "kubectl create -f /vagrant/calico.yaml"

# Generate Cluster join command
echo "[TASK 4] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh

# Сreate nfs-provisioner
echo "[TASK 5] Сreate nfs-provisioner"
su - vagrant -c "kubectl create -f /vagrant/nfs-provisioner/rbac.yaml"
su - vagrant -c "kubectl create -f /vagrant/nfs-provisioner/default-sc.yaml"
su - vagrant -c "kubectl create -f /vagrant/nfs-provisioner/deployment.yaml"

# Install nfs-utils, mount storage and create jenkins dir
echo "[TASK 6] Create Jenkins dir"
yum install -y -q nfs-utils nfs-utils-lib net-tools > /dev/null 2>&1
systemctl enable rpcbind >/dev/null 2>&1
systemctl enable nfs-server >/dev/null 2>&1
systemctl enable nfs-lock >/dev/null 2>&1
systemctl enable nfs-idmap >/dev/null 2>&1
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
mkdir /nfs
mount -t nfs 172.42.42.200:/srv/nfs/kubedata /nfs
mount | grep kubedata
mkdir /nfs/jenkins
chown -R 1000:1000 /nfs/jenkins
umount /nfs
rm -rf /nfs -r

# Mount Docker Registry
echo "[TASK 7] Mount Docker Registry"
cat >/etc/docker/daemon.json<<EOF
{
  "group": "dockerroot",
  "insecure-registries":["172.42.42.200:5000"]
}
EOF
usermod -aG dockerroot vagrant
systemctl restart docker
chmod 666 /var/run/docker.sock

# Download & Install HELM
echo "[TASK 8] Download & Install HELM"
wget https://get.helm.sh/helm-v3.5.4-linux-amd64.tar.gz >/dev/null 2>&1
tar zxf helm*gz
cp linux-amd64/helm /usr/local/bin/
su - vagrant -c "helm repo add stable https://charts.helm.sh/stable"
su - vagrant -c "helm repo add jenkinsci https://charts.jenkins.io"
su - vagrant -c "helm repo update"

# jnlp-slave-alpine-docker
echo "[TASK 9] Jenkins Docker agent"
docker build -t 172.42.42.200:5000/jnlp-slave-alpine-docker:1.0 /vagrant/jnlp-slave-alpine-docker/ >/dev/null 2>&1
docker push 172.42.42.200:5000/jnlp-slave-alpine-docker:1.0 >/dev/null 2>&1
