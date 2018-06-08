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
const generateRandomNumber = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;
const generateRandomChar = () => {
    const chars = "1234567890ABCDEFGIJKLMNOPQRSTUVWXYZ";
    const randomNumber = generateRandomNumber(0, chars.length - 1);
    return chars[randomNumber];
}

const generateSerialNumber = () => {
    let serialNumber = '';
    const mask = '00000-00000-00000-00000-00000';
    if (mask != null) {
        mask.array.forEach(element => {
            serialNumber += element == '0' ? generateRandomChar() : element;
        });
    }
}

async function transferDrugs(trade) {
    console.log(trade);
    const NS = 'org.drugs';
    const factory = getFactory();

    const me = getCurrentParticipant();

    trade.drugs.issuer = me;
    trade.drugs.owner = trade.newOwner;
    //trade.drugs.orderStatus = trade.

    return getAssetRegistry('org.drugs')
        .then(() => {
            return assetRegistry.update(trade.drugs);
        })
}

async function produceDrugs(trade) {
    console.log('initiate drugs');

    const factory = getFactory();
    const NS = 'org.drugs';

    const drug = factory.newResource(NS, 'Drug', trade.drugsId);
    drug.orderStatus = 'CREATED';
    drug.serialNumber = serialNumber;
    drug.batchNumber = '';
    drug.manufacturer = trade.drugs.issuer;

    const serialNumber = generateSerialNumber();
}

async function wholeSalerVerify(trade) {
    console.log('whole soler verifies')
}

async function pharmacistVerifies(trade) {
    console.log('pharmacist verifies origin of product');
}

async function patientVerifies(trade) {
    console.log('patient verifies the origin of the product');
}

/**
 * Sample transaction
 * @param {org.drugs.SampleTransaction} sampleTransaction
 * @transaction
 */
async function sampleTransaction(tx) {
    // Save the old value of the asset.
    const oldValue = tx.asset.value;

    // Update the asset with the new value.
    tx.asset.value = tx.newValue;

    // Get the asset registry for the asset.
    const assetRegistry = await getAssetRegistry('org.drugs.SampleAsset');
    // Update the asset in the asset registry.
    await assetRegistry.update(tx.asset);

    // Emit an event for the modified asset.
    let event = getFactory().newEvent('org.drugs', 'SampleEvent');
    event.asset = tx.asset;
    event.oldValue = oldValue;
    event.newValue = tx.newValue;
    emit(event);
}
