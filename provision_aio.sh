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
NAME_OF_VM="cantu-${NAME}-${RPC_OR_OSA}"

# OpenStack releated variables
IMAGE=${IMAGE:-"8e7bdecd-380a-43d7-af9a-ec4f4df51dbd"}

MY_FLAVOR=${MY_FLAVOR:-""}

# Check to see if hostname is less than 20 characters
if [ $(echo $NAME_OF_VM | wc -m) -gt 20 ]; then
    echo "The hostname must be shorter"
    exit
fi

if [ "${RPC_OR_OSA}" == "osa" ]; then
    FLAVOR=${FLAVOR:-"8"}
else
    FLAVOR=${FLAVOR:-"performance2-30"}
fi

if [ "${4}" == 'metal' ] || [ "${3}" == 'metal' ]; then
    FLAVOR="onmetal-io2"
    # Use a different image for onmetal servers
    IMAGE="9dc2bf0a-7771-45cd-a7f9-ce86ce94c548"
fi

# Should the osa/rpc playbooks run?
if [ "${3}" == "nodeploy" ]; then
    NODEPLOY="_nodeploy"
else
    NODEPLOY=""
fi

if [ "${4}" == 'metal' ] || [ "${3}" == 'metal' ]; then
    METAL="_metal"
else
    METAL=""
fi

# The name of the cloud init config file to use.
# Right now there are serveral for each use case:
# * Running an RPC AIO with(out) running the playbooks
# * Running an OSA AIO with(out) running the playbooks
# * An on_metal server with OSA
PATH_TO_USER_CONFIG="/root/osa_rpc_aio_provisioner_scripts/cloud_init_configs/provision_${RPC_OR_OSA}_aio${NODEPLOY}${METAL}.yml"

# We might want to override the flavor is some cases.
if [ ! -z "$MY_FLAVOR" ]; then
    FLAVOR=$MY_FLAVOR
fi

# Actually creating the server..
openstack server create --image $IMAGE --flavor $FLAVOR --key-name=alex_pub_iad --config-drive=true --user-data ${PATH_TO_USER_CONFIG} ${NAME_OF_VM}
echo $PATH_TO_USER_CONFIG
