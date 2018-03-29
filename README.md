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

Kubernetes repo:  `https://github.com/kubernetes/kubernetes`  
Kubespray repo:  `https://github.com/kubernetes-incubator/kubespray`  

### Requirements ###

General requirements:

* Control Node: Where the Kubespray commands are run (i.e. laptop or jump host).
* Cluster Machines: Minimum of one, but at least three are recommended
* Operating System: Ubuntu 16.04   (CentOS 7 support upcoming under consideration)
* Container Storage Requirement:  Additional physical or virtual disk.  By default, /dev/sdb is used.
* Persistent Storage Requirement:  Additional physical or virtual disk.  By default, /dev/sdc is used.

### Prepare Control Node ###

Prepare __control node__ where management tools are installed.  A laptop computer will be sufficient.


1. Install required packages.  Ansible v2.4 (or newer) and python-netaddr is installed on the machine that will run Ansible commands.

    `$ sudo -H pip2 install ansible kubespray`  

    Debian or Ubuntu control node also need:  
    `$ sudo apt-get install sshpass`

2. Clone repo with ansibles

    `$ cd`

    `$ git clone https://github.com/rcompos/kubespray-and-pray`

    `$ git clone https://github.com/kubespray/kubespray-cli`

### Install Kubernetes ###

Perform the following steps on the __control node__ where ansible command will be run from.  This might be your laptop or a jump host.  The cluster machines must already exist and be responsive to SSH.

1. Hostname resolution.

    Ensure that the names are resolvable in DNS or are listed in local hosts file.

    The control node and all cluster vm's must have DNS resolution or /etc/hosts entries.  IP addresses may be used if you must.

2. From __control node__, run command to generate inventory file _~/.kubespray/inventory/inventory.cfg_) which defines the target nodes.  If there are too many hosts for command-line, run the kubespray prepare command with a minimal set of hosts then add to the resulting inventory.cfg file.  Running the prepare command will clone the kubespray repo to `~/.kubespray`.

    `$ cp ~/kubespray-cli/src/kubespray/files/.kubespray.yml ~`  

    `$ cd ~/kubespray-and-pray`  

    `$ kubespray prepare --nodes k8s0 k8s1 k8s2 --etcds k8s0 k8s1 k8s2 --masters k8s0`  

    The file ansible.cfg defines the inventory file as _~/.kubespray/inventory/inventory.cfg_.  This will be the default inventory file when ansible is run.
    
    If multiple network adapters are present on any node(s), then define the IP address to use by defining ansible\_ssh\_host and ip in the `all` group for each node.  For example: _k8s0 ansible\_ssh\_host=10.117.31.20 ip=10.117.31.20_.  See the inventory templates in `~/kubespray-and-pray/inventory`.  

    Nodes may be added later by running the Kubespray _scale.yml_.

3. Bootstrap ansible by installing Python.  Note that ansible.cfg defines the inventory file as _~/.kubespray/inventory/inventory.cfg_.  This will be the default inventory file when ansible is run.  Supply SSH password. 

    `$ ansible-playbook bootstrap-ansible.yml -k -K`

4. Allow user solidfire to sudo without password.

    `$ ansible-playbook user-sudo.yml -k -K`

5. Run pre-install step.

    `$ ansible-playbook kubespray-pre.yml`

6. Create logical volume for container storage.  Supply -e block\_device with an raw volume where container storage logical volume is to be created.  For example `-e block_device=/dev/sdc`.  Skip this step if no additional disk are available, in which case the container storage is located on the local filesystem.

    `$ ansible-playbook create-volume.yml -e block_device=/dev/sdc`

7. Edit cluster parameters.

    `$ cp -a ~/.kubespray/inventory/sample/group_vars ~/.kubespray/inventory`

    Define container storage driver.  Edit file.
    
    `$ vi ~/.kubespray/inventory/group_vars/all.yml`

    Uncomment the following line:
    
    `docker_storage_options: -s overlay2`  

    Optional: Enable Helm package manager.  Edit file.
    
    `$ vi ~/.kubespray/inventory/group_vars/k8s-cluster.yml`

    Change line:
    
    `helm_enabled: true`

8. Deploy Kubespray.  Ansible playbook is run on all nodes to install and configure Kubernetes cluster.

    `$ kubespray deploy -u solidfire`
    
Congratulations!  You're cluster is running.  On a master node, run `kubectl get nodes` to validate.


### Kubernetes Permissions ###

***WARNING... Insecure permissions for development only!***

1. Log onto a Kubernetes master node.

2. Run the following on the master node.  

    `$ kubectl -n kube-system edit service kubernetes-dashboard`

3. Identify the line:  
    `type: CluserIP`  
    Change to:  
    `type: NodePort`  

4. Permissive admin role.  
    Kubernetes RBAC: `https://kubernetes.io/docs/admin/authorization/rbac/`

    **MORE WARNING:** The following policy allows ALL service accounts to act as cluster administrators. Any application running in a container receives service account credentials automatically, and could perform any action against the API, including viewing secrets and modifying permissions. This is not a recommended policy... On other hand, works like charm for dev!

    `$ kubectl create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts`

5. Get Kubernetes master IP address.  
    `kubectl cluster-info`

6. Get dashboard port.  
    `kubectl -n kube-system get service kubernetes-dashboard`

7. Access dashboard with url.  
    `https://<master_ip>:<dashboard_port>/`

### GlusterFS Storage ###

This optional step creates a Kubernetes default storage class using the distributed filesystem GlusterFS, managed with Heketi.

Requirement:  Additional raw physical or virtual disk.  The disk will be referenced by it's device name (i.e. /dev/sdc).

From the __control node__, configure hyper-converged storage solution consisting of a Gluster distributed filesystem running in the Kubernetes cluster.  Gluster cluster is managed by Heketi.  Raw storage volumes are defined in a topology file.

Heketi install procedure: `https://github.com/heketi/heketi/blob/master/docs/admin/install-kubernetes.md`

1. Create GlusterFS topology file.  Edit file to define distributed filesystem members.  The `hostnames.manage` value should be set to the node _FQDN_ and the `storage` value should be set to the node _IP address_.  The raw block device(s) (i.e. /dev/sdc) are specified under `devices`.

    `$ cd ~/kubespray-and-pray/files`   
    `$ cp topology-sample.json topology.json`  
    `$ vi topology.json`  

2. From the control node, run ansible on all GlusterFS members to install kernel modules and glusterfs client.  Use to `-l host1,host2` option to limit the playbook to a subset of the entire cluster.

    `$ cd ~/kubespray-and-pray`   
    `$ ansible-playbook heketi-pre.yml`  
    
3. Edit heketi-run.  Edit `- hosts:` line to include a single cluster master hostname (or ip address).  List all GlusterFS cluster nodes as storage\_nodes.  List the total number of nodes as num\_nodes.

    `storage_nodes: 'k8s0 k8s1 k8s2 k8s3 k8s4'`  
    `num_nodes: 5`  

    `$ vi heketi-run.yml`
    
3. Execute heketi-run on a single Kubernetes cluster master.  Edit `- hosts:` line to include a single cluster master hostname (or ip address).  Substitute actual hostname of ip address for <master_node>.

    `$ ansible-playbook -l <master_node> heketi-run.yml`
    
4. Create default storage class. Edit `- hosts:` line to include a single cluster master hostname (or ip address). Substitute actual hostname of ip address for <master_node>.

    `$ ansible-playbook -l <master_node> heketi-sc.yml`


### Contact ###

* NetApp SolidFire Central Engineering
* Maintainer:  ronald.compos@netapp.com
