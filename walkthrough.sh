#!/bin/bash
# chmod +x walkthrough.sh

URI="http://localhost:3000"

echo "Starting Drugs traceability workflow ..."
echo "2 participants will be created for each type"

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

dafalganSerialNumber=`readJson Dafalgan.json serialNumber`
dafalganProductCode=`readJson Dafalgan.json productCode`
dafalganBatchNumber=`readJson Dafalgan.json batchNumber`


# Create manufacturers

manufacturerId="jo"
manufacturerName="manufacturer_$manufacturerId"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.Manufacturer", "manufacturerId": "'$manufacturerId'", "name": "Jo Vercammen" }' "$URI/api/Manufacturer"
echo "Manufacturer [$manufacturerId] created"


# Create distributer

distributerId="gene"
distributerName="distributer_$distributerId"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.Distributer", "customerId": "'$distributerId'" }' "$URI/api/Distributer"
echo "Distributer [$distributerId] created"

 # Create pharmacist

pharmacistId="leander"
pharmacistName="pharmacist_$pharmacistId"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.Pharmacist", "customerId": "'$pharmacistId'" }' "$URI/api/Pharmacist"
echo "Pharmacist [$pharmacistId] created"

# Create patient

patientId="cedric"
patientName="patient_$patientId"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.Patient", "customerId": "'$patientId'" }' "$URI/api/Patient"
echo "Patient [$patientId] created"

echo ""
echo "Creating cards for each participant..."
echo ""
# Creating cards of participants
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/octet-stream' -d '{ "participant": "resource:org.drugs.Manufacturer#'$manufacturerId'", "userID":"'$manufacturerName'" }' "$URI/api/system/identities/issue" > ${manufacturerName}.card
echo "Created $manufacturerName.card"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/octet-stream' -d '{ "participant": "resource:org.drugs.Distributer#'$distributerId'", "userID":"'$distributerName'" }' "$URI/api/system/identities/issue" > ${distributerName}.card
echo "Created $distributerName.card"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/octet-stream' -d '{ "participant": "resource:org.drugs.Pharmacist#'$pharmacistId'", "userID":"'$pharmacistName'" }' "$URI/api/system/identities/issue" > ${pharmacistName}.card
echo "Created $pharmacistName.card"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/octet-stream' -d '{ "participant": "resource:org.drugs.Patient#'$patientId'", "userID":"'$patientName'" }' "$URI/api/system/identities/issue" > ${patientName}.card
echo "Created $patientName.card"

# Import cards of participants
echo ""
echo "Importing cards..."
echo ""
composer card import -f ./${manufacturerName}.card
composer card import -f ./${distributerName}.card
composer card import -f ./${pharmacistName}.card
composer card import -f ./${patientName}.card
echo "Finished importing cards"
