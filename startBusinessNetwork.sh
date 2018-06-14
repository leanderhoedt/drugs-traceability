# ./startFabrich.sh --> is fabric already started ??
# ./createPeerAdmin.sh --> is PeerAdmin card already generated??
# composer card delete -c admin@drug_network
composer archive create -t dir -n .
composer network install --archiveFile drug_network@0.0.1.bna --card PeerAdmin@hlfv1
composer network start --networkName drug_network --networkVersion 0.0.1 --card PeerAdmin@hlfv1 --networkAdmin admin --networkAdminEnrollSecret adminpw
composer card import --file admin@drug_network.card
# composer-rest-server #admin@drug_network