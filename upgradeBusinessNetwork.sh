# FIRST BUMP PACKAGE.JSON VERSION
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
composer network install --card PeerAdmin@hlfv1 --archiveFile drug_network@$version.bna
composer network upgrade --card PeerAdmin@hlfv1 -n drug_network -V $version
composer-rest-server #admin@drug_network
