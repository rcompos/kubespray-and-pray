# Kubespray-and-pray # 

Deploy Kubernetes clusters with Kubespray on machines both virtual and physical.

```
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  (  scattered rays of light,             )
 (         honey bee communities,          )
  (             stir the winds of change  )
   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
          \   ^__^
           \  (oo)\_______
              (__)\       )\/\
                  ||----w |
                  ||     ||
```

## Description ##

Deploy Kubernetes clusters on virtual machines or baremetal (i.e. physical servers) using Kubespray and Ansible.  Default storage class provided by GlusterFS hyper-converged storage.  Whether you're in your datacenter or on your laptop, you can build Kubernetes clusters for evaluation, development or production.  All you need to bring to the table is a few machines to run the cluster.

__Kubernetes Node Operating Systems Supported:__

* Ubuntu 16.04 Xenial
* CentOS 7

This project provides a very simple deployment process for Kubernetes in the datacenter, on-premise, local vm's, etc.  System setup, disk prep, easy rbac and default storage all provided.  Kubespray, which is built on Ansible, automates cluster deployments and provides for flexibility in configuration. 

The Kubernetes cluster configs include the following component defaults:  
Container engine: _docker_  
Container network interface: _calico_  or _flannel_
Storage driver: _overlay2_  or _overlay_

Estimated time to complete: 1 hr  

## Requirements ##

General requirements:

* __Control Node:__ Where the Kubespray commands are run (i.e. laptop or jump host).  MacOS High Sierra, RedHat 7, CentOS 7 or Ubuntu Xenial all tested. Python 2 is a requirement.
* __Cluster Machines:__ Minimum of one, but at least three are recommended.  Physical or virtual.  Recommended minimum of 2gb ram per node for evaluation clusters. For a ready to use Vagrant environment clone _https://github.com/rcompos/vagrant-zero_ and run `vagrant up k8s0 k8s1 k8s2`.
* __Operating System:__ Ubuntu 16.04   (CentOS 7 is an open issue)
* __Container Storage Volume:__  Additional physical or virtual disk volume.  i.e. /dev/sdc
* __Persistent Storage Volume:__  Additional physical or virtual disk volume.  i.e. /dev/sdd
* __Hostname resolution:__  Ensure that cluster machine hostnames are resolvable in DNS or are listed in local hosts file.  The control node and all cluster vm's must have DNS resolution or /etc/hosts entries.  IP addresses may be used.

## Prepare Control Node ##

Prepare __control node__ where management tools are installed.  A laptop or desktop computer will be sufficient.  A jump host is fine too.


1. __Install Packages__ 

    a. Install Python 2 as requirement of Ansible.  

    _MacOS_: `$ brew install -vd python@2`  
    _RedHat 7_ or _CentOS 7_: `Python 2.7.5 installed by default`  
    _Ubuntu_: `$ apt install python2.7 python-pip`  

    b. Use Python package manager pip2 to install required packages on __control node__ including Ansible v2.4 (or newer) and python-netaddr.  

    `$ sudo -H pip2 install --updgrade pip`  
    `$ sudo -H pip2 install ansible kubespray`  

    c. _Debian_ or _Ubuntu_ control node also need:  

    `$ sudo apt-get install sshpass`

2. __Clone Repo__

    Clone kubespray-and-pray repository.  

    `$ cd; git clone https://bitbucket.org/solidfire/kubespray-and-pray`

## TLDR ##
---

A Kubernetes cluster can be rapidly deployed with the following steps.  See further sections for details of each step.  

1. Deploy Kubernetes  
   Prepare directory (inventory/default or custom) with Kubespray config files.  Update _inventory.cfg_, _all.yml_, _k8s-cluster.yml_ and _topology.json_.  Deploy cluster.  
   
        $ ./kubespray-and-pray.sh  

2. Kubernetes Access Controls  
   Insecure permissions for development only!  
   
        $ ansible-playbook dashboard-permissive.yml  

3. GlusterFS Distributed Storage  
   Hyper-converged storage solution consisting of a Gluster distributed filesystem running in the Kubernetes cluster.  Heketi provides a REST API for Gluster.  
   
        $ ansible-playbook gluster.yml  

---

## Deploy Kubernetes ##

The Kubernetes cluster topology is defined as masters, nodes and etcds.  Masters are cluster masters running the Kubernetes API service.  Nodes are worker nodes where pods will run.  Etcds are etcd cluster members, which serve as the state database for the Kubernetes cluster.

