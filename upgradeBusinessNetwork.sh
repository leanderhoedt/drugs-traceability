version=0.0.2
composer archive create -t dir -n .
composer network install --card PeerAdmin@hlfv1 --archiveFile drug_network@$version.bna
composer network upgrade --card PeerAdmin@hlfv1 -n drug_network -V $version
composer-rest-server
