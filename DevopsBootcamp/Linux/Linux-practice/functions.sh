# sum=0
# while true
#   do
#     read -p "enter a score: " score
#     if [ "$score" == "q" ]
#     then
#       break
#     fi
#     sum=$(($sum+$score))
#     echo "total score: $sum"
#   done


# without passing in parameters
#!/bin/bash
function func_name () {
    echo "this is a simple function"
    echo ""
}
func_name

# pass in parameters
function create_file() {
    file_name=$1
    is_shell_script=$2
    touch $file_name
    if [[ $is_shell_script = true ]]
    then
        chmod u+x $file_name
        echo "file permissions for $file_name: "
        echo "#!/bin/bash\necho And with that, ladies and gentlemen, the 2023 season is over.\necho Happy New year, Phyllis!" > $file_name
        ls -l $file_name
        echo " "
        ./$file_name
    else
        echo "$file_name is empty"
    fi
}
create_file test.txt
create_file test.yaml
create_file test.sh true

# return value from a function
function sum() {
    total=$(($1+$2))
    return $total
}
sum 2 10
result=$?
echo $result
