#!/bin/bash

URI="http://localhost:3000"

read -p "Would you like to start the business network? (Y/N)" confirm
echo
if [[ $confirm =~ ^[Yy]$ ]]
then sh ./startBusinessNetwork.sh
fi

read -p "Would you like to initialize everything? (make sure the rest server is not running) (Y/N)" confirm
if [[ $confirm =~ ^[Yy]$ ]]
then sh ./initscript.sh
fi
echo "Environment has been setup."


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

echo "Login as Manufacturer ... "
composer-rest-server -n 'never' -c manufacturer_jo@drug_network &
sleep 5
read -p "Press any key to continue..."
echo "Creating drug ..."
#create drug
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.CreateDrug", "drugHash": "'$dafalganDrugHash'", "name": "Dafalgan", "metaData": { "$class": "org.drugs.DrugMetaData", "serialNumber": "'$dafalganSerialNumber'", "productCode": "'$dafalganProductCode'", "batchNumber": "'$dafalganBatchNumber'", "manufacturer": "resource:org.drugs.Manufacturer#'$manufacturerId'" } }' "$URI/api/CreateDrug"
echo ""
echo "Created drug '$dafalganDrugHash'"
echo "by Manufacturer '$manufacturerId'"
kill $!

echo "Login as Distributer ..."
composer-rest-server -n 'never' -c distributer_gene@drug_network &
sleep 5
read -p "Press any key to continue..."
echo ""
echo "Distributer verifies orgin ..."
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.VerifyDrug",  "metaData": { "$class": "org.drugs.DrugMetaData", "serialNumber": "'$dafalganSerialNumber'", "productCode": "'$dafalganProductCode'", "batchNumber": "'$dafalganBatchNumber'",  "manufacturer": "resource:org.drugs.Manufacturer#'$manufacturerId'" }, "drugHash": "'$dafalganDrugHash'", "verifier": "resource:org.drugs.Distributer#'$distributerId'" }' 'http://localhost:3000/api/VerifyDrug'
echo "Distributer '$distributerId' receives drugs from manufacturer '$manufacturerId'"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.drugs.ReceiveDrug", "customer": "resource:org.drugs.Distributer#'$distributerId'", "drug": "resource:org.drugs.Drug#'$dafalganDrugHash'" }' 'http://localhost:3000/api/ReceiveDrug'
echo ""
kill $!

echo "Login as Pharmacist ..."
composer-rest-server -n 'never' -c pharmacist_leander@drug_network &
read -p "Press any key to continue..."
echo ""
echo "Pharmacist verifies orgin ..."
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.VerifyDrug",  "metaData": { "$class": "org.drugs.DrugMetaData", "serialNumber": "'$dafalganSerialNumber'", "productCode": "'$dafalganProductCode'", "batchNumber": "'$dafalganBatchNumber'",  "manufacturer": "resource:org.drugs.Manufacturer#'$manufacturerId'" }, "drugHash": "'$dafalganDrugHash'", "verifier": "resource:org.drugs.Pharmacist#'$pharmacistId'" }' 'http://localhost:3000/api/VerifyDrug'
echo "Pharmacist '$pharmacistId' receives drugs from distributer '$distributerId'"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.drugs.ReceiveDrug", "customer": "resource:org.drugs.Pharmacist#'$pharmacistId'", "drug": "resource:org.drugs.Drug#'$dafalganDrugHash'" }' 'http://localhost:3000/api/ReceiveDrug'
kill $!

echo "Login as Patient ..."
composer-rest-server -n 'never' -c patient_cedric@drug_network &
sleep 5
read -p "Press any key to continue..."
echo ""
echo "Patient '$patientId' receives drugs from pharmacist '$pharmacistId'"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.drugs.ReceiveDrug", "customer": "resource:org.drugs.Patient#'$patientId'", "drug": "resource:org.drugs.Drug#'$dafalganDrugHash'" }' 'http://localhost:3000/api/ReceiveDrug'
kill $!