#!/bin/bash
# chmod +x walkthrough.sh

URI="http://localhost:3000"

echo "Starting Drugs traceability workflow ..."

echo "composer rest server will be started with admin credentials"
echo "make sure you started the business network with startBusinessNetwork.sh"
composer-rest-server -c admin@drug_network
sleep 3

echo "2 participants will be created for each type"

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
echo ""

echo "Creating identities ..."

composer identity issue -u manufacturer1 -a "resource:org.drugs.Manufacturer#$manufacturerId" -f $manufacturerName.card -c admin@drug_network
composer identity issue -u distributer1 -a "resource:org.drugs.Distributer#$distributerId" -f $distributerName.card -c admin@drug_network
composer identity issue -u pharmacist1 -a "resource:org.drugs.Pharmacist#$pharmacistId" -f $pharmacistName.card -c admin@drug_network
composer identity issue -u patient1 -a "resource:org.drugs.Patient#$patientId" -f $patientName.card -c admin@drug_network

echo "Created identities"
echo "Finished INIT SCRIPT"