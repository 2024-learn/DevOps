#!/bin/bash
echo please choose one of the options below:
echo 'a = Display Date and Time'
echo 'b = List files and directories'
echo 'c = List users logged in'
echo 'd = Check system uptime'

read choices
case $choices in
a) date;;
b) ls;;
c) who;;
d) uptime;;
*) echo Invalid choice - bye!
esac

# Write a case script that will give the option to the user to run commands as, top, iostat, free, dmesg, cat /proc/cpuinfo, cat /proc/meminfo
echo please choose one of the options below:
echo 'a = show the linux processes'
echo 'b = input output statistics'
echo 'c = display the physical memory, swap space'
echo 'd = display the output of the system, related warnings, error messages, failures'

read choices
case $choices in
a) top;;
b) iostat;;
c) free;;
d) dmesg;;
*) echo Invalid choice - bye!
esac
