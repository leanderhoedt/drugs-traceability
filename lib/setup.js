/* global getFactory getParticipantRegistry getAssetRegistry */

/**
 * Setup the demo
 * @param {org.drugs.SetupDemo} setupDemo - the SetupDemo transaction
 * @transaction
 */
async function setupDemo() {
    console.log('setupDemo');

    const NS = 'org.drugs';
    const factory = getFactory();
    let patients = ['Leander', 'Cedric', 'Jo', 'Gene'];
    let manufacturers;

    const drugs = {
        'Omega Pharma': {
            'Aranesp': {
                'serialNumber': '5R2P2TH8',
                'productCode': '2225-613',
                'batchNumber': '1',
                'drugStatus': 'VALID'
            },
            'Dafalgan': {
                'serialNumber': '3GF64CXW',
                'productCode': '3010-733',
                'batchNumber': '2',
                'drugStatus': 'VALID'
            }

        },
        'Pfizer': {
            'Brufen': {
                'serialNumber': 'ZL9SQ9DD',
                'productCode': '3491-875',
                'batchNumber': '1',
                'drugStatus': 'VALID'
            }
        }
    };

    // convert array names of people to be array of participant resources of type Patient with identifier of that name
    patients = patients.map((patient) => factory.newResource(NS, 'Patient', patient));

    // create array of Manufacterer participant resources identified by the top level keys in drugs
    manufacturers = Object.keys(drugs).map((manufacturer) => {
        const manufacturerResource = factory.newResource(NS, 'Manufacturer', manufacturer);
        manufacturerResource.name = manufacturer;
        return manufacturerResource;
    });

    // add the manufacturers
    const manufacturerRegistry = await getParticipantRegistry(NS + '.Manufacturer');
    await manufacturerRegistry.addAll(manufacturers);
   
    const drugResources = [];
    for (const manufacturer in drugs) {
        for (const drug in drugs[manufacturer]) {
            const drugsTemplate = drugs[manufacturer][drug];

            const newDrug = factory.newResource(NS, 'Drug', drugsTemplate.serialNumber);

            newDrug.serialNumber = drugsTemplate.serialNumber;
            newDrug.productCode = drugsTemplate.productCode;
            newDrug.batchNumber = drugsTemplate.batchNumber;
            newDrug.drugStatus = drugsTemplate.drugStatus;
            newDrug.name = drug;
            newDrug.manufacturer = factory.newResource(NS, 'Manufacturer', manufacturer);

            drugResources.push(newDrug);
        }
    }

    const drugsRegistry = await getAssetRegistry(NS + '.Drug');

    await drugsRegistry.addAll(drugResources);

}