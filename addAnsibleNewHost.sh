#!/bin/bash

### add a new host in ansible inventories, with group_vars , host_vars, etc
## ytanguy, 2018-01-22

group_list=()
while read line
do
    if [[ ! $line =~ :children && $line =~ ^\[(.*)\] ]]
    then
        group=${BASH_REMATCH[1]}
        group_list+=($group)
    fi
done < /etc/ansible/inventories/hosts

echo -e "Available groups from current inventories : "
for i in "${group_list[@]}"
do
    ((j++))
    echo -e "\t $j - $i"
done

echo -e "Choose ansible group to put host in (1 to $j) : "
read group
if [[ -z "$group" || ! $group =~ [0-9]{1,2} ]]
then
    echo -e "Missing or wrong 'group' parameter : $group"
fi

echo -e "Enter hostname : "
read host
if [[ -z "$host" || ! $host =~ [a-z]+ ]]
then
    echo -e "Missing or wrong 'host' parameter : $host"
    exit
fi

echo -e "Enter IP address of host : "
read ip
if [[ -z "$ip" || ! $ip =~ ([0-9]{1,3}\.?){4} ]]
then
    echo -e "Missing or wrong 'ip' parameter : $ip"
    exit
fi

echo -e "Enter user to connect to host : "
read user
if [[ -z "$user" || ! $user =~ [a-z]+ ]]
then
    echo -e "Missing or wrong 'user' parameter : $user"
    exit
fi

echo -e "Enter port to connect to host : "
read port
if [[ -z "$port"  || ! $port =~ [0-9]{1,5} ]]
then
    echo -e "Missing or wrong 'port' parameter : $port"
    exit
fi

group=${group_list[($group - 1)]}

echo -e "\nWill create host with these parameters : "
echo -e "\tgroup = $group"
echo -e "\thost = $host"
echo -e "\tip = $ip"
echo -e "\tuser = $user"
echo -e "\tport = $port"
echo -e "\nCONTINUE ?"
read -n 1 continue
if [[ "$continue" == "" ]]
then
    echo -e "*Add host '$host' to group '$group'*"
    sed -i "s/^\[$group\]/&\n$host/" /etc/ansible/inventories/hosts

    if [[ -f /etc/ansible/inventories/host_vars/$host ]]
    then
        echo -e "!Error : '$host' host_vars file already exists!"
        echo -e "\nEXIT HERE\n"
        exit
    else
        echo -e "*Create '$host' host_vars file*"
        echo "# created by addAnsibleNewHost.sh" > /etc/ansible/inventories/host_vars/$host
        echo "ansible_host: $ip" >> /etc/ansible/inventories/host_vars/$host
    fi

    echo -e "*Check for user '$user' and port '$port' in '$group' group_vars*"
    if [[ ! -f /etc/ansible/inventories/group_vars/$group ]]
    then
        echo -e "!Warning : '$group' group_vars does not exists, create it!"
        echo "# created by addAnsibleNewHost.sh" > /etc/ansible/inventories/group_vars/$group
    fi

    while read line
    do
        if [[ $line =~ ansible_user:\ $user ]]
        then
            echo -e "*!User '$user' already set on '$group' group_vars!"
        else
            echo -e "*Set user '$user' on '$host' host_vars*"
            echo "ansible_user: $user" >> /etc/ansible/inventories/host_vars/$host
        fi

        if [[ $line =~ ^ansible_port:\ $port ]]
        then
            echo -e "!Port '$port' already set on '$group' group_vars!"
        else
            echo -e "*Set port '$port' on '$host' host_vars*"
            echo "ansible_port: $port" >> /etc/ansible/inventories/host_vars/$host
        fi
    done < /etc/ansible/inventories/group_vars/$group

fi
