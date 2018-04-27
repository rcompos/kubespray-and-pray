#!/bin/bash
export PYTHONUNBUFFERED=1
KUSER=solidfire
KUBESPRAY_REPO=https://github.com/kubespray/kubespray.git
KUBESPRAY_INV=~/.kubespray/inventory
INVDIR_DEFAULT=inventory/default

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
    INVDIR="$2"
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

echo "Kubespray-and-Pray"
echo
if [ ! -z ${KUSER} ];  then  echo KUSER  = "${KUSER}"; fi
if [ ! -z ${INVDIR} ]; then  echo INVDIR = "${INVDIR}"; fi
if [ ! -z ${BLOCK} ];  then  echo BLOCK  = "${BLOCK}"; fi
#echo YES             = "${YES}"

# Check for passed in arg
if [ ! -d "$INVDIR" ]; then 
   INVDIR=$INVDIR_DEFAULT   ##echo "IF $INVDIR"; else echo "ELSE $INVDIR"
fi

echo
echo "Contents of $INVDIR/inventory.cfg:"
echo
cat -n $INVDIR/inventory.cfg
echo

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

# Clone Kubespray git repository
git clone $KUBESPRAY_REPO ~/.kubespray

# Create backup of original inventory dir
if [ ! -d "$KUBESPRAY_INV-orig" ]; then 
   mv $KUBESPRAY_INV $KUBESPRAY_INV-orig
else
   rm -fr $KUBESPRAY_INV-old
   mv $KUBESPRAY_INV $KUBESPRAY_INV-old
fi

# Copy inventory directory to active kubespray location
cp -a $INVDIR $KUBESPRAY_INV

# Run top-level ansible playbook to prepare all nodes for kubespray deploy
ansible-playbook prep-cluster.yml -k -K -e user=$KUSER -e block_device=$BLOCK 

# Deploy Kubespray
kubespray deploy -y -u $KUSER

