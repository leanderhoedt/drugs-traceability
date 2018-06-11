/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

'use strict';
/**
 * Write your transction processor functions here
 */

/**
 * Update the status of the drug
 * @param {org.drugs.UpdateDrugStatus} updateDrugStatus - the UpdateDrugStatus transaction
 * @transaction
 */
async function updateDrugStatus(updateDrugStatusRequest) {
    console.log('updateDrugStatus');

    const factory = getFactory();
    const NS = 'org.drugs';

    console.log(updateDrugStatusRequest);
    // update the drug status
    let drug = updateDrugStatusRequest.drug;
    drug.owner = updateDrugStatusRequest.customer;
    if (updateDrugStatusRequest.distributer) {
        drug.distributer = updateDrugStatusRequest.distributer;
    }
    if (updateDrugStatusRequest.pharmacist) {
        drug.pharmacist = updateDrugStatusRequest.pharmacist;
    }

    const drugRegistry = await getAssetRegistry(NS + '.Drug');
    await drugRegistry.update(drug);

    // emit the event
    const updateDrugStatusEvent = factory.newEvent(NS, 'UpdateDrugStatusEvent');
    updateDrugStatusEvent.drugTransactionStatus = updateDrugStatusRequest.drugTransactionStatus;
    updateDrugStatusEvent.drug = drug;
    updateDrugStatusEvent.customer = updateDrugStatusRequest.customer;
    emit(updateDrugStatusEvent);
}

/**
 * We use the native transaction of 'create drug asset'
 * @param {org.drugs.CreateDrug} drug - The drug instance
 * @transaction
 */
async function createDrug(drug) {
    console.log('createDrug');
    console.log(drug);

    const factory = getFactory();
    const NS = 'org.drugs';

    const drugHash = sha256({
        serialNumber: drug.serialNumber,
        productCode: drug.productCode,
        batchNumber: drug.batchNumber,
        manufacturer: drug.manufacturer
    });

    let drugResource = factory.newResource('org.drugs', 'Drug', drugHash);
    drugResource.serialNumber = drug.serialNumber;
    drugResource.productCode = drug.productCode;
    drugResource.batchNumber = drug.batchNumber;
    drugResource.manufacturer = drug.manufacturer;

    const drugRegistry = await getParticipantRegistry(NS + '.Drug');
    await drugRegistry.add(drugResource);
}

/**
 * 
 * @param {org.drugs.VerifyOrigin} origin - origin drug 
 */
async function verifyOrigin(origin) {
    console.log('verifyOrigin');

    const factory = getFactory();
    const NS = 'org.drugs';
    
    if(origin.drugTransactionStatus === 'VOID') {
        throw new Error('Drug already placed in quarantine');
    }
}
