#!/bin/bash
count=98
if [ $count -eq 100 ]
then
    echo the count is 100
else
    echo "The count is not quite 100; the current count is $count"
fi

count=100
if [ $count -eq 100 ]
then
    echo count is 100
else
    echo count is not 100
fi

# check if the file exits exists
if [ -e home/user/existing.txt ]
then
    echo "file exists"
else
    echo "file does not exist"
fi

# check if a variable is met
a=`date | awk '{print $1}'`
if [ $a == Sun ]
then
    echo Today is $a
else
    echo Today is definitely not Sunday
fi

# # check the response then output
# echo What is your name?
# read name
# echo "Hello $name! Do you like working in IT? (y/n)"
# read like
# if [[ $like == y ]] || [[ $like == Y ]]
# then
#     echo You are a super cool guy
# else
#     echo But why though, join the cool kids
# fi

userGroup=phyllis
if [ $userGroup == "phyllis" ]
then
    echo "you can configure the server"
elif [ $userGroup == "admin" ]
then
    echo "You have admin rights to configure the server"
else
    echo "you do not not have the necessary permissions to configure this server"
fi

# provide the variable as a parameter
userGroup=$1
if [ "$userGroup" == "phyllis" ]
then
    echo "you can configure the server"
elif [ "$userGroup" == "admin" ]
then
    echo "You have admin rights to configure the server"
else
    echo "you do not not have the necessary permissions to configure this server"
fi


configDir=$2
if [ -d "$configDir" ]
then
    config_file=$(ls "$configDir")
    echo -e "here are the config directory contents: \n$config_file"
else
    echo "$configdir not found. Creating directory"
    new_config_file=$(mkdir -p "$configDir/newdir"; mkdir "$configDir/another_dir"; touch "$configDir/newfile.txt")
    ls "$configDir"
fi

# to execute on the command line, pass in the variables, the first being for $1 and the second being for $2:
# e.g ./if-then.sh admin configs