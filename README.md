# SolidFire Kubernetes Kubespray #

Deploy Kubernetes clusters with Kubespray.

### Description ###

Automated install Kubernetes clusters using KubeSpray.  The clusters are  designed to be built on virtual machines.

The cluster will use the following components:  
Control plane container engine: docker  
Container network interface: calico  
Storage driver: overlay2  

Estimated time to complete: 1 hr

Kubespray:  `https://github.com/kubernetes-incubator/kubespray`

### Requirements ###

General requirements:

* A control node where the Kubespray commands are run (i.e. laptop or jump host).
* Virtual machines running Ubuntu 16.04 (Minimum of one, but at least three are recommended).

### Prepare Control Node ###

Prepare control node where management tools are installed.  A laptop computer will be sufficient.

MacOS or Linux:

1. Install required packages.  Ansible v2.4 (or newer) and python-netaddr is installed on the machine that will run Ansible commands.

    `$ pip2 install ansible kubespray`  

2. Clone repo with ansibles

    `$ cd; git clone https://bitbucket.org/solidfire/kubespray-and-pray`

3.  To-do  
    Known hosts??  Make connection first?
    Might need to log in and make a ssh connection which will create .ssh dir.

### Install Components ###

Perform the following steps on the control node where ansible command will be run from.  Define the nodes, etcds and masters as appropriate.

1. Run command to generate inventory file (~/.kubespray/inventory/inventory.cfg) which defines the target nodes.  If there are too many hosts for command-line, run the kubespray prepare command with a minimal set of hosts then add to the resulting inventory.cfg file.

    `$ kubespray prepare --nodes k8s0 k8s1 k8s2 --etcds k8s0 k8s1 k8s2 --masters k8s0`

    ___Ensure that the names are resolvable in DNS or are listed in local hosts file.___

2. Create default user and bootstrap ansible.  Note that the ansible.cfg file defines the inventory file as follows.  This will be used as the default inventory file when ansible is run.  

    `inventory = ~/.kubespray/inventory/inventory.cfg`

    `$ ansible-playbook user-solidfire.yml`

3. Run pre-install step.

    `$ ansible-playbook ubuntu-pre.yml`

4. Optional.  Edit cluster parameters if needed.

    `$ vi ~/.kubespray/inventory/group_vars/all.yml`

     Uncomment the following line:
     `docker_storage_options: -s overlay2`  
     Other common options will be listed...
 
5. Deploy Kubespray.  Ansible is run on all nodes to install and configure Kubernetes cluster.
 
    `$ kubespray deploy`
    
Congratulations!  You're cluster is running.  On a master node, run `kubectl get nodes` to validate.

### Docker Thin Pool ###

From the control node, run post-install steps.  This includes configuring Docker LVM thin pool storage provisioning.  Raw storage volume (defaults to /dev/sdb) will be used for container  storage.

1. Run ansible post-install tasks.

    `$ ansible-playbook kubespray-post.yml`

### Gluster Filesystem ###


Configure hyper-converged storage solution consisting of a Gluster distributed filesystem running as pods in the Kubernetes cluster.  Raw storage volume (defaults to /dev/sdc) will be used for GlusterFS.

1. Run ansible to install kernel modules and glusterfs client.

    `$ ansible-playbook heketi-gluster/gluster-pre.yml`

2. Create GlusterFS daemonset.

3. Heteki ...

### Kubernetes Permissions ###

***WARNING... Insecure permissions for development only!***

1. Run the following on the master node.  
    `$ kubectl -n kube-system edit service kubernetes-dashboard`

2. Identify the line:  
    `type: CluserIP`  
    Change to:  
    `type: NodePort`  

3. Permissive admin role.  
    `$ kubectl create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts`

4. Get Kubernetes master IP address.  
    `kubectl cluster-info`

5. Get dashboard port.  
    `kubectl -n kube-system get service kubernetes-dashboard`

6. Access dashboard with url.  
    `https://<master_ip>:<dashboard_port>/`

### Contact ###

* NetApp SolidFire Central Engineering
* Maintainer:  ronald.compos@netapp.com
