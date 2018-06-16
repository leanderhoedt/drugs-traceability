# ./startFabrich.sh --> is fabric already started ??
# ./createPeerAdmin.sh --> is PeerAdmin card already generated??
# composer card delete -c admin@drug_network
#rm -rf ~/.composer
# sh ~/fabric-dev-servers/createPeerAdminCard.sh

function readJson {  
  UNAMESTR=`uname`
  if [[ "$UNAMESTR" == 'Linux' ]]; then
    SED_EXTENDED='-r'
  elif [[ "$UNAMESTR" == 'Darwin' ]]; then
    SED_EXTENDED='-E'
  fi; 

  VALUE=`grep -m 1 "\"${2}\"" ${1} | sed ${SED_EXTENDED} 's/^ *//;s/.*: *"//;s/",?//'`

  if [ ! "$VALUE" ]; then
    echo "Error: Cannot find \"${2}\" in ${1}" >&2;
    exit 1;
  else
    echo $VALUE ;
  fi; 
}


# generate sha256 of Dafalgan metadata
version=`readJson package.json version`

composer archive create -t dir -n .
composer network install --archiveFile drug_network@$version.bna --card PeerAdmin@hlfv1
composer network start --networkName drug_network --networkVersion $version --card PeerAdmin@hlfv1 --networkAdmin admin --networkAdminEnrollSecret adminpw
composer card import --file admin@drug_network.card
# composer-rest-server #admin@drug_network