#!/bin/bash

# Install nfs-utils and create NFS storage
echo "[TASK 1] Install nfs-utils and create NFS storage"
mkdir /srv/nfs/kubedata -p
chown nobody: /srv/nfs/kubedata
yum install -y -q nfs-utils nfs-utils-lib net-tools > /dev/null 2>&1
systemctl enable rpcbind >/dev/null 2>&1
systemctl enable nfs-server >/dev/null 2>&1
systemctl enable nfs-lock >/dev/null 2>&1
systemctl enable nfs-idmap >/dev/null 2>&1
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
cat >>/etc/exports<<EOF
/srv/nfs/kubedata *(rw,sync,no_subtree_check,no_root_squash,no_all_squash,insecure)
EOF
exportfs -rav
exportfs -v

# Install Docker Registry
echo "[TASK 2] Install Docker Registry"
docker run -d -p 5000:5000 --restart=always --name registry-srv -v docker:/var/lib/registry registry:2 >/dev/null 2>&1
docker run -d -p 8080:8080 --name registry-web --link registry-srv -e REGISTRY_URL=http://registry-srv:5000/v2 -e REGISTRY_NAME=localhost:5000 hyper/docker-registry-web >/dev/null 2>&1
chmod 666 /var/run/docker.sock
