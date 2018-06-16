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

function main(){
  echo "Note that for the functions to run the init script has to have run once"
  echo "Please chose the simulation you'd like to run"
  echo "Press 1 for the happy path (default)"
  echo "Press 2 for simulating a Distributer trying to create a drug"
  echo "Press 3 for simulating a Patient trying to sell a drug"
  echo "Press 4 for simulating a Distributer quarantaining an invalid drug"
  echo "Press Q/q to quit"
  read -p "option: " path
  if [[ $path =~ '2' ]]
  then
    evil_distributer
  elif [[ $path == '3' ]]
  then 
    evil_patient
  elif [[ $path == '4' ]]
  then 
    quarantine_drug
  elif [[ $path =~ ^[Qq]$ ]]
  then 
    exit 0
  else
    happy_path
  fi
}

# Functions 
function quarantine_drug(){
  echo "Distributer marijn verifies a drug and this drug has been wrongly created."
  echo "The drug will be quarantained"
  # generate sha256 of Codaine metadata
  codaDrugHash=`sha256sum codaine.json | awk '{ print $1 }'`

  # get metadata of file
  codaSerialNumber=`readJson codaine.json serialNumber`
  codaProductCode=`readJson codaine.json productCode`
  codaBatchNumber=`readJson codaine.json batchNumber`

  manufacturerId="jo"
  distributerId="marijn"
  
  echo "Manufacturer creates medicine with wrong info ... "
  composer-rest-server -n 'never' -c manufacturer_jo@drug_network &
  sleep 5
  read -p "Press any key to continue..."
  echo "Creating faulty drug ..."
  #create drug
  curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.CreateDrug", "drugHash": "'$codaDrugHash'", "name": "codaine", "metaData": { "$class": "org.drugs.DrugMetaData", "serialNumber": "'$codaSerialNumber'", "productCode": "'$codaProductCode'", "batchNumber": "'$codaBatchNumber'", "manufacturer": "resource:org.drugs.Manufacturer#'$manufacturerId'" } }' "$URI/api/CreateDrug" | python -m json.tool
  echo ""
  echo "Created drug '$codaDrugHash'"
  echo "by Manufacturer '$manufacturerId'"
  curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'$codaDrugHash | python -m json.tool
  kill $!

  echo "Login as Distributer Marijn..."
  composer-rest-server -n 'never' -c distributer_marijn@drug_network &
  sleep 5
  read -p "Press any key to continue..."
  echo ""
  echo "Distributer verifies orgin ..."
  curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.VerifyDrug",  "metaData": { "$class": "org.drugs.DrugMetaData", "serialNumber": "1234-11", "productCode": "'$codaProductCode'", "batchNumber": "'$codaBatchNumber'",  "manufacturer": "resource:org.drugs.Manufacturer#'$manufacturerId'" }, "drugHash": "'$codaDrugHash'", "verifier": "resource:org.drugs.Distributer#'$distributerId'" }' 'http://localhost:3000/api/VerifyDrug' | python -m json.tool
  echo ""
  curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'$codaDrugHash | python -m json.tool
  kill $!
  
  main
}
function evil_patient(){
  echo "Patient cedric will try to launch a transaction that sells a drug he ownes to Nico."
  echo "An exception will be logged saying thay cedric has no right to execute the transaction"
  # generate sha256 of Dafalgan metadata
  paraDrugHash=`sha256sum paracetamol.json | awk '{ print $1 }'`

  # get metadata of file
  paraSerialNumber=`readJson paracetamol.json serialNumber`
  paraProductCode=`readJson paracetamol.json productCode`
  paraBatchNumber=`readJson paracetamol.json batchNumber`

  patientId="cedric"
  patientName="patient_$patientId"
  patientIdNico="nico"
  patientNameNico="patient_$patientId"


  echo "Login as Patient cedric ... "
  composer-rest-server -n 'never' -c patient_cedric@drug_network &
  sleep 5
  read -p "Press any key to continue..."
  echo "Selling drug to Nico ..."
  curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.drugs.ReceiveDrug", "customer": "resource:org.drugs.Patient#'$patientIdNico'", "drug": "resource:org.drugs.Drug#'$paraDrugHash'" }' 'http://localhost:3000/api/ReceiveDrug' | python -m json.tool
  echo ""
  echo "An error should be above, saying Patient Cedric has no permission to receive drug"
  read -p "Press any key to finish..."
  kill $!
  main
}

