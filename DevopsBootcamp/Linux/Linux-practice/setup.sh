#!/bin/bash
if [ -d "config" ]
then
    echo "here are the config directory contents"
    config_file=$(ls config)
else
    echo "configdir not found. Creating config dir"
    mkdir config
fi

file_name=iplist.txt
ip_list=$(cat $file_name)
echo "using $file_name to check for pingable ips"
echo "here are the list of IPs we'll use to test out the ping command : $ip_list"


# pass in at the command line when executing script
echo "all params : $*"
echo "number of params: $#"
for param in $*
    do
        echo $param
    done