# List of tools to handle Ansible inventories

## Requirements

### Inventories format

#### Examples

/etc/ansible/inventories/hosts
```
###################
## TYPES definition
###################

[linux:children]
infrastructure
monitoring
private

[production:children]
infrastructure

##################
# HOSTS definition
##################

[infrastructure]
server1
server2
server3
#server4
server5

[monitoring]
mon1
mon2

[private]
priv1
```

/etc/ansible/inventories/group_vars/infrastructure
```
# created by addAnsibleNewHost.sh
ansible_user: root
ansible_port: 22
```

/etc/ansible/inventories/host_vars/server1
```
# created by addAnsibleNewHost.sh
ansible_host: 123.123.123.123
```
