#!/bin/bash

#ACTUAL DATE
ds=`date "+%Y_%m_%d"`

#DATE WITH HOUR & MINITE
ds_h=`date "+%y-%m-%d-%H-%M"`

#TO FETCH THE LOGS FILES MORE THAN 1 GB.
store=`du -ha / 2>/dev/null | grep '[0-9\.0]\+G'| grep /storage/logs/| sort -rh | head -30|awk '/log$/'|awk '{print $2}'`
for file in $store;do
        echo -e $file-$ds_h
        zip -r $file-$ds_h.zip $file    #ZIPPING THE EACH OF THE LOGS FILES 
        zipstatus=$?
        #echo $zipstatus

        #FILTERING THE LOGS FILE PATH TO CREATE MODULE WISE LOGS
        resource=$file
        a_resource=`echo -e $resource|awk -F"storage/logs/" '{print $2}'`
        #echo $a_resource

        #GCS BUCKET DETAILS TO PUSH THE LOGS FILES
        bucketname="openmoney-prod-cron-v2"
        g_location=$bucketname/$ds/$a_resource-$ds_h'.zip'
        echo "Bucket Path on GCS: $g_location"

        #PUSH THE LOGS FILES TO THE GCS
        gsutil cp $file-$ds_h.zip gs://$g_location
        gcsstatus=$?
        #echo $gcsstatus
        if [ $zipstatus -eq 0 ] && [ $gcsstatus -eq 0 ];   
                then
                rm -f $file-$ds_h.zip
                >$file  
                echo "File has been successfully emptied"
        fi
done
