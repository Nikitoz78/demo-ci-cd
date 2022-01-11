#!/bin/bash

# Join worker nodes to the Kubernetes cluster
echo "[TASK 1] Join node to Kubernetes Cluster"
yum install -q -y sshpass >/dev/null 2>&1
sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster.example.com:/joincluster.sh /joincluster.sh 2>/dev/null
bash /joincluster.sh >/dev/null 2>&1

# Add vagrant user in dockerroot group
echo "[TASK 2] Add vagrant user in dockerroot group"
cat >/etc/docker/daemon.json<<EOF
{
  "group": "dockerroot",
  "insecure-registries":["172.42.42.200:5000"]
}
EOF
usermod -aG dockerroot vagrant
systemctl restart docker
chmod 666 /var/run/docker.sock
