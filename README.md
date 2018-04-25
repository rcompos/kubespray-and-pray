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

Deploy Kubernetes clusters on virtual machines or baremetal (i.e. physical servers) using Kubespray and Ansible.  Whether you're in your datacenter or on your laptop, you can build Kubernetes clusters for evaluation, development or production.  All you need to bring to the table is a few machines to run the cluster.

__Kubernetes Node Operating Systems Supported:__  Ubuntu 16.04 Xenial  (CentOS 7 soon)

The tool used to do the heavy lifting is Kubespray which is built on Ansible.  Kubespray automates the cluster deployments and provides for flexibility in configuration.

This project provides a very simple deployment process for Kubernetes in the datacenter, on-premise, local vm's, etc.  System setup, disk prep, easy rbac and 

The Kubernetes cluster configs include the following component defaults:  
Container engine: _docker_  
Container network interface: _calico_  
Storage driver: _overlay2_  

Estimated time to complete: 1 hr

References:  
_https://github.com/kubernetes/kubernetes_  
_https://github.com/kubernetes-incubator/kubespray_   

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

    `$ sudo -H pip2 install ansible kubespray`  

    c. _Debian_ or _Ubuntu_ control node also need:  

    `$ sudo apt-get install sshpass`

2. __Clone Repo__

    Clone kubespray-and-pray repository.  

    `$ cd; git clone https://github.com/scandalizer/kubespray-and-pray`


## Deploy Kubernetes ##

The cluster topology is defined as masters, nodes and etcds.  Masters are cluster masters running the Kubernetes API service.  Nodes are worker nodes where pods will run.  Etcds are etcd cluster members, which serve as the state database for the Kubernetes cluster.

The following is an example _inventory.cfg_ defining a Kubernetes cluster with three members (all).  There are two masters (kube-master), three etcd members (etcd) and three worker nodes (kube-node).  There are also three GlusterFS (gluster) members defined.