function evil_distributer(){
  echo "Distributer Gene will try to launch a transaction that creates a drug in Manufacturer Jo's name."
  echo "An exception will be logged saying thay Gene has no right to execute the transaction"
  # generate sha256 of Dafalgan metadata
  aranespDrugHash=`sha256sum Aranesp.json | awk '{ print $1 }'`

  # get metadata of file
  aranespSerialNumber=`readJson Aranesp.json serialNumber`
  aranespProductCode=`readJson Aranesp.json productCode`
  aranespBatchNumber=`readJson Aranesp.json batchNumber`

  manufacturerId="jo"
  manufacturerName="manufacturer_$manufacturerId"
  distributerId="gene"
  distributerName="distributer_$distributerId"
  pharmacistId="leander"
  pharmacistName="pharmacist_$pharmacistId"
  patientId="cedric"
  patientName="patient_$patientId"

   echo "Login as Distributer ..."
  composer-rest-server -n 'never' -c distributer_gene@drug_network &
  sleep 5
  read -p "Press any key to continue..."
  echo "Creating drug ..."
  #create drug
  curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.CreateDrug", "drugHash": "'$aranespDrugHash'", "name": "Aranesp", "metaData": { "$class": "org.drugs.DrugMetaData", "serialNumber": "'$aranespSerialNumber'", "productCode": "'$aranespProductCode'", "batchNumber": "'$aranespBatchNumber'", "manufacturer": "resource:org.drugs.Manufacturer#'$manufacturerId'" } }' "$URI/api/CreateDrug" | python -m json.tool
  echo ""
  echo "An error should be displayed above, Distributer gene can't create drug"
  read -p "Press any key to finish..."
  kill $!
  main
}

function happy_path(){
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
  curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.CreateDrug", "drugHash": "'$dafalganDrugHash'", "name": "Dafalgan", "metaData": { "$class": "org.drugs.DrugMetaData", "serialNumber": "'$dafalganSerialNumber'", "productCode": "'$dafalganProductCode'", "batchNumber": "'$dafalganBatchNumber'", "manufacturer": "resource:org.drugs.Manufacturer#'$manufacturerId'" } }' "$URI/api/CreateDrug" | python -m json.tool
  echo ""
  echo "Created drug '$dafalganDrugHash'"
  echo "by Manufacturer '$manufacturerId'"
  curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'$dafalganDrugHash | python -m json.tool
  kill $!

  echo "Login as Distributer ..."
  composer-rest-server -n 'never' -c distributer_gene@drug_network &
  sleep 5
  read -p "Press any key to continue..."
  echo ""
  echo "Distributer verifies orgin ..."
  curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.VerifyDrug",  "metaData": { "$class": "org.drugs.DrugMetaData", "serialNumber": "'$dafalganSerialNumber'", "productCode": "'$dafalganProductCode'", "batchNumber": "'$dafalganBatchNumber'",  "manufacturer": "resource:org.drugs.Manufacturer#'$manufacturerId'" }, "drugHash": "'$dafalganDrugHash'", "verifier": "resource:org.drugs.Distributer#'$distributerId'" }' 'http://localhost:3000/api/VerifyDrug' | python -m json.tool
  echo "Distributer '$distributerId' receives drugs from manufacturer '$manufacturerId'"
  curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.drugs.ReceiveDrug", "customer": "resource:org.drugs.Distributer#'$distributerId'", "drug": "resource:org.drugs.Drug#'$dafalganDrugHash'" }' 'http://localhost:3000/api/ReceiveDrug' | python -m json.tool
  echo ""
  curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'$dafalganDrugHash | python -m json.tool
  kill $!

  echo "Login as Pharmacist ..."
  composer-rest-server -n 'never' -c pharmacist_leander@drug_network &
  read -p "Press any key to continue..."
  echo ""
  echo "Pharmacist verifies orgin ..."
  curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.VerifyDrug",  "metaData": { "$class": "org.drugs.DrugMetaData", "serialNumber": "'$dafalganSerialNumber'", "productCode": "'$dafalganProductCode'", "batchNumber": "'$dafalganBatchNumber'",  "manufacturer": "resource:org.drugs.Manufacturer#'$manufacturerId'" }, "drugHash": "'$dafalganDrugHash'", "verifier": "resource:org.drugs.Pharmacist#'$pharmacistId'" }' 'http://localhost:3000/api/VerifyDrug' | python -m json.tool
  echo "Pharmacist '$pharmacistId' receives drugs from distributer '$distributerId'"
  curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.drugs.ReceiveDrug", "customer": "resource:org.drugs.Pharmacist#'$pharmacistId'", "drug": "resource:org.drugs.Drug#'$dafalganDrugHash'" }' 'http://localhost:3000/api/ReceiveDrug' | python -m json.tool
  curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'$dafalganDrugHash | python -m json.tool
  kill $!

  echo "Login as Patient ..."
  composer-rest-server -n 'never' -c patient_cedric@drug_network &
  sleep 5
  read -p "Press any key to continue..."
  echo ""
  echo "Patient '$patientId' receives drugs from pharmacist '$pharmacistId'"
  curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{"$class": "org.drugs.ReceiveDrug", "customer": "resource:org.drugs.Patient#'$patientId'", "drug": "resource:org.drugs.Drug#'$dafalganDrugHash'" }' 'http://localhost:3000/api/ReceiveDrug' | python -m json.tool
  curl -X GET --header 'Accept: application/json' 'http://localhost:3000/api/Drug/'$dafalganDrugHash | python -m json.tool
  kill $!
  main
}

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

# MAIN
main
