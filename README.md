# Kubespray-and-Pray :8ball: #

Deploy Kubernetes on-premise.  K:8ball:s!

Deploy on-premise Kubernetes clusters with Kubespray.  For on-premise, bare metal or virtual machines.

```
   ~~~~~~~~~~~~~~~~~~~~~~~
 (       K8s v1.21.6      )
   ~~~~~~~~~~~~~~~~~~~~~~~
          \   ^__^
           \  (oo)\_______
              (__)\       )\/\
                  ||----w |
                  ||     ||
```

## Description ##

Deploy on-premises Kubernetes clusters on virtual machines or baremetal (i.e. physical servers) using Kubespray and Ansible.  Whether you're in your datacenter or on your laptop, you can build Kubernetes clusters for evaluation, development or production.  All you need to bring to the table is a few machines to run the cluster.

Kubernetes v1.19.5  
Kubespray v2.14.2   

__Kubernetes Node Operating Systems Supported:__

* Ubuntu 16.04 Xenial
* Ubuntu 18.04 Bionic
* CentOS 7
* CentOS 8

This project provides a very simple deployment process for Kubernetes in the datacenter, on-premise, local vm's, etc.  System setup, disk prep, easy rbac and default storage all provided.  Kubespray, which is built on Ansible, automates cluster deployments and provides for flexibility in configuration. 

Estimated time to complete: 1 hr  

## Requirements ##

General requirements:

* __Control Node:__ Where the Kubespray commands are run (i.e. laptop or jump host).  MacOS High Sierra, RedHat/CentOS 7 or 8 and Ubuntu Xenial all tested. Python is a requirement. 
* __Cluster VM Provisioning:__ Minimum of one, but at least three are recommended.  Physical or virtual.  Recommended minimum of 2gb ram per node for evaluation clusters. For a ready to use Vagrant environment, clone _https://github.com/rcompos/zero_ and run `vagrant up yolo-1 yolo-2 yolo-3`.
* __Clueter Operating Systems:__ Ubuntu 16.04, 18.04 and RedHat/CentOS 7, 8
* __Container Storage Volume:__  Mandatory additional physical or virtual disk volume.  i.e. /dev/sdc.  This is the Docker volume.
* __Persistent Storage Volume:__  Optional additional physical or virtual disk volume.  i.e. /dev/sdd.  This additional storage may be used for distributed filesystems running in-cluster, such as OpenEBS or Gluster.
* __Hostname resolution:__  Ensure that cluster machine hostnames are resolvable in DNS or are listed in local hosts file.  The control node and all cluster vm's must have DNS resolution or /etc/hosts entries.  IP addresses may be used.
* __Helm 3:__ Helm v3.0.0 Tiller install in cluster.  Tillerless Helm not supported.  See file helm/install-helm3-tiller.sh.


## Control Node ##

Prepare __control node__ by installing requirements.  A laptop or desktop computer will be sufficient.  A jump host is fine too.


1. __Install Packages__ 

    a. Install Python (v3) as requirement of Ansible.  

    _MacOS_: `$ brew install python`  
    _RedHat 7_ or _CentOS 7_: `Python 2.7.5 installed by default`  
    _Ubuntu_: `$ sudo apt install python python-pip`  

    b. Use Python package manager pip to install required packages on __control node__ including Ansible.

    `$ sudo -H pip install --upgrade pip`  
    `$ sudo -H pip install -r requirements.txt`  
    `$ sudo -H pip install kubespray`  


    c. _Debian_ or _Ubuntu_ control node also need in addition to previous steps:  

    `$ sudo apt-get install sshpass`

2. __Clone Repo__

    Clone kubespray-and-pray repository in home directory.  Substitute actual repo url for _\<RepositoryURL\>_.

    `$ cd; git clone <RepositoryURL>`

3. __SSH key__

    A SSH key is required at _~/.ssh/id_rsa.pub_.

    If you don't have a SSH key one can be generated as follows:

    `$ ssh-keygen -t rsa`

## TLDR ##

A Kubernetes cluster can be rapidly deployed with the following steps.  See further sections for details of each step.  

1. Deploy K8s cluster on virtual or physical machines  

   Prepare directory (inventory/_cluster-name_) with _inventory.cfg_.  Deploy cluster.  Substitute actual cluster name for _cluster\-name_.  When prompted for SSH password, entire the ssh pasword for the operating system user.
   
        $ ./kap.sh -i cluster-name -o username

2. Kubernetes Access Controls  

   Insecure permissions for development only!  Use RBAC for production environments.
   
        $ ansible-playbook kubespray-08-dashboard-permissive.yml


