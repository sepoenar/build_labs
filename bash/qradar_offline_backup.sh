#!/bin/bash

### check if active node
[ $(/opt/qradar/ha/bin/ha state) != "active" ] && exit 0;

FLAG_EMAIL=true
HOST_NAME=$(hostname -s)
SUBJECT="Restarting ECS services on $HOST_NAME"
STORY=""

[ ! -d /opt/SOS/qradar/bin/log/ ] && mkdir -p /opt/SOS/qradar/bin/log/
LOGFILE="/opt/SOS/qradar/bin/log/restart-ECS-services-$(date +"%d_%m_%Y").log"
echo "" > $LOGFILE

#EMAIL="sos-qradar@wwpdl.vnet.ibm.com"
EMAIL="sepoenar@gmail.com"

function send_email () {

  ssh root@10.10.10.10 /bin/sh <<EOF
mail -s "$SUBJECT" "$EMAIL" << END_MAIL
    Log file: '$LOGFILE'
-----------------------------------------------
    $STORY


END_MAIL
EOF

}

exec > $LOGFILE 2>&1
### restating services
[ $(/opt/qradar/ha/bin/ha state) == "active" ] && (systemctl restart ecs-ec-ingress; sleep 5; systemctl restart ecs-ec; sleep 5; systemctl restart ecs-ep;)

### check status, if any service is failing to restart will alert, if not it will send an email to confirm services has been restarted
[ $(/opt/qradar/ha/bin/ha state) == "active" ] && [ $(systemctl status ecs-ec |grep -i active:|awk '{print $3}') == "(running)" ] && STORY="ecs-ec service was successfully restarted; $STORY" || (FLAG_EMAIL=false; SUBJECT="ecs-ec service didn't restart correctly on $HOST_NAME";STORY=$(cat $LOGFILE);send_email);
sleep 5;
[ $(/opt/qradar/ha/bin/ha state) == "active" ] && [ $(systemctl status ecs-ec-ingress |grep -i active:|awk '{print $3}') == "(running)" ] && STORY="ecs-ec-ingress service was successfully restarted; $STORY" || (FLAG_EMAIL=false; SUBJECT="ecs-ec-ingress service didn't restart correctly on $HOST_NAME"; STORY=$(cat $LOGFILE);send_email);
sleep 5;
[ $(/opt/qradar/ha/bin/ha state) == "active" ] && [ $(systemctl status ecs-ep |grep -i active:|awk '{print $3}') == "(running)" ] && STORY="ecs-ep service was successfully restarted; $STORY." || (FLAG_EMAIL=false; SUBJECT="ecs-ep service didn't restart correctly on $HOST_NAME"; STORY=$(cat $LOGFILE);send_email);
sleep 5;

[ $FLAG_EMAIL ] && (SUBJECT="Service successfully restarted on $HOST_NAME";send_email)

exit 0;
