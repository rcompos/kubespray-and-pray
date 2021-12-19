# Kubespray-and-Pray with OpenEBS # 

Make persistent storage available to your Kubernetes clusters with OpenEBS.

## Description ##

Once you have a running K8s cluster, you might realize you have a need for persistent data storage.  Once OpenEBS is installed, you can create persistent volumes with the default storage class or other available classes.

https://github.com/openebs/charts/tree/master/charts/openebs

__Kubernetes Node Operating Systems Supported:__

* Ubuntu 16.04 Xenial
* CentOS 7

## Requirements ##

General requirements:  
1. Existing Kubernetes cluster  
2. Disk device available  

## Install OpenEBS ##

Install OpenEBS to allow service exposure via ingress.

1. __Change to Repo Directory__

    Change to the cloned repository directory.

   `cd ~/kubespray-and-pray`

2. __Specify Target Cluster__

   Specify target cluster. Substitute actual cluster name for _\<cluster\>_.

   `./kap.sh -i <cluster> -l`

3. __Verify Target Cluster__

   Verify target cluster. Substitute actual cluster name for _\<cluster\>_.

   `ansible all -m ping`

4. __Deploy Ingress__

    Run Ansible playbook to deploy ingress-nginx.  Substitute the actual name of the block device that already exists on the nodes.

   `ansible-playbook openebs/openebs.yml -e block_device_openebs=/dev/sdd`

5. __Verify Ingress__

    Run Ansible playbook to validate Nginx ingress.

   `kubectl get all -n openebs`
   
5. __Verify Storageclass__

    Run Ansible playbook to validate kubernetes storage classes.

   `kubectl get storageclass`