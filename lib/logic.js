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
/* global getFactory getAssetRegistry */
/**
 * Write your transction processor functions here
 */

/**
 * We use the native transaction of 'create drug asset'
 * @param {org.drugs.CreateDrug} drug - The drug instance
 * @transaction
 */
async function createDrug(drugRequest) {
    console.log('createDrug');
    console.log(drugRequest);

    const factory = getFactory();
    const NS = 'org.drugs';

    let drugResource = factory.newResource('org.drugs', 'Drug', drugRequest.drugHash);
    drugResource.metaData = drugRequest.metaData;
    drugResource.name = drugRequest.name;
    drugResource.drugStatus = 'VALID';
    drugResource.drugTransactionStatus = 'CREATED';

    const mf = factory.newRelationship(NS, 'Manufacturer', drugRequest.metaData.manufacturer.getIdentifier());

    drugResource.metaData.manufacturer = mf;

    const drugRegistry = await getAssetRegistry(NS + '.Drug');
    await drugRegistry.add(drugResource);
}

/**
 * Receive the status of the drug
 * @param {org.drugs.ReceiveDrug} receiveDrugRequest - the ReceiveDrug transaction
 * @transaction
 */
async function receiveDrug(receiveDrugRequest) {
    console.log('receiveDrug');

    const factory = getFactory();
    const NS = 'org.drugs';

    console.log(receiveDrugRequest);
    // update the drug status
    let drug = receiveDrugRequest.drug;
    const currentParticipant = getCurrentParticipant();

    // THIS CHECK SHOULD BE ADDED IN A REAL WORLD APP
    if (receiveDrugRequest.customer && currentParticipant.getFullyQualifiedIdentifier() != receiveDrugRequest.customer.getFullyQualifiedIdentifier()) {
        throw new Error('The customer that you signed does not match your identity!');
    }

    const CQT = receiveDrugRequest.customer.getFullyQualifiedType().split(".").pop();
    console.log(CQT);
    drug.owner = factory.newRelationship(NS, CQT, receiveDrugRequest.customer.getIdentifier());

    // set Distributer to currentParticipant
    // set drugTransactionStatus to PHARMA
    if (CQT == 'Distributer') {
        drug.distributer = drug.owner;
        drug.drugTransactionStatus = 'DISTRIBUTED';
        // set Pharmacist to currentParticipant
        // set drugTransactionStatus to PHARMA
    } else if (CQT == 'Pharmacist') {
        drug.pharmacist = receiveDrugRequest.customer;
        drug.drugTransactionStatus = 'PHARMA';
    } else if (CQT == 'Patient') {
        // is it necessary to set 'patient' to the drug asset?
        drug.drugTransactionStatus = 'DELIVERED';
        drug.drugStatus = 'SOLD';
    } else {
        throw new Error('Type of customer does not match distributer, pharmacist nor patient');
    }

    const drugRegistry = await getAssetRegistry(NS + '.Drug');
    await drugRegistry.update(drug);

    // emit the event
    let receiveDrugEvent = factory.newEvent(NS, 'ReceiveDrugEvent');
    receiveDrugEvent.drug = drug;
    receiveDrugEvent.customer = receiveDrugRequest.customer;
    emit(receiveDrugEvent);
}


/**
 * Participants can verify the origin of the product
 * If drug exists, with the same serial number, but with wrong metadata, it's put in quarantine
 * 
 * @param {org.drugs.VerifyDrug} drug - drug to verify 
 * @transaction 
 */
async function verifyDrug(drug) {
    console.log('verifyOrigin');

    const factory = getFactory();
    const NS = 'org.drugs';

    const drugRegistry = await getAssetRegistry(NS + '.Drug');
    console.log(drug.drugHash);
    const originExists = await drugRegistry.exists(drug.drugHash);
    if (!originExists) {
        throw new Error('Drug does not exist');
    }
    const origin = await drugRegistry.get(drug.drugHash);
    console.log(origin.name);
    // if doesn't match, throw error
    if (origin.metaData.serialNumber !== drug.metaData.serialNumber) {
        await placeInQuarantine(origin);
    }

    // serial does match
    // but productCode doesn't correspond, place in quarantine
    if (origin.metaData.productCode !== drug.metaData.productCode) {
        await placeInQuarantine(origin);
    }

    // but batchnumber doesn't correspond, place in quarantine
    if (origin.metaData.batchNumber !== drug.metaData.batchNumber) {
        await placeInQuarantine(origin);
    }
    // but manufacturer doesn't correspond, place in quarantine
    if (origin.metaData.manufacturer.getIdentifier() !== drug.metaData.manufacturer.getIdentifier()) {
        await placeInQuarantine(origin);
    }

    if (origin.drugStatus === 'VOID') {
        throw new Error('Drug already placed in quarantine.');
    }

    let originVerifiedEvent = factory.newEvent(NS, 'DrugVerified');
    originVerifiedEvent.drug = origin;
    originVerifiedEvent.verifier = drug.verifier;
    emit(originVerifiedEvent);

}

async function placeInQuarantine(drug) {
    
    const factory = getFactory();
    const NS = 'org.drugs';

    const drugRegistry = await getAssetRegistry(NS + '.Drug');

    const origin = await drugRegistry.get(drug.drugHash);
    origin.drugStatus = 'VOID';
    console.log(origin.drugStatus);
    await drugRegistry.update(origin);

    let drugInQuarantineEvent = factory.newEvent(NS, 'DrugInQuarantine');
    drugInQuarantineEvent.drug = origin;
    emit(drugInQuarantineEvent);
}