The following is an example _inventory.cfg_ defining a Kubernetes cluster with three members (all).  There are two masters (kube-master), three etcd members (etcd) and three worker nodes (kube-node).  There are also three GlusterFS (gluster) members defined.

The top lines with ansible\_ssh\_host and ip values are required since machines may have multiple network addresses.  Change the ansible\_ssh\_host and ip addresses in the file to actual ip addresses.  Lines or partial lines may be commented out with the pound sign (#).

Note:  The Heketi service will be assigned to a value of _ansible\_ssh\_host_ for a master node from the ansible inventory file (_~/.kubespray/inventory/inventory.cfg_).

For more examples see _inventory_ directory.  Pull the latest inventory files from the upstream kubespray repo under _inventory/samples_ directory.

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
node2
node3

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
node2

[gluster]
node1
node2
node3
    
[k8s-cluster:children]
kube-node
kube-master
```

Perform the following steps on the __control node__ where ansible command will be run from.  This might be your laptop or a jump host.  The cluster machines must already exist and be responsive to SSH.

1. __Kubernetes Cluster Topology__  
    
    Define your desired cluster topology ansible inventory and variables files.  These files are locate at _inventory/default_.  
    
    The file _ansible.cfg_ defines the ansible inventory file as _inventory/default/inventory.cfg_.
    
    __Multiple network adapters:__  If multiple network adapters are present on any node(s), Ansible will use the value provided as _ansible\_ssh\_host_ and/or _ip_ for each node.  For example: _k8s0 ansible\_ssh\_host=10.117.31.20 ip=10.117.31.20_.
    
    __Hyper-converged storage:__  Define Kubernetes cluster node members to be part of Heketi GlusterFS hyper-converged storage in inventory group _gluster_.

    __Kubespray cluster configuration:__  Edit Kubespray group variables in _all.yml_ and _k8s-cluster.yml_ to configure cluster to your needs.

    _inventory/default/all.yml_  
    _inventory/default/k8s-cluster.yml_  
    
    Modify inventory file with editor such as vi or nano.  
    
    `$ cd ~/kubespray-and-pray`  
    `$ vi inventory/default/inventory.cfg`  
    
    __Alternate Location:__  Create new directory under _inventory_ based on one of the example directories.  Update _inventory.cfg_ and other files.  Then specify this directory in the deployment step.

2. __Deploy Kubernetes Cluster__

    Run script to deploy Kubernetes cluster to machines specified in _inventory/default/inventory.cfg_ by default and optionally and entire directory such as _inventory/mycluster_.  If necessary, specify a user name to connect to via SSH to all cluster machines, a raw block device for container storage and the cluster inventory file.  
    
    __Deployment User__ _solidfire_ is used in this example.  This user account must already exist on the cluster nodes, and must have sudo privileges and must be accessible with password or key.  Supply the user's SSH password when prompted, then at second prompt press enter to use SSH password as sudo password.  Note: If you specify a user, then you must manually update the _ansible.cfg_ file.
     
    __Optional Container Volume__  To create a dedicated Docker container logical volume on an available raw disk volume, specify optional argument -b for _block_device_, such as _/dev/sdd_.  Otherwise default device is _/dev/sdc_.  If default block device not found, the _/var/lib/docker_ directory will by default, reside under the local root filesystem.  
    
    __Inventory Directory__  The Ansible inventory host configuration files are located by default in the directory _inventory/default_.  However this location can be specified with option -i. 
    

    Example:  kubespray-and-pray.sh -u myuser -b /dev/sdb -i dev20node
    
    Optional arguments for _kubespray-and-pray.sh_ are as follows.  If no option is specified the default values will be used.
    
    | Flag   | Description                            | Default     |
    |--------|----------------------------------------|-------------|
    | -u     | SSH username                           | solidfire   |
    | -b     | Block device for containers            | /dev/sdc    |
    | -i     | Inventory directory under _inventory_  | default     | 
    | -s     | Silence prompt Ansible SSH password    |             | 


    Run script to deploy Kubernetes cluster to all nodes with default values.

    `$ ./kubespray-and-pray.sh`

Congratulations!  Your cluster should be running.  Log onto a master node and run `kubectl get nodes` to validate.

__Scale out:__  Nodes may be added later by running the Kubespray _scale.yml_.

## Kubernetes Access Controls ##

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


## GlusterFS Distributed Storage ##

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


