#!/bin/bash
####################################
##Nightly backup offline sync script
##The script pulls all nightly backups from all SOS Qradar consoles and EPs
####################################
: 'SOS QRadar Consoles and EPs:
make sure destination directory is like
/QRbackups/SJC3Test/sj3-ta-qracon01/
the path needs 3 jumps


version 5b
-> backup integrity logs for Shared4 console and EPs

3Dec2021: 50 count
'
COMPONENT=(
"IP:/path/to/folder/"
)

##SOS Qradar group email
#EMAIL="sos-qradar@wwpdl.vnet.ibm.com"
EMAIL=""
COMPONENTS=0

##SSH key created May 2019, a reminder will be added.
SHH_KEY_DATE="01 05 2019"
SSH_KEY_EXP="01 05 2021"
NOW=`date +"%d %m %Y"`

##SSH key
SSH_KEY="/root/.ssh/dl9-pl-qstor01_rsa"

## Source dir
SRC_DIR="/store/backup/"
INTEGRITY_DIR="/store/LOGS/integrity/"

## Number of days back for keeping files
nDAYS=365

## Get epoch date nDAYS days ago
xDAYS_AGO=$(date -d "-$nDAYS day 00:00:00" +%s)

## Number of files to be deleted
HITCOUNT=0

##REGEX for backup files
ARCHIVES_REGEX="^backup.nightly.*_([0-9]+).([0-9]+)_([0-9]+)_([0-9]+).([a-z]+).([0-9]+).tgz$"
LOG_DATE="([0-9]+)_([0-9]+)_([0-9]+)"

## Array for holding file names older than $xDAYS_AGO
result=()

SUBJECT=""
STORY=""
WHATHAPPENED=""

CON=""

##delimiter
function delimiter {
   for i in {1..20}; do echo -ne "="; done; echo -e "\n"
}

##################################
##################################

#LOGFILE=/QRbackups/logs/backup_log_$(date +"%Y-%m-%d_%H-%M").log
LOGFILE=/opt/SOS/bin/log/backup_log_$(date +"%Y-%m-%d_%H-%M").log
#    Redirect output
exec > $LOGFILE 2>&1

echo -e "\n\nOffline Nightly Backups - $(date)\n\n"

##################################
##################################

## Send email function
function send_email() {
   mailx -s "$SUBJECT" $EMAIL << END_MAIL
   Story: $STORY

   Log file: "$LOGFILE"
   EOM
END_MAIL
}

##################################
##################################

function clenup_backup_dir {
   echo -e "[INFO] Destination dir is: $1"
   AYEARAGO=$(date --date="1 year ago" '+%d_%m_%Y')
   echo -e "[INFO] 1 year ago date is: $AYEARAGO. All files oder 365 days will be deleted!"

   #delete from destination offline, files older than 365 days#
   find $1 -type f -mtime +366 -print
   find $1 -type f -mtime +366 -delete
}

function analize_sync_output {
   echo "Rsync --- return code: $1"
   echo ""
   if [ $1 != 0 ]; then
      echo "[ERROR] Rsync error, '$2' backup failed ! Sending email alert..."
      SUBJECT="[ERROR] Offline Nightly Backup :: BACKUP FAILED on $2 - $(date)"
      #STORY="'$2' backup has failed."
      send_email
  else
    echo "[SUCCESS] Backup sync successful - '$2', backup complet."
  fi
}

function execute_sync {
#   echo "rsync -avuzPh --no-o --no-g --bwlimit=5000 $1:$2 $3"
   echo "rsync -avuzPh --no-o --no-g $1:$2 $3"
   exec 3>&1 4>&2
   exec > /tmp/foo 2>&1
#   CMD=$(rsync -avuzPh --no-o --no-g --bwlimit=5000 $1:$2 $3)
   CMD=$(rsync -avuzPh --no-o --no-g $1:$2 $3)
   RETURN=$?
   STORY=$(cat /tmp/foo)
   exec >&3  2>&4
   analize_sync_output $RETURN $4
}

function sync_archives {
   COMPONENTS=$[$COMPONENTS+1]
   echo -e "$COMPONENTS - starte time: $(date +%T)"
   echo "[INFO] Backup started for $5 - $2"
   execute_sync  $2 $3 $4 $5
   [[ "$4" =~ .*Shared4.* ]] && (echo -e "\n[INFO] Shared4 console/EP - integrity log exists"; execute_sync $2 $INTEGRITY_DIR $4 $5)
}

function check_connectivity {
   CON=$(ssh $1 exit; echo $?)
   #echo $CON
}

for line in "${COMPONENT[@]}"
do
   IP_ADD="${line%%:*}"
   DEST_DIR="${line##*:}"
   WHOIAM=$(echo $DEST_DIR|awk -F "/" '{print $4}')
   check_connectivity $IP_ADD
   if [[ $CON == '0' ]]; then
      sync_archives $SSH_KEY $IP_ADD $SRC_DIR $DEST_DIR $WHOIAM
      clenup_backup_dir  $DEST_DIR $WHOIAM
   else
      echo  "[ERROR] Connectivity failed on $IP_ADD ! Sending email alert..."
      SUBJECT="[ERROR] Offline Nightly Backup :: Connectivity to $WHOIAM failed - $(date)"
      STORY="[ERROR] No ssh connectivity to $IP_ADD!"
      send_email
   fi
   echo ""
   delimiter
done

if [[ "$NOW" =~ $SSH_KEY_EXP ]]
then
  echo "[INFO] Sending email alert..."
  SUBJECT="Offline Nightly Backup :: SSH KEY Pair close to expire on `hostname`"
  STORY="SSH KEY pair needs to be renewed every 2 years!\nIt passed 2 years since creation!"
  send_email
fi

##change ownersip on /QRbackups/ nightly backups, it is better for DR backup
chown -R nfsnobody:nfsnobody /QRbackups/

echo -e "[INFO] Backups finished for $COMPONENTS devices: $(date)"
# The END
exit $?
