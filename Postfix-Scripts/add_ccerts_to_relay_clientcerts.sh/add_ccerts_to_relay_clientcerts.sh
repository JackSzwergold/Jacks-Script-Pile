#!/bin/bash -e
#
# $Id: add_ccerts_to_relay_clientcerts.sh 2 2005-02-04 09:04:54Z patrick $
# vim: sts=2
#
#
# add_ccerts_to_relay_clientcerts.sh
# Extract MD5 sum from a (directory of) certificate(s) that end on *.pem and
# add it to a Postfix map that may be used to control certificate based
# relaying.
#
# Example output to the map:
# # subject= /C=DE/ST=Bavaria/L=Eching/O=State of Mind/CN=patrick/emailAddress=p@state-of-mind.de
# 44:22:00:38:76:87:87:F6:67:27:5C:FB:D8:A5:75:9A         Feb  3 11:31:39 2006 GMT

#####################################################################
#                          VARIABLES                                #
#####################################################################

# map (filename without path)
CERTMAP="relay_clientcerts"

# suffix for prototype map
PROTOSUFFIX="proto"

# prototype map
PROTOMAP="${CERTMAP}.${PROTOSUFFIX}"

# Postfix confuguration directory
# We ask Postfix where it stores configuration and maps by default
POSTFIXCONFDIR="$(postconf -n -h config_directory)"

# root has $UID 0
ROOT_UID=0

#####################################################################
#                     COMMANDS AND FUNCTIONS                        #
#####################################################################


function root_check () { 
if [ "$UID" -eq "$ROOT_UID" ]; then
  :
else
  echo "You must be root to run `basename ${0}`."
  exit 77
fi
}


function check_input () {
if [ -e ${1} ]; then
  :
else
  echo "File or directory does not exist: ${1}"
  exit 1
fi
}


function build_protomap () {

declare -a CERTS
CERTS=($(find ${1} -type f -name *.pem))

for i in ${CERTS[@]}; do

  echo "# $(openssl x509 -noout -subject -in ${CERTS})"
  echo -e "$(openssl x509 -noout -fingerprint -in ${CERTS} | sed -e 's/MD5 Fingerprint=//')\
          $(openssl x509 -noout -enddate -in ${CERTS} | sed -e 's/notAfter=//')"

done >> ${PROTOMAP}
}


function build_certmap () {
if [ -e ${PROTOMAP} ]; then
	chmod 600 ${PROTOMAP}
  postmap -p -r hash:${PROTOMAP}
else
  echo "Protomap does not exist: ${PROTOMAP}"
  exit 66
fi
}


function install_certmap () {
if $(mv ${PROTOMAP}.db ${POSTFIXCONFDIR}/${CERTMAP}.db 2>/dev/null); then
  chmod 600 ${POSTFIXCONFDIR}/${CERTMAP}.db
else
  echo "Could not move ${PROTOMAP}.db to ${POSTFIXCONFDIR}/${CERTMAP}.db"
fi
}


root_check
if [ -z "$1" ]; then
  echo "Usage: `basename $0` filename"
  exit 64
else
  check_input ${1}
  build_protomap ${1}
  build_certmap
  install_certmap
fi

