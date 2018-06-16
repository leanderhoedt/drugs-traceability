#!/bin/bash
# chmod +x walkthrough.sh

URI="http://localhost:3000"

echo "Starting Drugs traceability workflow ..."
composer-rest-server -n 'never' -c admin@drug_network &
sleep 5
echo "composer rest server will be started with admin credentials"
echo "make sure you started the business network with startBusinessNetwork.sh"
sleep 10
#composer-rest-server -c admin@drug_network


echo "2 participants will be created for each type"

# Create manufacturers

manufacturerId="jo"
manufacturerName="manufacturer_$manufacturerId"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.Manufacturer", "manufacturerId": "'$manufacturerId'", "name": "Jo Vercammen" }' "$URI/api/Manufacturer"
echo "Manufacturer [$manufacturerId] created"

manufacturerIdSofie="Sofie"
manufacturerNameSofie="manufacturer_$manufacturerIdSofie"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.Manufacturer", "manufacturerId": "'$manufacturerIdSofie'", "name": "Sofie" }' "$URI/api/Manufacturer"
echo "Manufacturer [$manufacturerIdSofie] created"

# Create distributer

distributerId="gene"
distributerName="distributer_$distributerId"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.Distributer", "customerId": "'$distributerId'" }' "$URI/api/Distributer"
echo "Distributer [$distributerId] created"

distributerIdMarijn="marijn"
distributerNameMarijn="distributer_$distributerIdMarijn"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.Distributer", "customerId": "'$distributerIdMarijn'" }' "$URI/api/Distributer"
echo "Distributer [$distributerIdMarijn] created"
 # Create pharmacist

pharmacistId="leander"
pharmacistName="pharmacist_$pharmacistId"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.Pharmacist", "customerId": "'$pharmacistId'" }' "$URI/api/Pharmacist"
echo "Pharmacist [$pharmacistId] created"

pharmacistIdMichael="Michael"
pharmacistNameMichael="pharmacist_$pharmacistIdMichael"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.Pharmacist", "customerId": "'$pharmacistIdMichael'" }' "$URI/api/Pharmacist"
echo "Pharmacist [$pharmacistIdMichael] created"

# Create patient

patientId="cedric"
patientName="patient_$patientId"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.Patient", "customerId": "'$patientId'" }' "$URI/api/Patient"
echo "Patient [$patientId] created"

patientIdNico="nico"
patientNameNico="patient_$patientIdNico"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "$class": "org.drugs.Patient", "customerId": "'$patientIdNico'" }' "$URI/api/Patient"
echo "Patient [$patientIdNico] created"

echo ""
echo "Creating cards for each participant..."
echo ""
# Creating cards of participants
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/octet-stream' -d '{ "participant": "resource:org.drugs.Manufacturer#'$manufacturerId'", "userID":"'$manufacturerName'" }' "$URI/api/system/identities/issue" > ${manufacturerName}.card
echo "Created $manufacturerName.card"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/octet-stream' -d '{ "participant": "resource:org.drugs.Manufacturer#'$manufacturerIdSofie'", "userID":"'$manufacturerNameSofie'" }' "$URI/api/system/identities/issue" > ${manufacturerNameSofie}.card
echo "Created $manufacturerNameSofie.card"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/octet-stream' -d '{ "participant": "resource:org.drugs.Distributer#'$distributerId'", "userID":"'$distributerName'" }' "$URI/api/system/identities/issue" > ${distributerName}.card
echo "Created $distributerName.card"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/octet-stream' -d '{ "participant": "resource:org.drugs.Distributer#'$distributerIdMarijn'", "userID":"'$distributerNameMarijn'" }' "$URI/api/system/identities/issue" > ${distributerNameMarijn}.card
echo "Created $distributerNameMarijn.card"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/octet-stream' -d '{ "participant": "resource:org.drugs.Pharmacist#'$pharmacistId'", "userID":"'$pharmacistName'" }' "$URI/api/system/identities/issue" > ${pharmacistName}.card
echo "Created $pharmacistName.card"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/octet-stream' -d '{ "participant": "resource:org.drugs.Pharmacist#'$pharmacistIdMichael'", "userID":"'$pharmacistNameMichael'" }' "$URI/api/system/identities/issue" > ${pharmacistNameMichael}.card
echo "Created $pharmacistNameMichael.card"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/octet-stream' -d '{ "participant": "resource:org.drugs.Patient#'$patientId'", "userID":"'$patientName'" }' "$URI/api/system/identities/issue" > ${patientName}.card
echo "Created $patientName.card"
curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/octet-stream' -d '{ "participant": "resource:org.drugs.Patient#'$patientIdNico'", "userID":"'$patientNameNico'" }' "$URI/api/system/identities/issue" > ${patientNameNico}.card
echo "Created $patientNameNico.card"

# Import cards of participants
echo ""
echo "Importing cards..."
echo ""
composer card import -f ./${manufacturerName}.card
composer card import -f ./${manufacturerNameSofie}.card
composer card import -f ./${distributerName}.card
composer card import -f ./${distributerNameMarijn}.card
composer card import -f ./${pharmacistName}.card
composer card import -f ./${pharmacistNameMichael}.card
composer card import -f ./${patientName}.card
composer card import -f ./${patientNameNico}.card
echo "Finished importing cards"
echo ""

#echo "Creating identities ..."
#composer identity issue -u manufacturer1 -a "resource:org.drugs.Manufacturer#$manufacturerId" -f $manufacturerName.card -c admin@drug_network
#composer identity issue -u distributer1 -a "resource:org.drugs.Distributer#$distributerId" -f $distributerName.card -c admin@drug_network
#composer identity issue -u pharmacist1 -a "resource:org.drugs.Pharmacist#$pharmacistId" -f $pharmacistName.card -c admin@drug_network
#composer identity issue -u patient1 -a "resource:org.drugs.Patient#$patientId" -f $patientName.card -c admin@drug_network
#echo "Created identities"
kill $!
echo "Finished INIT SCRIPT"