The top lines with ansible\_ssh\_host and ip values are required if machines have multiple network addresses, otherwise may be omitted.  Change the ip addresses in the file to actual ip addresses.  Lines or partial lines may be commented out with the pound sign (#).

For more examples see the _inventory-*.cfg_ files in the directory _files_ and under _inventory_.

```
k8s0    ansible_ssh_host=192.168.1.60  ip=192.168.1.60
k8s1    ansible_ssh_host=192.168.1.61  ip=192.168.1.61
k8s2    ansible_ssh_host=192.168.1.62  ip=192.168.1.62
    
[all]
k8s0
k8s1
k8s2
    
[kube-master]
k8s0
k8s1

[kube-node]
k8s0
k8s1
k8s2
    
[etcd]
k8s0
k8s1
k8s2
    
[gluster]
k8s0
k8s1
k8s2
    
[k8s-cluster:children]
kube-node
kube-master
```

Perform the following steps on the __control node__ where ansible command will be run from.  This might be your laptop or a jump host.  The cluster machines must already exist and be responsive to SSH.

1. __Define Cluster Topology__  
    
    Define your desired cluster topology.  Modify inventory file with editor such as vi or nano.

    `$ cd ~/kubespray-and-pray`  
    `$ vi files/inventory.cfg`  
    
    The file _ansible.cfg_ defines the ansible inventory file as _~/.kubespray/inventory/inventory.cfg_.  One of the ansible playbooks will copy the edited _inventory.cfg_ to _~/.kubespray/inventory_. This will be the default inventory file when Kubespray is run.
    
    __Multiple network adapters__:  If multiple network adapters are present on any node(s), Ansible will use the value provided as ansible\_ssh\_host and/or ip for each node.  For example: _k8s0 ansible\_ssh\_host=10.117.31.20 ip=10.117.31.20_.
    
    __Scale out:__  Nodes may be added later by running the Kubespray _scale.yml_.

    __Optional Cluster Configuration:__  Edit Kubespray group variables in _all.yml_ and _k8s-cluster.yml_ to configure cluster to your needs.

    _kubespray-and-pray/files/all.yml_  
    _kubespray-and-pray/files/k8s-cluster.yml_  

2. __Deploy Cluster__

    Run script to deploy Kubernetes cluster to machines specified in inventory.cfg.  If necessary, specify a user name to connect to via SSH to all cluster machines, a raw block device for container storage and the cluster inventory file.  
    
    User _solidfire_ is used in this example.  This user account must already exist on the cluster nodes, and must have sudo privileges and must be accessible with password or key.  Supply the user's SSH password when prompted, then at second prompt press enter to use SSH password as sudo password.  Note: If you specify a user, then you must manually update the _ansible.cfg_ file.
     
    __Optional Container Volume:__  To create a dedicated Docker container logical volume on an available raw disk volume, specify optional argument -b for _block_device_, such as _/dev/sdd_.  Otherwise default device is _/dev/sdc_.  If default device not found, the _/var/lib/docker_ directory will by default, reside under the local root filesystem.

    Example:  pray-for-cluster.sh -u myuser -b /dev/sdb -i inventory-20node.cfg
    
    Optional arguments for _pray-for-cluster_ are as follows.  If no option is specified the default values will be used.
    | Flag   | Description                          | Default       |
    |--------|--------------------------------------|---------------|
    | -u     | SSH username                         | solidfire     |
    | -b     | Block device for containers          | /dev/sdc      |
    | -i     | Inventory file in directory _files_  | inventory.cfg |

    Run script to deploy Kubernetes cluster to all nodes.

    `$ ./pray-for-cluster.sh`

Congratulations!  Your cluster should be running.  Log onto a master node and run `kubectl get nodes` to validate.


## Kubernetes Dashboard ##

***WARNING... Insecure permissions for development only!***

**MORE WARNING:** The following policy allows ALL service accounts to act as cluster administrators. Any application running in a container receives service account credentials automatically, and could perform any action against the API, including viewing secrets and modifying permissions. This is not a recommended policy... On other hand, works like charm for dev!

References:  
_https://kubernetes.io/docs/admin/authorization/rbac_

1. __Configure Cluster Permissions__

   From __control node__, run script to configure open permissions.  Make note of dashboard port.  Run command from _kubespray-and-pray_ directory.

    `$ ansible-playbook dashboard-permissive.yml`  

2. __Access Dashboard__ 

   From web browser, access dashboard with following url. Use dashboard_port from previous command.  When prompted to login, choose _Skip_.

    `https://master-ip:dashboard-port`  


## GlusterFS Distributed Storage ##

This optional step creates a Kubernetes default storage class using the distributed filesystem GlusterFS, managed with Heketi.  Providing a default storage class abstracts the application from the implementation.

Requirement:  Additional raw physical or virtual disk.  The disk will be referenced by it's device name (i.e. _/dev/sdc_).

From the __control node__, configure hyper-converged storage solution consisting of a Gluster distributed filesystem running in the Kubernetes cluster.  Gluster cluster is managed by Heketi.  Raw storage volumes are defined in a topology file.

References:  
_https://github.com/heketi/heketi/blob/master/docs/admin/install-kubernetes.md_

1. __Configuration__

   Define GlusterFS topology.  Edit file to define distributed filesystem members.
   
   For each node block, the `hostnames.manage` value should be set to the node _FQDN_ and the `storage` value should be set to the node _IP address_.  The raw block device(s) (i.e. /dev/sdd) are specified under `devices`.  See _files/topology-sample.json_ for an example of multiple block devices per node. 
   
   Modify file with editor such as vi or nano.

    `$ vi ~/kubespray-and-pray/files/topology.json`   

   Define Kubespray inventory.  Edit `gluster` section in Kubespray inventory file.  Specify all members to be part of the GlusterFS distributed filesystem.
    
    ```
    [gluster]
    k8s0
    k8s1
    k8s2
    ```
    
    Modify file with editor such as vi or nano.  Copy to _.kubespray_ directory.

    `$ vi files/inventory.cfg`  
    `$ cp files/inventory.cfg ~/.kubespray/inventory`  

2. __Deploy Heketi GlusterFS__

   Run ansible playbook on all GlusterFS members to install kernel modules and glusterfs client.  The playbook  will be run against the `gluster` inventory group.  Run command from _kubespray-and-pray_ directory.

    `$ ansible-playbook pray-for-gluster.yml`   
    
## Validation ##

Validate cluster functionality by deploying an application.

1. __Deploy Helm Package__
2. __Change Service Type__
3. __View Service__
