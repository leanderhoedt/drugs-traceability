#!/bin/bash
# chmod +x script_clean.sh

URI="http://localhost:3000"

echo "Removing cards"

# delete cards

manufacturerId="jo"
manufacturerName="manufacturer_$manufacturerId"
distributerId="gene"
distributerName="distributer_$distributerId"
pharmacistId="leander"
pharmacistName="pharmacist_$pharmacistId"
patientId="cedric"
patientName="patient_$patientId"


composer card delete -c ${manufacturerName}@drug_network

composer card delete -c ${distributerName}@drug_network

composer card delete -c ${pharmacistName}@drug_network

composer card delete -c ${patientName}@drug_network

echo "end of removing cards"