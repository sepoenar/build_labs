#!/bin/bash
##script to install NR remotly

MYSELF=$(ls -l $0 | awk '{print $NF;}')
MYNAME=$(basename $MYSELF)
BIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MY_SELF_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
EP_IP_LIST="$BIN_DIR/ep_ip.list"
NAT_EP_IP_LIST="$BIN_DIR/NAT_ep_ip.list"

NR-NR-con_ep_portmonitor_update.sh"

NR_DIR="/opt/SOS/newrelic"
NR_CONF="$NR_DIR/ep_details.yml"
NR_CONF_TEMPLATE="$NR_DIR/Template-Qradar-newrelic-infra.yml"



HostGroup=""
Region=""
DataCentre=""
HostedType=""
Environment=""
HostFunction=""

function get_ep_details {
  read -p "Console: [QRadar-SIEM4 | QRadar-EUC]" HostGroup
  read -p "Region: [US | EU]" Region
  read -p "Function: [EP | EC | DN | Console]" HostFunction
  read -p "Data Center: [eg. DAL09]" DataCentre
  read -p "Host Type: [VM | BM | AWS]" HostedType
  read -p "Environment: [PROD | TEST | DEV]" Environment
}

function action {
  get_ep_details
  head --lines=-7 Template-Qradar-newrelic-infra.yml > ep_details.yml
  echo "  Team: SOS-QRadar" >> $NR_CONF
  echo "  HostGroup: $HostGroup" >> $NR_CONF
  echo "  Country: $Region" >> $NR_CONF
  echo "  DataCentre: $DataCentre" >> $NR_CONF
  echo "  HostFunction: $HostFunction" >> $NR_CONF
  echo "  HostedType: $HostedType" >> $NR_CONF
  echo "  Environment: $Environment" >> $NR_CONF
  
##check if ep_details.yml has been updated
# read -p "Did you updated $NR_CONF file?(y/n)" CHOICE
#case "$CHOICE" in
#   y|Y ) echo -e "\nContinue...\n" ;;
#  * ) echo -e "Please update the file and execute the script again!\nExit!"; exit 0 ;;
#esac

   ##check connectivity
   echo -e "\n\nCheck connectivity with New Relic ... "
   [[ $(nmap -Pn -p 443 infra-api.newrelic.com|grep 443/tcp) =~ .*open.* ]] && echo "connectivity ok" || echo "connectivity NOT ok"
   ssh root@$1 "nmap -Pn -p 443 infra-api.newrelic.com|grep 443/tcp"
   ##copy new_relic packages over
   echo -e "\n\n[INFO] Create NR dir if don't exist and copy files over..."
   ssh root@$1 "rm -Rf $DEST_NR_DIR"
   ssh root@$1 "mkdir -p $DEST_NR_DIR"
   rsync -avurzPh $SRC_NR_DIR root@$1:$DEST_NR_DIR
   echo -e "\n\nChange permission on instll script..."
   ssh root@$1 "chmod 755 $DEST_NR_DIR$NR_INSTALL_SCRIPT"
   ssh root@$1 "ls -al $DEST_NR_DIR$NR_INSTALL_SCRIPT"
   echo -e "\n\nCopy files over to remote EP..."
   rsync -avurzPh $NR_CONF root@$1:$NR_CONF_REMOTE
   ssh root@$1 "cat $NR_CONF_REMOTE"
   ssh root@$1 "$DEST_NR_DIR$NR_INSTALL_SCRIPT"
   echo -e "\n\nCheck NewRelic service..."
   ssh root@$1 "ps -aef|grep newrelic"
   echo -e "\n\nCheck NewRelic log entry..."
   ssh root@$1 "tail -10 /var/log/newrelic-infra/newrelic-infra.log"
   echo -e "\n\nAdd port 22 monitoring from console to EP..."
   $PORT_MON_CMD
}

function action_list {
   echo -e "[INFO] List Mode!\nNot implemented yet!"
}

##check if list is parameter in command
echo -e "\n[$(date)] Script start.\n"
if [ $# -eq 0 ]; then
   echo -e "[ERROR]: Missing parameter. Abort execution!\n"
   exit 1
elif [ $1 == "list" ]; then
   action_list $LIST
elif [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
   echo -e "[RUN] IP mode\n"
   action $1
else
   echo -e "[ERROR] Wrong parameter. Abort execution!"
   exit 1
fi

echo -e "\n[$(date)] Script end.\n"
exit $?
