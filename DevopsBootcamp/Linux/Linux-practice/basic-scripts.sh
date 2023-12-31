#!/bin/bash
a=Phyllis
b=AfricA
c='linux class'
echo "My name is $a, from $b, and I am delighted to be in $c"

# save a variable from an output in a file.
iplist=$(cat iplist.txt)
echo "here are the list of ips in the ip file: " $iplist
