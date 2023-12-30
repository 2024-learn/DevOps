for i in {1..5} # 1 2 3 4 5 
do
echo Welcome $i times
done
# Welcome 1 times
# Welcome 2 times
# Welcome 3 times
# Welcome 4 times
# Welcome 5 times

# Simple for loop output
for i in eat run jump play
do
echo See Phyll $i
done
# See Phyll eat
# See Phyll run
# See Phyll jump
# See Phyll play

# for loop to create 5 files named 1-5
for i in {1..5}
do
 touch $i
done

# for loop to delete 5 files named 1-5
for i in {1..5}
do
 rm $i
done

# specify days in a for loop
i=1
for day in Mon Tue Wed Thu Fri
do
echo "Weekday $((i++)) : $day"
done
# Weekday 1 : Mon
# Weekday 2 : Tue
# Weekday 3 : Wed
# Weekday 4 : Thu
# Weekday 5 : Fri

# List all users one by one from /etc/passwd file

i=1
for username in `awk -F: '{print $1}' /etc/passwd`
do
echo "Username $((i++)) : $username" >> users.txt
done