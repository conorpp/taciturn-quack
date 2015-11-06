#!/bin/bash

i=1
mountp=drive
drive_folder=$mountp/storage_test3
bigfile=Bigfile

if [[ ! -f $bigfile ]]
then
    echo "initializing first big file and encypting..."
    cat /dev/urandom | head -c $((150 * (1<<20))) > $bigfile
    openssl aes-256-cbc -in $bigfile -pass pass:wat"$RANDOM"word | head -c $((150*(1<<20))) > "$bigfile".bin
    cp "$bigfile".bin Bigfile
fi
bigfile=bigfile"$RANDOM""$RANDOM""$RANDOM"
cp Bigfile "$bigfile".bin
nextfile="$bigfile".bin

echo starting

while true
do
    i=$(($i+1))
    lastfile=$nextfile
    nextfile=$bigfile"$i".bin

    if [[ "$(($i % 100))" == "9" ]]
    then
        echo "clearing cache"
        umount $mountp
        google-drive-ocamlfuse -cc
        google-drive-ocamlfuse $mountp
    fi

    openssl aes-256-cbc -in $lastfile -pass pass:pass"$RANDOM"word | head -c $((150*(1<<20))) > $nextfile
    cp $nextfile $drive_folder/$nextfile
    sync
    
    # test it worked until it worked
    while [ $(du -b $drive_folder/$nextfile |awk '{print $1}') == '0' ] ;
    do
	    echo "transfer failed - trying again"
        cp $nextfile $drive_folder/$nextfile
    	sync
    done

    rm $lastfile

    echo "$lastfile uploaded"

done
