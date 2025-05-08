# k8s

## Vagrant

- start

```shell
vagrant up
```

- stop

```shell
vagrant halt
```

- delete

```shell
vagrant destroy
```

- ssh

```shell
vagrant ssh
```

- check status

```shell
vagrant status
```

- sync with Vagrantfile

```shell
vagrant reload
```

## Ansible

- run

```shell
ansible-playbook -i inventory.ini setup.yml
```

- get ip local of vm

```shell
vagrant ssh worker-1 -c "hostname -I"
```

## K8S

### Init cluster

```shell
sudo kubeadm init --control-plane-endpoint "controlplane:6443" --pod-network-cidr=10.0.0.0/16 --upload-certs
```

### Show join command

```shell
sudo kubeadm token create --print-join-command
```

### Init kubectl

```shell
rm -rf $HOME/.kube
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/super-admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl config use-context kubernetes-super-admin@kubernetes
```

### Setup

- install calico

```shell
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

- install metrics server

```shell
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```