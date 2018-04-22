# Kubernetes Baremetal Cluster # 
Deploy Kubernetes clusters with Kubespray on bare metal (physical servers or virtual machines).

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

### Description ###

Deploy Kubernetes clusters on baremetal (i.e. physical servers) or virtual machines using Kubespray and Ansible.  Whether you're in your datacenter or on your laptop, you can build Kubernetes clusters for evaluation, development or production.  All you need to bring to the table is a few machines to run the cluster.

The tool used to do the heavy lifting is Kubespray which is built on Ansible.  Kubespray automates the cluster deployments and provides for flexibility in configuration.

The Kubernetes cluster configs include the following component defaults:  
Container engine: _docker_  
Container network interface: _calico_  
Storage driver: _overlay2_  

Estimated time to complete: 1 hr

References:  
`https://github.com/kubernetes/kubernetes`  
`https://github.com/kubernetes-incubator/kubespray`  

### Requirements ###

General requirements:

* Control Node: Where the Kubespray commands are run (i.e. laptop or jump host).  MacOS High Sierra, RedHat 7, CentOS 7 or Ubuntu Xenial all tested.
* Cluster Machines: Minimum of one, but at least three are recommended.  Physical or virtual.  Recommended minimum of 2gb ram per node for evaluation clusters. For a ready to use Vagrant environment clone `https://github.com/rcompos/vagrant-zero` and run `vagrant up k8s0 k8s1 k8s2`.
* Operating System: Ubuntu 16.04   (CentOS 7 is an open issue)
* Container Storage Volume:  Additional physical or virtual disk volume.  i.e. /dev/sdc
* Persistent Storage Volume:  Additional physical or virtual disk volume.  i.e. /dev/sdd
* Hostname resolution:  Ensure that cluster machine hostnames are resolvable in DNS or are listed in local hosts file.  The control node and all cluster vm's must have DNS resolution or /etc/hosts entries.  IP addresses may be used.

### Prepare Control Node ###

Prepare __control node__ where management tools are installed.  A laptop or desktop computer will be sufficient.  A jump host is fine too.


1. Install required packages on control node.  Ansible v2.4 (or newer) and python-netaddr is installed on the machine that will run Ansible commands.

    `$ sudo -H pip2 install ansible kubespray`  

    Debian or Ubuntu control node also need:  
    `$ sudo apt-get install sshpass`

2. Clone repo with ansibles into home directory.

    `$ cd; git clone https://github.com/rcompos/kubespray-and-pray`


### Create Kubernetes Cluster ###

Perform the following steps on the __control node__ where ansible command will be run from.  This might be your laptop or a jump host.  The cluster machines must already exist and be responsive to SSH.


