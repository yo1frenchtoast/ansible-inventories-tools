#!/bin/bash

### extract ansible_host list from /etc/ansible/hosts and convert it to bash alias, ytanguy 2017-05-31
# 2017-11-17 : change to inventories/host_vars ansible format

proceed=false
while read line
do
    [[ $line =~ "HOSTS definition" ]] && proceed=true

    if $proceed
    then
        unset user
        unset ip
        unset port
        unset option

        if [[ ! $line =~ :children && $line =~ ^\[(.*)\] ]]
        then
            group=${BASH_REMATCH[1]}
        fi

        if [[ $line =~ ^([a-zA-Z0-9]+.*) ]]
        then
    	    host=${BASH_REMATCH[1]}

            if [[ -e /etc/ansible/inventories/group_vars/$group ]]
            then
                while read param
                do
                    if [[ $param =~ ansible_user:\ ([a-z]+) ]]
                    then
                        user=${BASH_REMATCH[1]}
                    fi

                    if [[ $param =~ ansible_port:\ ([0-9]{1,5}) ]]
                    then
                        port=${BASH_REMATCH[1]}
                    fi
                done < /etc/ansible/inventories/group_vars/$group
            fi

            if [[ -e /etc/ansible/inventories/host_vars/$host ]]
            then
                while read param
                do
                    if [[ $param =~ ansible_host:\ (([0-9]{1,3}\.?){4}) ]]
                    then
    	                ip=${BASH_REMATCH[1]}
                    fi

                    if [[ ! $user || $user == "root" ]]
                    then
    	                if [[ $param =~ ansible_user:\ ([a-z]+) ]]
                        then
    	                    user=${BASH_REMATCH[1]}
    	                else
    	                    user='root'
    	                fi
                    fi

                    if [[ ! $port || $port -eq 22 ]]
                    then
                        if [[ $param =~ ansible_port:\ ([0-9]{1,5}) ]]
    	                then
    	                    port=${BASH_REMATCH[1]}
    	                else
    	                    port=22
    	                fi
                    fi

                    if [[ $param =~ ansible_ssh_common_arg:\ \"-o\ (.*)\" ]]
                    then
                        option=${BASH_REMATCH[1]}
                    fi

                done < /etc/ansible/inventories/host_vars/$host

                if [[ $1 == "alias" ]]
                then
                    echo "alias $host='ssh $user@$ip -p $port'"
                else
                    unset CONFIG
                    if [[ ! $option ]]
                    then
                        CONFIG=$(cat <<EOF
Host $host
    User $user
    HostName $ip
    Port $port
EOF
                        )
                    else
                        CONFIG=$(cat <<EOF
Host $host
    User $user
    HostName $ip
    Port $port
    $option
EOF
                        )
                    fi
                    echo "$CONFIG"
                fi
            fi
        fi
    fi
done < /etc/ansible/inventories/hosts
