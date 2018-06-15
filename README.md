# drugs-traceability

This business network defines:

**Participants**
`Manufacturer` `Distributer` `Pharmacist` `Patient`

**Assets**
`Drug`

**Transactions**
`CreateDrugs` `UpdateDrugStatus` `VerifyOrigin`

**Events**
`ReceiveDrugEvent` `DrugVerified` `DrugInQuarantine`

#Description
In this implementation of the drug traceability solution, we chose to add two statuses to a drug. One to indicate if a drug is valid/void/sold and one to track the drug through its lifetime. 
This allows us to set permissions easier and with more precision and keep void/sold drugs from being resold/distributed.
The second status we used to track the product. Again, this is done to make the permission model easier. We can now block drugs from transferring twice or from a Manufacturer to the Patient.

To make validation easier we created a DrugMetaData concept. This concept is used in the Drug asset itself and in the VerifyOrigin transaction. By using this we can easily identify the problem with an invalid drug. This is than logged via the DrugInQuarantine event.


##Permissions##
In our implementation we chose to allow participants to see themselves and others. We added some exceptions to this general rule. Manufacturers and Distributers can't see patients. This for privacy and patient safety reasons. The industry doesn't need to know what patient takes which drug. 
Drugs can be seen by everyone until they are sold. Once the drug is sold only the patient and the Pharmacy that sold the drug can still see this. 
The reason a Pharmacist can still see the drug is again for patient safety. It is important that a Pharmacist has a record of which drugs he sold to a patient. This is needed because the Pharmacist needs to make sure he doesn't give drugs that might conflict with each other to Patients.

All 'Customers' can verify a drug before buying this. We need to implement this in the front end of the application so before every buy transaction we do a validation. Once a drug is registered as invalid it is put into quarantine.


##Issues
**Hash**
We tried to generate the hash in the logic.js code. At first, we tried to import a library and use this to generate the hash. This is not possible though. We than decided that hashing should not happen on the chain logic. Hashing logic is now transferred to the client side of the application. Since this project does not include a front end we added the hashing code to the walkthrough script.

**Permissions**
We had some issues getting started with the permission model. The hyperledger documentation is good to get started but didn't give enough in-depth examples. To get around this we started out with allowing everyone to do everything. This allowed us to continue the logic and cto. Once we got more familiar with the permission model we started by restricting access slowly. Once we developed all the rules that where necessary we refactored these rules into a smaller more efficient set. 

##Possible improvements##
* Allow Pharmacists to view all drugs from a patient WITH permission of that patient.
* Mechanism to bring valid drugs that have been quarantined back in production (consensus)

#Run#
Run whole application:

1. cd ~/fabric-dev-servers
2. ./startFabric.sh
2. ./createPeerAdmin.sh
3. cd /pathto/drugs-traceability
5. ./walkthrough.sh
