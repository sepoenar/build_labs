#!/bin/bash

echo "
Script to renew Let's Encrypt certificates...
$(date)

"

LOCAL_HOST=$(hostname -s)
PFX_FILE="/opt/qradar/conf/key_stores/$LOCAL_HOST.servercert.pfx"
PASSWORD="qqZa4TUJTCHXgHtV"

CERT_DIR="/opt/SOS/qradar/certs/"
LE_CA_INTERMEDIATE=""
CA_ANCORS_DIR="/etc/pki/ca-trust/source/anchors/"

echo -e "Make sure you have the files in correct location!!!\nScript location: $(pwd)\nCerts location: $CERT_DIR";
echo -e "\nCertificates:"
ls -althr $CERT_DIR

[[ ! -d $CERT_DIR ]] && echo -e "\nCert directory don't exist! Creating it! Please put the certs here!" && mkdir -p $CERT_DIR && exit 1;
[[ -f $PFX_FILE ]] && echo -e "\nPFX file to be updated with new certs: \n$PFX_FILE";


###check flags
[[ $# -ne 6 ]] && echo -e "\n\nScript should be run like:\n ./script.sh -c certificate.pem -k private.key -i intermediate.pem \n replace with your own cet/keynames/intermediate" && exit 1;

while getopts c:k:i: flag
do
    case "${flag}" in
        k) KEY_FILE=${OPTARG};;
        c) CERT_FILE=${OPTARG};;
        i) INTERMEDIATE_FILE=${OPTARG};;
    esac
done

###COMMAND
echo -e "\nopenssl pkcs12 -export -out $PFX_FILE -inkey $CERT_DIR$KEY_FILE -in $CERT_DIR$CERT_FILE -certfile $CERT_DIR$INTERMEDIATE_FILE -password pass:$PASSWORD"
openssl pkcs12 -export -out $PFX_FILE -inkey $CERT_DIR$KEY_FILE -in $CERT_DIR$CERT_FILE -certfile $CERT_DIR$INTERMEDIATE_FILE -password pass:$PASSWORD

echo -e "\n $(date) - Done..."