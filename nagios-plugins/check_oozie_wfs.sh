#!/bin/bash
# check_oozie_wfs - Check last n Oozie workflows of running coordinators for errors
# 2012-02-21 AGn

lastrunwfs=25
icinga_host="icinga.domain.tld"

# find out which coordinators are running 
running_coords=`/data/oozie/oozie/bin/oozie jobs -oozie http://localhost:11000/oozie -jobtype coordinator -filter status=RUNNING | grep -v ^- | tail -n +2 | cut -d" " -f1`

badworkflows=0

for c in $running_coords
do
        badwfs=`/data/oozie/oozie/bin/oozie job -oozie http://localhost:11000/oozie -info $c | \
        tail -n $lastrunwfs | grep ^[0-9] | sort -n -k3 | tail -n 50 | grep -v PREP | grep -v RUNNING | grep -v SUCCEEDED | grep -v WAITING`

        if [ ! "$badwfs" == "" ]
        then   
                badworkflows=$(( badworkflows + 1))
        fi

done

if [ $badworkflows -eq 0 ]
then   
        echo -e "`hostname -f`\toozie_workflow_status\t0\tOK | badworkflows=0" | /usr/sbin/send_nsca -H $icinga_host -c /etc/send_nsca.cfg
else  
        echo -e "`hostname -f`\toozie_workflow_status\t1\tWARNING - $badworkflows workflows are bad | badworkflows=$badworkflows" | /usr/sbin/send_nsca -H $icinga_host -c /etc/send_nsca.cfg
fi

exit 0

