composer archive create -t dir -n .
composer network install --archiveFile tutorial-network@1.0.0.bna --card PeerAdmin@fabric-network
composer network start --networkName tutorial-network --networkVersion 1.0.0 --card PeerAdmin@fabric-network --networkAdmin admin --networkAdminEnrollSecret adminpw
