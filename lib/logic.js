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
  * Manufacterer can produce a drug
  * @param {org.drugs.Drug} tx - the drug
  */
async function produceDrug(tx) {
    console.log('produce drugs');

    const factory = getFactory();
    const NS = 'org.drugs';

    const drug = factory.newResource(NS, 'Drug', tx.serialNumber);
    drug.orderStatus = 'CREATED';
    drug.serialNumber = tx.serialNumber;
    drug.batchNumber = tx.batchNumber;
    drug.manufacturer = tx.issuer;

    await assetRegistry.update(drug);

    const produceDrugEvent = factory.newEvent(NS, 'ProduceDrugEvent');
    emit(produceDrugEvent);
}

async function transferDrugs(trade) {
    console.log('transferDrugs');
    console.log(tx);
    const NS = 'org.drugs';
    const assetRegistry = await getAssetRegistry(NS);

    const me = getCurrentParticipant();

    tx.drugs.issuer = me;
    tx.drugs.owner = tx.newOwner;
    tx.drugs.orderStatus = tx.orderStatus

    console.log(trade);
    await assetRegistry.update(trade);

    const transferDrugEvent = getFactory().newEvent(NS, 'TransferDrugEvent');
    emit(transferDrugEvent);
}

async function wholeSalerVerify(trade) {
    console.log('whole soler verifies');
}

async function pharmacistVerifies(trade) {
    console.log('pharmacist verifies origin of product');
}

async function patientVerifies(trade) {
    console.log('patient verifies the origin of the product');
}
