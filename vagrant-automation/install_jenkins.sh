#!/bin/bash

# Install & Configure jenkins
echo "[TASK 1] Install & Configure jenkins"
su - vagrant -c "kubectl create namespace jenkins"
su - vagrant -c "kubectl create -f /vagrant/jenkins/jenkins-sc.yaml"
su - vagrant -c "kubectl create -f /vagrant/jenkins/jenkins-pv.yaml"
su - vagrant -c "kubectl create -f /vagrant/jenkins/jenkins-pvc.yaml"
# helm inspect values jenkinsci/jenkins > /tmp/jenkins-values.yaml
su - vagrant -c "helm install jenkins -n jenkins -f /vagrant/jenkins/jenkins-values.yaml jenkinsci/jenkins"
