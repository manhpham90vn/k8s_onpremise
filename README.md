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