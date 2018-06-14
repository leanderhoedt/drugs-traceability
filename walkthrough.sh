#!/bin/bash

URI="http://localhost:3000"

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
dafalganDrugHash=`sha256sum Dafalgan.json | awk '{ print $1 }'`

# get metadata of file
dafalganSerialNumber=`readJson Dafalgan.json serialNumber`
dafalganProductCode=`readJson Dafalgan.json productCode`
dafalganBatchNumber=`readJson Dafalgan.json batchNumber`

manufacturerId="jo"
manufacturerName="manufacturer_$manufacturerId"
distributerId="gene"
distributerName="distributer_$distributerId"
pharmacistId="leander"
pharmacistName="pharmacist_$pharmacistId"
patientId="cedric"
patientName="patient_$patientId"

echo "Creating drug ..."
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.CreateDrug", "drugHash": "'$dafalganDrugHash'", "name": "Dafalgan", "metaData": { "$class": "org.drugs.DrugMetaData", "serialNumber": "'$dafalganSerialNumber'", "productCode": "'$dafalganProductCode'", "batchNumber": "'$dafalganBatchNumber'", "manufacturer": "resource:org.drugs.Manufacturer#'$manufacturerId'" } }' "$URI/api/CreateDrug"

echo ""
echo "Created drug '$dafalganDrugHash'"
echo "by Manufacturer '$manufacturerId'"

echo ""
echo "Distributer '$distributerId' receives drugs from manufacturer '$manufacturerId'"