1. From __control node__, edit inventory file.  Specify the cluster topology as masters, nodes and etcds.  Masters are cluster masters running the Kubernetes API service.  Nodes are worker nodes where pods will run.  Etcds are etcd cluster members, which serve as the state database for the Kubernetes cluster.

    Modify file with editor such as vi or nano.

    `$ vi ~/kubespray-and-pray/files/inventory.cfg`
    
    The file ansible.cfg defines the inventory file as _~/.kubespray/inventory/inventory.cfg_.  The ansible playbook will copy the edited _inventory.cfg_ to _~/.kubespray/inventory_. This will be the default inventory file when Kubespray is run.
    
    If multiple network adapters are present on any node(s), Ansible will use the value provided as ansible\_ssh\_host and/or ip for each node.  For example: _k8s0 ansible\_ssh\_host=10.117.31.20 ip=10.117.31.20_.
    
    Example _inventory.cfg_ defining a Kubernetes cluster with three members (all).  There are two masters (kube-master), three etcd members (etcd) and three worker nodes (kube-node).  The top lines with ansible\_ssh\_host and ip values are required if machines have multiple network addresses, otherwise may be omitted.  Change the ip addresses in the file to actual ip addresses.  Lines or partial lines may be comment out with the pound sign (#).

    ```
    # Kubespray inventory file
    
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
    
    [k8s-cluster:children]
    kube-node
    kube-master
    ```

    Nodes may be added later by running the Kubespray _scale.yml_.

    _Optional:_ From __control node__, edit _all.yml_ and _k8s-cluster.yml_.  Config cluster to your needs.

    _~/kubespray-and-pray/files/all.yml_  
    _~/kubespray-and-pray/files/k8s-cluster.yml_  

2. From __control node__, run script to install Kubernetes cluster on machines specified in inventory.cfg.

    Specify a user name to connect to via SSH to all cluster machines.  User _solidfire_ is used in this example.  This user account must exist and with sudo privileges and be accessible with password or key.  Supply the user's SSH password when prompted, then at second prompt supply sudo password or press enter to use SSH password.

    `$ pray-for-cluster.sh solidfire`

Congratulations!  You're cluster is running.  Log onto a master node and run `kubectl get nodes` to validate.


### Kubernetes Permissions ###

***WARNING... Insecure permissions for development only!***

**MORE WARNING:** The following policy allows ALL service accounts to act as cluster administrators. Any application running in a container receives service account credentials automatically, and could perform any action against the API, including viewing secrets and modifying permissions. This is not a recommended policy... On other hand, works like charm for dev!

1. From __control node__, run script to configure open permissions.  Make note dashboard port.

    `$ cd ~/kubespray-and-pray`  
    `$ ansible-playbook dashboard-permissive.yml`  

2. Access dashboard with url. Use dashboard_port from previous command.  

    _https://master\_ip:dashboard\_port_  

References:  
`https://kubernetes.io/docs/admin/authorization/rbac/`

### GlusterFS Storage ###

This optional step creates a Kubernetes default storage class using the distributed filesystem GlusterFS, managed with Heketi.  Providing a default storage class abstracts the application from the implementation.

Requirement:  Additional raw physical or virtual disk.  The disk will be referenced by it's device name (i.e. /dev/sdc).

From the __control node__, configure hyper-converged storage solution consisting of a Gluster distributed filesystem running in the Kubernetes cluster.  Gluster cluster is managed by Heketi.  Raw storage volumes are defined in a topology file.


1. Create GlusterFS topology file.  Edit file to define distributed filesystem members.  The `hostnames.manage` value should be set to the node _FQDN_ and the `storage` value should be set to the node _IP address_.  The raw block device(s) (i.e. /dev/sdc) are specified under `devices`.

    `$ cd ~/kubespray-and-pray/files`   
    `$ cp topology-sample.json topology.json`  
    `$ vi topology.json`  

2. From the control node, run ansible on all GlusterFS members to install kernel modules and glusterfs client.  Use to `-l host1,host2` option to limit the playbook to a subset of the entire cluster.

    `$ cd ~/kubespray-and-pray`   
    `$ ansible-playbook heketi-pre.yml`  
    
3. Edit heketi-run.  Edit `- hosts:` line to include the hostname or ip addres of a single cluster master.  The GlusterFS cluster members are specified as storage\_nodes.  List the total number of nodes as num\_nodes.

    `storage_nodes: 'k8s0 k8s1 k8s2 k8s3 k8s4'`  
    `num_nodes: 5`  

    `$ vi heketi-run.yml`
    
3. Execute heketi-run on a _single_ Kubernetes cluster master.  Edit `- hosts:` line to include a single cluster master hostname (or ip address).  Substitute actual hostname of ip address for <master_node>.

    `$ ansible-playbook -l <master_node> heketi-run.yml`
    
4. Create default storage class. Edit `- hosts:` line to include a single cluster master hostname (or ip address). Substitute actual hostname of ip address for <master_node>.

    `$ ansible-playbook -l <master_node> heketi-sc.yml`

References:  
`https://github.com/heketi/heketi/blob/master/docs/admin/install-kubernetes.md`
