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
        },
        'Pharmagenerix ': {
            'serialNumber': '4GF64CXW',
            'productCode': '3010-744',
            'batchNumber': '3',
            'drugStatus': 'VOID'
        }
    };

    // convert array names of people to be array of participant resources of type Patient with identifier of that name
    patients = patients.map((patient) => factory.newResource(NS, 'Patient', patient));

    // add the patients
    const patientRegistry = await getParticipantRegistry(NS + '.Patient');
    await patientRegistry.addAll(patients);

    // add the distributer
    let distributer = factory.newResource(NS, 'Distributer', 'Febelco');

    const distributerRegistry = await getParticipantRegistry(NS + '.Distributer');
    await distributerRegistry.add(distributer);

    // add the pharmacist
    let pharmacist = factory.newResource(NS, 'Pharmacist', 'Dessein');
    const pharmacistRegistry = await getParticipantRegistry(NS + '.Pharmacist');
    await pharmacistRegistry.add(pharmacist);

    // add the drugs & manufacturers
    let drugResources = [];
    let manufacturerResources = [];
    for (const manufacturer in drugs) {
        const manufacturerResource = factory.newResource(NS, 'Manufacturer', manufacturer);
        manufacturerResource.name = manufacturer;
        manufacturerResources.push(manufacturerResource);

        for (const drug in drugs[manufacturer]) {
            const drugsTemplate = drugs[manufacturer][drug];

            const newDrug = factory.newResource(NS, 'Drug', drugsTemplate.serialNumber);

            newDrug.serialNumber = drugsTemplate.serialNumber;
            newDrug.productCode = drugsTemplate.productCode;
            newDrug.batchNumber = drugsTemplate.batchNumber;
            newDrug.drugStatus = drugsTemplate.drugStatus;
            newDrug.name = drug;

            newDrug.manufacturer = manufacturerResource;

            drugResources.push(newDrug);
        }
    }

    // add the manufacturers
    const manufacturerRegistry = await getParticipantRegistry(NS + '.Manufacturer');
    await manufacturerRegistry.addAll(manufacturerResources);

    const drugsRegistry = await getAssetRegistry(NS + '.Drug');

    await drugsRegistry.addAll(drugResources);

}