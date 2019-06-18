# Kubespray-and-Pray with OpenEBS # 

Make persistent storage available to your Kubernetes clusters with OpenEBS.

## Description ##

Once you have a running K8s cluster, you might realize you have a need for persistent data storage.

__Kubernetes Node Operating Systems Supported:__

* Ubuntu 16.04 Xenial
* CentOS 7

## Requirements ##

General requirements:

* __Cluster Machines:__ Minimum of one, but at least three are recommended.  Physical or virtual.  Recommended minimum of 2gb ram per node for evaluation clusters. For a ready to use Vagrant environment clone _https://github.com/rcompos/vagrant-zero_ and run `vagrant up k8s0 k8s1 k8s2`.
* __Node Operating System:__ Ubuntu 16.04   (CentOS 7 is an open issue)
* __Persistent Storage Volume:__  Additional physical or virtual disk volume.  i.e. /dev/sdd

## TLDR ##

A Kubernetes cluster can be rapidly deployed with the following steps.  See further sections for details of each step.  

1. Deploy K8s cluster on virtual or physical machines  

   Prepare directory (inventory/_cluster_name_) with _inventory.cfg_, _all.yml_, _k8s-cluster.yml_ .  Deploy cluster.  Substitute actual cluster name for _cluster\_name_.
   
        $ ./kap.sh -i _cluster\_name_

2. Kubernetes Access Controls  

   Insecure permissions for development only!  Use RBAC for production environments.
   
        $ ansible-playbook kubespray-08-dashboard-permissive.yml


## Define Storage Topology ##

The OpenEBS topology is defined in the inventory file.  

* OpenEBS distributed filesystem will be installed in members of the group openebs.  

The following is an example _inventory.cfg_ defining a Kubernetes cluster as well as the OpenEBS nodes.  Edit the relevant _inventory.cfg_ file for your cluster to define the nodes where OpenEBS will store data.  The nodes should be defined one per line under the _[openebs]_ group.

```
node1    ansible_ssh_host=192.168.1.50  ip=192.168.1.50
node2    ansible_ssh_host=192.168.1.51  ip=192.168.1.51
node3    ansible_ssh_host=192.168.1.52  ip=192.168.1.52
    
[all]
node1
node2
node3
    
[kube-master]
node1

[etcd]
node1
node2
node3
    
[kube-node]
node1
node2
node3

[kube-ingress]
node1

[openebs]  # OpenEBS nodes
node1
node2
node3
    
[k8s-cluster:children]
kube-node
kube-master
```

Perform the following steps on the __control node__ where ansible command will be run from.  This might be your laptop or a jump host.  The cluster machines must already exist and be responsive to SSH.

## Deploy OpenEBS ##

1. __Deploy OpenEBS__

    Run script to deploy OpenEBS cluster to machines specified in _inventory/default/inventory.cfg_.
    
    __Deployment User__ _solidfire_ is used in this example.  A user account must already exist on the cluster nodes, and must have sudo privileges and must be accessible with password or key.  Supply the user's SSH password when prompted, then at second prompt press enter to use SSH password as sudo password.  Note: If you specify a different remote user, then you must manually update the _ansible.cfg_ file.
     
    __Optional Container Volume__  To create a dedicated Docker container logical volume on an available raw disk volume, specify optional argument -b for _block_device_, such as _/dev/sdd_.  Otherwise default device is _/dev/sdc_.  If default block device not found, the _/var/lib/docker_ directory will by default, reside under the local root filesystem.  
    
    __Inventory Directory__  The Ansible inventory host configuration files are located by default in the directory _inventory/default_.  However this location can be specified with option -i. 
    

    Example:  kap.sh -u myuser -b /dev/sdb -i dev20node
    
    Optional arguments for _kap.sh_ are as follows.  If no option is specified the default values will be used.
    
    | Flag   | Description                            | Default     |
    |--------|----------------------------------------|-------------|
    | -u     | SSH username                           | solidfire   |
    | -b     | Block device for containers            | /dev/sdc    |
    | -i     | Inventory directory under _inventory_  | default     | 
    | -s     | Silence prompt Ansible SSH password    |             | 


    Run script to deploy Kubernetes cluster to all nodes with default values.

    `$ ./kap.sh`

Congratulations!  Your cluster should be running.  Log onto a master node and run `kubectl get nodes` to validate.

__Scale out:__  Nodes may be added later by running the Kubespray _scale.yml_.

## K8s Access Controls ##

***WARNING... Insecure permissions for development only!***

