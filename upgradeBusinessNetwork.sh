version="0.0.2"
composer archive create -t dir -n .
composer network install --card PeerAdmin@hlfv1 --archiveFile drug_traceability@$version.bna
composer network upgrade --card PeerAdmin@hlfv1 -n drug_traceability -V $version
composer-rest-server
