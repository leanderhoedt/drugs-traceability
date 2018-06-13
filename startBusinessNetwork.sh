# ./startFabrich.sh --> is fabric already started ??
# ./createPeerAdmin.sh --> is PeerAdmin card already generated??
composer archive create -t dir -n .
composer network install --archiveFile drug_network@1.0.0.bna --card PeerAdmin@hlfv1
composer network start --networkName drug_network --networkVersion 1.0.0 --card PeerAdmin@hlfv1 --networkAdmin admin --networkAdminEnrollSecret adminpw
