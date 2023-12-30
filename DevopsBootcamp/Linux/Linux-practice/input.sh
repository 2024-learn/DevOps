#!/bin/bash
echo Hello, my name is AI Helper. What is your name?
read name
echo Hello $name! Nice to meet you!

# if you want it to read a command inside an echo command:
server_name=`hostname`
echo My name is $server_name