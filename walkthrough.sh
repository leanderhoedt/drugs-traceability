#!/bin/bash

read -p "Would you like to initialize everything? (Y/N)" confirm
echo
if [[ $confirm =~ ^[Yy]$ ]]
then sh ./initscript.sh
fi


function readJson {  
  UNAMESTR=`uname`
  if [[ "$UNAMESTR" == 'Linux' ]]; then
    SED_EXTENDED='-r'
  elif [[ "$UNAMESTR" == 'Darwin' ]]; then
    SED_EXTENDED='-E'
  fi; 

  VALUE=`grep -m 1 "\"${2}\"" ${1} | sed ${SED_EXTENDED} 's/^ *//;s/.*: *"//;s/",?//'`

  if [ ! "$VALUE" ]; then
    echo "Error: Cannot find \"${2}\" in ${1}" >&2;
    exit 1;
  else
    echo $VALUE ;
  fi; 
}


# generate sha256 of Dafalgan metadata
drugHash=`sha256sum Dafalgan.json | awk '{ print $1 }'`

# get metadata of file
dafalganSerialNumber=`readJson Dafalgan.json serialNumber`
dafalganProductCode=`readJson Dafalgan.json productCode`
dafalganBatchNumber=`readJson Dafalgan.json batchNumber`

read -p "enter to continue ..."