**MORE WARNING:** The following policy allows ALL service accounts to act as cluster administrators. Any application running in a container receives service account credentials automatically, and could perform any action against the API, including viewing secrets and modifying permissions. This is not a recommended policy... On other hand, works like charm for dev!

References:  
_https://kubernetes.io/docs/admin/authorization/rbac_

1. __Kubernetes Cluster Permissions__

   From __control node__, run script to configure open permissions.  Make note of dashboard port.  Run command from _kubespray-and-pray_ directory.

    `$ ansible-playbook dashboard-permissive.yml`  

2. __Access Kubernetes Dashboard__ 

   From web browser, access dashboard with following url. Use dashboard_port from previous command.  When prompted to login, choose _Skip_.

    `https://master-ip:dashboard-port`  


## GlusterFS Storage ##

This optional step creates a Kubernetes default storage class using the distributed filesystem GlusterFS, managed through Heketi REST API.  Providing a default storage class abstracts the application from the implementation.  Kubernetes application deployments can now claim storage without specifying what kind.

Requirement:  Additional raw physical or virtual disk.  The disk will be referenced by it's device name (i.e. _/dev/sdc_).

From the __control node__, configure hyper-converged storage solution consisting of a Gluster distributed filesystem running in the Kubernetes cluster.  Gluster cluster is managed by Heketi.  Raw storage volumes are defined in a topology file.

References:  
_https://github.com/heketi/heketi/blob/master/docs/admin/install-kubernetes.md_

1. __GlusterFS Cluster Topology__

    a. Define Heketi GlusterFS topology.  
   
    For each node block, the `hostnames.manage` value should be set to the node _FQDN_ and the `storage` value should be set to the node _IP address_.  The raw block device(s) (i.e. _/dev/sdd_) are specified under `devices`.  See _files/topology-sample.json_ for an example of multiple block devices per node.  Additional examples in the _files_ directory.  
   
    Edit file to define distributed filesystem members.  Modify file with editor such as vi or nano.

    `$ vi ~/kubespray-and-pray/inventory/default/topology.json`   

    b. Define Kubespray inventory nodes in gluster group.
    
    _It's safe to skip this step if gluster group was already defined in inventory.cfg during Kubespray deploy, as the gluster group will already be defined_.  
    
     Edit `gluster` section in Kubespray inventory file.  Specify which nodes are to become members of the GlusterFS distributed filesystem.  Modify file with editor such as vi or nano.  Copy to _.kubespray_ directory.

    `$ vi inventory/default/inventory.cfg`  
    `$ cp inventory/default/inventory.cfg ~/.kubespray/inventory`  

2. __Deploy Heketi GlusterFS__

    Run ansible playbook on all GlusterFS members to install kernel modules and glusterfs client.  The playbook  will be run against the `gluster` inventory group.  Run command from _kubespray-and-pray_ directory.

    `$ ansible-playbook gluster.yml`   

## Cluster Scale Out ##

Scale out cluster.  Run from base directory of kubespray-and-pray repository.

1. __Adjust Inventory File__

    Modify inventory file with editor such as vi or nano.  Add node(s).  

    `$ cd ~/kubespray-and-pray`  
    `$ vi inventory/default/inventory.cfg`  
     
2. __Run Scale Out Playbook__

    Run Kubespray scale-out playbook scale.yml.

    `$ cd ~/kubespray-and-pray`  
    `$ ansible-playbook ~/.kubespray/scale.yml -b -v`  

## Validation ##

Validate cluster functionality by deploying an application. Run on master or with appropriate _~/.kube/config_.

1. __Deploy Helm Package__  
     
    Install Helm package for Minio with 20Gi volume.  Modify volume size as needed.  Run from **master** or with appropriate _~/.kube/config_.

    `# helm install stable/minio -n minio --namespace minio --set service.type=NodePort --set persistence.size=11Gi`

2. __Get Port__ 
  
    Get port under PORT(S).  Make note of the second port value.

    `# kubectl get svc minio -n minio`

3. __View Service__

    Use any node IP address and the node port from previous step.

    `URL:  http://<node_ip>:<node_port>`
    
## References ##

_https://github.com/kubernetes/kubernetes/_  
_https://github.com/kubernetes-incubator/kubespray/_   
_https://hub.docker.com/r/heketi/heketi/tags/_  
_https://docs.gluster.org/en/v3/Install-Guide/Install/_  
_https://github.com/gluster/gluster-containers/_  
_https://github.com/heketi/heketi/releases/_  
_https://download.gluster.org/pub/gluster/glusterfs/4.0/_  
_https://heptio.github.io/ark/_ 


