#!/bin/bash

# -t (timeout)
# -c count: the number of ping times
ping -c2 -t2 8.8.8.8
if [ $? -eq 0 ]
then
    echo OK
else
    echo NOT OK
fi


# Don't show the output
ping -c1 -t2 192.168.1.1 &> /dev/null
if [ $? -eq 0 ]
then
    echo OK
else
    echo NOT OK
fi

# Define a variable:
host="8.8.8.8"
ping -c2 -t2 $host &> /dev/null
if [ $? -eq 0 ]
then
    echo $host is reachable
else
    echo $host NOT reachable
fi

echo # leaves an empty line in the output


# ping multiple addresses
IPLIST="./iplist.txt"

for ip in $(cat $IPLIST)
do
    ping -c1 -t2 $ip &> /dev/null
    if [ $? -eq 0 ]
    then
        echo $ip ping OK
    else
        echo $ip ping NOT OK
    fi
done