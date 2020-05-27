# Demo CI/CD

### This will help to deploy a demonstration stand for work (experiments) in k8s.
-----------------------------------------------------------------------------
* install.txt - Install Kubernetes Cluster using kubeadm, Helm 2(3), Docker Registry, NFS server, Dynamic Volume Provisioning, Jenkins on CentOS 7
* nfs-provisioner - YAML for Dynamic Volume Provisioning
* config - config files Cluster Networking, Jenkins, Docker Registry

##### After installation and configuration:

Enter Jenkins <ip-adress:32323> (admin/admin) and add in *Credentials* - *Add Credentials* - *Kubernetes configuration (kubeconfig)* 
>Note that in the field: ID
>has to be: mykubeconfig
>Content: contents of your file 
```sh
$ cat /home/user/.kube/config
```

Upload edited files to your GitHub:
* Dockerfile
* index.html
* Jenkinsfile
* web.yaml

Now you need to connect to the *Open Blue Ocean* your GitHub using the received token.
If everything is done correctly, watch the automatic CI/CD of our web page. At < ip-adress: 32223 > there will be our test web page.
To automatically upload modified code from the GitHub to our test stand, you must configure *Webhook* in your repository settings.