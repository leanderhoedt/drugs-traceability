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
    const me = getCurrentParticipant();
    if (updateDrugStatusRequest.customer && me.getFullyQualifiedIdentifier() != updateDrugStatusRequest.customer.getFullyQualifiedIdentifier()) {
        throw new Error('The customer that you signed does not match your identity!');
    }

    drug.owner = me;
    if (updateDrugStatusRequest.distributer) {
        drug.distributer = updateDrugStatusRequest.distributer;
    }
    if (updateDrugStatusRequest.pharmacist) {
        drug.pharmacist = updateDrugStatusRequest.pharmacist;
    }

    const drugRegistry = await getAssetRegistry(NS + '.Drug');
    await drugRegistry.update(drug);

    // emit the event
    let updateDrugStatusEvent = factory.newEvent(NS, 'UpdateDrugStatusEvent');
    updateDrugStatusEvent.drugTransactionStatus = updateDrugStatusRequest.drugTransactionStatus;
    updateDrugStatusEvent.drug = drug;
    updateDrugStatusEvent.customer = updateDrugStatusRequest.customer;
    emit(updateDrugStatusEvent);
}


/**
 * Participants can verify the origin of the product
 * If drug exists, with the same serial number, but with wrong metadata, it's put in quarantine
 * 
 * @param {org.drugs.VerifyDrugs} drug - drug to verify 
 * @transaction 
 */
async function verifyOrigin(drug) {
    console.log('verifyOrigin');

    const factory = getFactory();
    const NS = 'org.drugs';

    const drugRegistry = await assetRegistry(NS + '.Drug');
    const origin = drugRegistry.get(drug.hash);
    if (!origin) {
        throw new Error('Drug does not exist');
    }

    // if doesn't match, throw error
    if (origin.serialNumber !== drug.serialNumber) {
        throw new Error('Serial Number does not match.');
    }

    // serial does match
    // but productCode doesn't correspond, place in quarantine
    if (origin.productCode !== drug.productCode) {
        placeInQuarantine(origin);
        throw new Error('Product code does not match.');
    }

    // but batchnumber doesn't correspond, place in quarantine
    if (origin.batchNumber !== drug.batchNumber) {
        placeInQuarantine(origin);
        throw new Error('Batch Number does not match.');
    }
    // but manufacturer doesn't correspond, place in quarantine
    if (origin.manufacturer !== drug.manufacturer) {
        placeInQuarantine(origin);
        throw new Error('Manufacturer does not match.');
    }

    if (origin.drugStatus === 'VOID') {
        throw new Error('Drug already placed in quarantine.');
    }

    // not necessary with permissions???
    //const me = getCurrentParticipant();
    //if(origin.owner && me.getFullyQualifiedIdentifier() != origin.owner.getFullyQualifiedIdentifier()){
    //    throw new Error('The current owner does not match your identity.');
    //}

    let originVerifiedEvent = factory.newEvent(NS, 'OriginVerified');
    originVerifiedEvent.drug = drugResource;
    originVerifiedEvent.customer = origin.customer;
    emit(originVerifiedEvent);

}

async function placeInQuarantine(drug) {
    const NS = 'org.drugs';
    const factory = getFactory();

    drug.drugStatus = 'VOID';

    const drugRegistry = await assetRegistry(NS, '.Drug');
    await drugRegistry.update(drug);

    let drugInQuarantineEvent = factory.newEvent(NS, 'DrugInQuarantine');
    drugInQuarantineEvent.drug = drug;
    emit(drugInQuarantineEvent);
}