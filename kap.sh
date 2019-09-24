#!/bin/bash
export PYTHONUNBUFFERED=1
KUSER=solidfire
KUBESPRAY_REPO=https://github.com/kubernetes-sigs/kubespray.git
KUBESPRAY_TAG='v2.11.0'
INVDIR_DEFAULT=default
KUBEDIR="${HOME}/.kubespray"
INVDEST="${KUBEDIR}/inventory"
INVFILE="inventory.ini"
BLOCK_DEFAULT=/dev/sdb
SILENT_RUN=false
UPGRADE=false

helpme() {
    echo "Usage: `basename $0` [-o os_user] [-i inventory] [-l] [-b block_device] [-y] [-s] [-u]"
    echo 
    echo "Must be run from directory where `basename $0` resides."
    echo "  -o, --osuser      operating system user"
    echo "  -b, --block       block device where docker volume will reside (/dev/sdb)"
    echo "  -i, --inventory   inventory directory (dir name under inventory dirctory)"
    echo "  -l, --link        create symbolic link to inventory directory (use with -i)"
    echo "  -y, --yes         continue"
    echo "  -s, --silent      do not ask for ansible passwords"
    echo "  -u, --ugprade     upgrade cluster"
    exit 1
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -o|--osuser)
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
    -l|--link)
    LINK=1
    shift # past argument
    ;;
    -y|--yes|-Y)
    YES=1
    shift # past argument
    ;;
    -u|--upgrade)
    UPGRADE=true
    shift # past argument
    ;;
    -s|--silent)
    SILENT_RUN=true
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo "Kubespray-and-Pray"
echo
if [ ! -z $KUSER ];  then echo KUSER  = "$KUSER"; fi
if [ -z $INVDIR ]; then INVDIR="$INVDIR_DEFAULT"; fi
echo INVDIR = "${INVDIR}"
if [ -z $BLOCK ]; then BLOCK="$BLOCK_DEFAULT"; fi
echo BLOCK  = "$BLOCK"

# Check for passed in arg for directory under inventory dir
if [ ! -d "inventory/$INVDIR" ]; then 
   echo "Inventory directory not found! inventory/$INVDIR"
   exit 2
fi

echo
echo "Contents of inventory/$INVDIR/$INVFILE"
echo
cat -n inventory/$INVDIR/$INVFILE
echo

INVSRC="${PWD}/inventory/$INVDIR"
if [ ! -z $LINK ]; then
    echo "Remove existing symbolic link $INVDEST"
    if [ -L $INVDEST ]; then
        rm -f $INVDEST
    fi
    if [ ! -d $KUBEDIR ]; then
        mkdir $KUBEDIR
    fi
    echo "Create local symbolic link $INVDEST pointing to $INVSRC"
    echo "ln -s $INVSRC $INVDEST"
    ln -s $INVSRC $INVDEST
    exit 0
fi

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
if [ ! -z $KUBESPRAY_TAG ]; then
  BRANCH_STRING="--branch $KUBESPRAY_TAG --single-branch"
else
  BRANCH_STRING=""
fi

git clone $KUBESPRAY_REPO ~/.kubespray $BRANCH_STRING

if [ ! -d "inventory" ]; then 
   echo "ERROR: Directory inventory not found!"
   exit 3
fi

rm -fr ~/.kubespray/inventory

# Link inventory directory to active kubespray location
ln -s ${PWD}/inventory/$INVDIR ~/.kubespray/inventory

# Run top-level ansible playbook to prepare all nodes for kubespray deploy
if $SILENT_RUN; then
  ansible-playbook cluster-pre.yml -e user=$KUSER -e block_device=$BLOCK 
else
  ansible-playbook cluster-pre.yml -k -K -e user=$KUSER -e block_device=$BLOCK
fi

# Deploy Kubespray
#kubespray deploy -y -u $KUSER
if $UPGRADE; then  # Upgrade existing cluster
	echo "Upgrading cluster ..."
    kscript=upgrade-cluster.yml
else  	# Create new cluster
	echo "Creating cluster ..."
    kscript=cluster.yml
fi

#ansible-playbook -i ${PWD}/inventory/$INVDIR/$INVFILE --become --become-user=$KUSER $KUBEDIR/$kscript
ansible-playbook -i ${PWD}/inventory/$INVDIR/$INVFILE --become --become-user=root $KUBEDIR/$kscript