## Define Cluster ##

The Kubernetes cluster topology is defined as masters, nodes and etcds.  

* Masters are cluster masters running the Kubernetes API service.  
* Nodes are worker nodes where pods will run.  
* Etcds are etcd cluster members, which serve as the state database for the Kubernetes cluster.  

Custom ansible groups may be included, such as gluster, openebs or trident.

The top lines with ansible\_ssh\_host and ip values are required since machines may have multiple network addresses.  Change the ansible\_ssh\_host and ip addresses in the file to actual ip addresses.  Lines or partial lines may be commented out with the pound sign (#).

Save your configuration under the _inventory_ directory, in a dedicated directory named for the cluster.  

The following is an example _inventory.cfg_ defining a Kubernetes cluster.  There are three members (all) including one master (kube-master), three etcd members (etcd) and three worker nodes (kube-node).  This file is from the upstream Kubespray repository _kubespray/inventory/sample/hosts.ini_.

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

[gluster]  # Custom group or OpenEBS
node1
node2
node3
    
[k8s-cluster:children]
kube-node
kube-master
```

Perform the following steps on the __control node__ where ansible command will be run from.  This might be your laptop or a jump host.  The cluster machines must already exist and be responsive to SSH.

1. __Kubernetes Cluster Topology__  
    
    Define your desired cluster topology Ansible inventory and variables files.  Create new directory under _inventory_ by copying one of the example directories.  Update _inventory.cfg_ and other files.  Then specify this directory in the deployment step.

    __Kubespray cluster configuration:__  Edit Kubespray group variables in _all.yml_ and _k8s-cluster.yml_ to configure cluster to your needs.  Substitute your cluster name for _my-cluster_.

    _inventory/my-cluster/all.yml_  
    _inventory/my-cluster/k8s-cluster.yml_  
    
    Modify inventory file with editor such as vi or nano.  
    
    `$ cd ~/kubespray-and-pray`  
    `$ vi inventory/my-cluster/inventory.cfg`  

    __Multiple network adapters:__  If multiple network adapters are present on any node(s), Ansible will use the value provided as _ansible\_ssh\_host_ and/or _ip_ for each node.  For example: _k8s0 ansible\_ssh\_host=10.117.31.20 ip=10.117.31.20_.

    __Optional hyper-converged storage:__  For development clusters only.  Define Kubernetes cluster node members to be part of Heketi GlusterFS hyper-converged storage in inventory group _gluster_.
    

## Deploy Kubernetes ##

1. __Deploy Kubernetes Cluster__

    Run script to deploy Kubernetes cluster to machines specified in _inventory/default/inventory.cfg_ by default and optionally an entire directory such as _inventory/my-cluster_.  If necessary, specify a user name to connect to via SSH to all cluster machines, a raw block device for container storage and the cluster inventory file.  
    
    __Deployment User__ _solidfire_ is used in this example.  A user account must already exist on the cluster nodes, and must have sudo privileges and must be accessible with password or key.  Supply the user's SSH password when prompted, then at second prompt press enter to use SSH password as sudo password.  Note: If you specify a different remote user, then you must manually update the _ansible.cfg_ file.
     
    __Optional Container Volume__  To create a dedicated Docker container logical volume on an available raw disk volume, specify optional argument -b for _block_device_, such as _/dev/sdd_.  Otherwise default device is _/dev/sdc_.  If default block device not found, the _/var/lib/docker_ directory will by default, reside under the local root filesystem.  
    
    __Inventory Directory__  The location of the cluster inventory is specified with option -i.  The following example looks in kubespray-and-pray/inventory/my-cluster for the inventory.ini file.

    Example:  ./kap.sh -o myuser -b /dev/sdb -i my-cluster

    Optional arguments for _kap.sh_ are as follows.  If no option is specified the default values will be used.
    
    | Flag   | Description                            | Default     |
    |--------|----------------------------------------|-------------|
    | -o     | SSH username                           | solidfire   |
    | -b     | Block device for containers            | /dev/sdc    |
    | -i     | Inventory directory under _inventory_  | default     | 
    | -s     | Silence prompt Ansible SSH password    |             | 


    Run script to deploy Kubernetes cluster to all nodes with default values.  Specify actual inventory directory in place of my-cluster.  This directory is located in the inventory directory (i.e. kubespray-and-pray/inventory/my-cluster).

    `$ ./kap.sh -i my-cluster`

Congratulations!  Your cluster should be running.  Log onto a master node and run `kubectl get nodes` to validate.


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


