#!/bin/sh

for i in commands pulse
do
    for f in /dev/shm/queue/${i}/dead/*
    do
        find /dev/shm/queue/${i}/dead/ -iname "*.log" |
        while read line 
            do 
                egrep "error|ERROR|Error" "$line"
                if  [ $? -eq 0 ]; then 
                    echo "ERROR has been found on the log file on $(hostname)"
                fi 
                rm -rf "$line" 
        done
        if ! [ $? -eq 0 ]; then
            echo "ERROR: Unable to remove the log files on $(hostname)"
        fi
        if [[ -e ${f} ]];
        then
            mv  ${f} /dev/shm/queue/${i}/new/
        if ! [ $? -eq 0 ]; then
            echo "ERROR: The following job ${f} has not been moved from the dead directory in the new directory on $(hostname)"
        fi
        else
        continue
    fi
    done
done