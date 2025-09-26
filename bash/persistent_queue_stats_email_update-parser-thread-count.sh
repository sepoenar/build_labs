##cron job to be scheduled
##Email Notification for persistent_queue status
#0 * * * * /opt/SOS/qradar/bin/persistent-queue-utils.sh 2>&1 > /tmp/email-ingress-stats.cron.log

#Script path: /opt/SOS/qradar/bin/email-ingress-stats.sh

#--------------------------------
if [ -d /store/persistent_queue/ecs-ec-ingress.ecs-ec-ingress/ ]
then
        THREADS=`grep PARSER_THREAD_COUNT /opt/qradar/conf/nva.conf | cut -d= -f2`
        FILECOUNT=`ls -ltrh /store/persistent_queue/ecs-ec-ingress.ecs-ec-ingress/ | wc -l`
        if [ "$THREADS" -lt 30 ]
        then
           sed -i 's/PARSER_THREAD_COUNT=[0-9]*/PARSER_THREAD_COUNT=30/' /opt/qradar/conf/nva.conf
           systemctl restart ecs-ec
        fi

        #if [ "$FILECOUNT" -gt 99 -o "$THREADS" -lt 30 ]
        if [ "$FILECOUNT" -gt 99 ]
        then
                (
                        echo Current thread setting
                        grep PARSER_THREAD_COUNT /opt/qradar/conf/nva.conf
                        echo
                        echo du
                        du -s /store/persistent_queue/ecs-ec-ingress.ecs-ec-ingress/
                        du -sh /store/persistent_queue/ecs-ec-ingress.ecs-ec-ingress/
                        echo
                        echo filecount /store/persistent_queue/ecs-ec-ingress.ecs-ec-ingress/
                        ls -ltrh /store/persistent_queue/ecs-ec-ingress.ecs-ec-ingress/ | wc -l
                ) | mailx -s "WARNING: Ingress Stats/Thread Count from `hostname`" sos-qradar@wwpdl.vnet.ibm.com
        fi
fi
#--------------------------------