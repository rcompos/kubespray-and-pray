#!/bin/bash
export PYTHONUNBUFFERED=1
KUSER=solidfire
KUBESPRAY_REPO=https://github.com/kubespray/kubespray.git

helpme() {
    echo "Usage: `basename $0` [-u user] [-i inventory] [-b block_device] [-y]"
    echo "  -u, --user        operating system user"
    echo "  -b, --block       block device"
    echo "  -i, --inventory   inventory directory"
    echo "  -y, --yes         continue"
    exit 1
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -u|--user)
    KUSER="$2"
    shift # past argument
    shift # past value
    ;;
    -i|--inventory)
    INVENTORY="$2"
    shift # past argument
    shift # past value
    ;;
    -b|--block)
    BLOCK="$2"
    shift # past argument
    shift # past value
    ;;
    -h|--help)
    helpme
    shift # past argument
    ;;
    -y|--yes|-Y)
    YES=1
    shift # past argument
    ;;
    #--default)
    #KUSER=solidfire
    #shift # past argument
    #;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo KUSER           = "${KUSER}"
echo INVENTORY       = "${INVENTORY}"
echo BLOCK           = "${BLOCK}"
#echo YES             = "${YES}"

if [ "$YES" != 1 ]; then
  while true; do
      read -p "Deploy Kubernetes cluster[y|yes]? " YES
      case $YES in
           [yY]  ) break;; 
           yes   ) break;; 
           [nN]* ) exit;;
           *     ) echo "Answer y or Y to continue.";;
      esac
  done
fi
#echo "Here we go: $YES"

mv ~/.kubespray ~/.kubespray.orig
git clone $KUBESPRAY_REPO ~/.kubespray
mv ~/.kubespray/inventory ~/.kubespray/inventory.orig
# Add conditional for INVENTORY
if [ ! -d "$INVENTORY" ]; then 
   INVENTORY="inventory/default"
fi
#cp -a inventory/default ~/.kubespray/inventory
cp -a $INVENTORY ~/.kubespray/inventory

# Run top-level ansible playbook to prepare all nodes for kubespray deploy
#ansible-playbook prep-cluster.yml -k -K -e user=$KUSER -e block_device=$BLOCK -e inv_src=$INVENTORY
ansible-playbook prep-cluster.yml -k -K -e user=$KUSER -e block_device=$BLOCK 

# Deploy Kubespray
kubespray deploy -y -u $KUSER

