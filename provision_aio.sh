#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage ./provision-aio.sh <osa-or-rpc> <name> [nodeploy] [metal]"
    exit
fi

source /root/envs/bin/activate
source /root/openrc

DATE=$(date --rfc-3339=date | cut -d'-' -f2-3)
RPC_OR_OSA="${1}"
NAME="${2}"
NAME_OF_VM="cantu-${NAME}-${DATE}-${RPC_OR_OSA}"
IMAGE="8e7bdecd-380a-43d7-af9a-ec4f4df51dbd"
MY_FLAVOR=${MY_FLAVOR:-""}


if [ "${RPC_OR_OSA}" == "osa" ]; then
    FLAVOR="7"
else
    FLAVOR="general1-8"
fi

if [ "${4}" == 'metal' ]; then
    FLAVOR="onmetal-io2"
    IMAGE="9dc2bf0a-7771-45cd-a7f9-ce86ce94c548"
fi

# Should the osa/rpc playbooks run?
if [ "${3}" == "nodeploy" ]; then
    NODEPLOY="_nodeploy"
else
    NODEPLOY=""
fi

if [ "${4}" == 'metal' ]; then
    METAL="_metal"
else
    METAL=""
fi

PATH_TO_USER_CONFIG="/root/osa_rpc_aio_provisioner_scripts/bash_scripts/provision_${RPC_OR_OSA}_aio${NODEPLOY}${METAL}.yml"

# We might want to override the flavor is some cases.
if [ ! -z "$MY_FLAVOR" ]; then
    FLAVOR=$MY_FLAVOR
fi

# Creating the VM and installing the rpc AIO using our custom repo
## If metal, don't inject user-data
openstack server create --image $IMAGE --flavor $FLAVOR --key-name=alex_pub_iad --config-drive=true --user-data ${PATH_TO_USER_CONFIG} ${NAME_OF_VM}
