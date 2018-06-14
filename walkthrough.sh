#!/bin/bash

URI="http://localhost:3000"

read -p "Would you like to start the business network? (Y/N)" confirm
echo
if [[ $confirm =~ ^[Yy]$ ]]
then sh ./startBusinessNetwork.sh
fi

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

echo "Login as Manufacturer ... (or just continue as admin)"
echo "create new bash and run: composer-rest-server -a 'never' -c manufacturer_jo@drug_network"
read -p
echo "Creating drug ..."
# create drug
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.CreateDrug", "drugHash": "'$dafalganDrugHash'", "name": "Dafalgan", "metaData": { "$class": "org.drugs.DrugMetaData", "serialNumber": "'$dafalganSerialNumber'", "productCode": "'$dafalganProductCode'", "batchNumber": "'$dafalganBatchNumber'", "manufacturer": "resource:org.drugs.Manufacturer#'$manufacturerId'" } }' "$URI/api/CreateDrug"

echo ""
echo "Created drug '$dafalganDrugHash'"
echo "by Manufacturer '$manufacturerId'"

echo "Login as Distributer ..."
echo "create new bash and run: composer-rest-server (distributer_gene@drug_network)"
read -p
echo ""
echo "Distributer '$distributerId' receives drugs from manufacturer '$manufacturerId'"

# receive drug from manufacturer to distributer
curl


echo "Received drug from Manufacturer '$manufacturerId'"
echo "to Distributer '$distributerId'"

echo "Distributer verifies orgin ..."
# verify origin drug by distributer
curl 

echo "Login as Pharmacist ..."
echo "create new bash and run: composer-rest-server (pharmacist_leander@drug_network)"
read -p

# receive drug from distributer to pharmacist

echo "Distributer verifies orgin ..."
# verify origin drug by distributer
curl 

echo ""
echo "Received drug from Distributer '$distributerId'"
echo "to Distributer '$pharmacistId'"

echo "Login as Patient ..."
echo "create new bash and run: composer-rest-server (patient_cedric@drug_network)"