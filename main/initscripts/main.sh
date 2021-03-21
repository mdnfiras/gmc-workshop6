#!/bin/bash
echo "=======> disabeling swap :"
swapoff -a

echo "=======> updating repos :"
apt update
echo "=======> installing curl, gnupg, software-properties-common :"
apt -y install curl gnupg software-properties-common

echo "=======> installing docker.io :"
apt -y install docker.io
echo "=======> starting docker :"
systemctl start docker
echo "=======> enabeling docker :"
systemctl enable docker
echo "=======> checking docker status :"
systemctl status docker | head -3 | tail -1

echo "=======> adding kubernetes repo :"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
echo "=======> updating repos :"
apt update
echo "=======> installing kubeadm, kubelet, kubectl & kubernetes-cni :"
apt -y install kubeadm kubelet kubectl kubernetes-cni

echo "=======> setting hostname to main :"
hostnamectl set-hostname main

echo "=======> initializing kubeadm :"
kubeadm init

echo "=======> copying config file :"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "=======> generating kubejoin.sh :"
printf %"s\n" \
"swapoff -a" \
"echo y | kubeadm reset" \
"systemctl restart kubelet" \
"`kubeadm token create --print-join-command`" \
"echo \"kubelet status\" :" \
"systemctl status kubelet | head -5 | tail -1"> kubejoin.sh
