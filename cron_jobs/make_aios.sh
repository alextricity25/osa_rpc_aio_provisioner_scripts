#!/bin/bash

# Variables
# Number used to keep track of how many VMs
# are associated with a particular PR.
NUM=0

# Function that checks if an instances with a given name
# already exists
function vm_exists () {
  pushd /root/
    source envs/bin/activate
    source ~/openrc
    SERVERS=$(openstack server list | grep cantu)
    for SERVER in $SERVERS; do
      if [ "$(echo ${1} | cut -d- -f2)" == $(echo $SERVER | cut -d- -f2) ]; then
        echo "Instance already exists for this PR. Extracting number.."
        NUM=$(echo $server | cut -d- -f3)
        NUM=$((NUM + 1))
        return 1
      fi
    done;
  popd
}
# From now on, my branch titles will be written like so:
# cantu/issue/<bug#>
# Note: the naming convention for my VMS are:
# cantu-<bug#>-<num>-rpc
pushd /tmp
  git clone --recursive https://github.com/rcbops/rpc-openstack
  pushd rpc-openstack
    MY_BRANCHES=$(git branch --all | grep -Ei 'alex|cantu')
    for BRANCH in $MY_BRANCHES; do
      echo "processing branch: ${BRANCH}"
      BUG_NUMBER=$(echo $BRANCH | rev | cut -d'/' -f1 | rev)
      # Check to see if there is already a VM for this PR.
      # If so, increment the number.
      vm_exists "cantu-${BUG_NUMBER}"
      echo "provisioning...cantu-${BUG_NUMBER}-${NUM}-rpc"
      provision_aio.sh rpc ${BUG_NUMBER}-${NUM}
    done
  popd
  echo "Removing the repository..."
  rm -rf rpc-openstack
popd

    
