# SolidFire Kubernetes Kubespray #

Deploy Kubernetes clusters with Kubespray.

### Description ###

Automated install Kubernetes clusters using KubeSpray.  The clusters are  designed to be built on virtual machines.

The cluster will use the following components:  
Control plane container engine: docker  
Container network interface: calico  
Storage driver: overlay2  

Estimated time to complete: 1 hr

### Requirements ###

General requirements:

* Control node where the Kubespray commands are run (i.e. laptop or jump host).
* Virtual machines running Ubuntu 16.04 (Minimum of one, but at least three are recommended).

Kubespray requirements:  
https://github.com/kubernetes-incubator/kubespray

* Ansible v2.4 (or newer) and python-netaddr is installed on the machine that will run Ansible commands
* Jinja 2.9 (or newer) is required to run the Ansible Playbooks
* The target servers must have access to the Internet in order to pull docker images.
* The target servers are configured to allow IPv4 forwarding.
* Your ssh key must be copied to all the servers part of your inventory.
* The firewalls are not managed, you'll need to implement your own rules the way you used to. in order to avoid any issue during deployment you should disable your firewall.


### Prepare Control Node ###

Prepare control node where management tools are installed.  A laptop computer will be sufficient.

MacOS:

1. Install required packages

```
$ pip2 install ansible
$ pip2 install kubespray
```
2. Clone repo with ansibles

```
$ cd; git clone https://bitbucket.org/solidfire/kubespray-and-pray
```

### Prepare Cluster Virtual Machines ###

Prepare virtual machines that will be part of the Kuberntes cluster.

Ubuntu 16.04:

Install required packages

```
$ apt-get install python
```

Copy SSH public key from control node to all cluster vm's.  On each cluster vm, append the public key to the user solidfire's authorized keys file.

```
$ cat id_pub.rsa >> ~solidfire/.ssh/authorized_keys
```

Todo:

* Known hosts??  Make connection first?
  Might need to log in and make a ssh connection which will create .ssh dir.

### Install Components ###

Perform the following steps on the control node.

Prepare ansible local config.

```
$ vi ~/.ansible/hosts
```

Edit the file.  The first line should be square bracketed arbitrary group name.  Each cluster member's hostname or IP address should be listed, one per line.  Ensure that the names are resolvable in DNS or are listed in local hosts file.  An example inventory file follows.

```
[autoinfra]
10.117.106.46
10.117.106.47
10.117.106.48
ai-k8s-01
ai-k8s-02
ai-k8s-03
k8s0
k8s1
k8s2
```


Perform pre-configuration.

Define hosts in base configuration ansible file.
```
$ vi ~/k8s-kubespray/kubespray-pre.yml
```

Identify the line:  
`- hosts: '*'`  
Change line to:  
`- hosts: 'ai-k8s-*'`

```
$ ansible-playbook kubespray-pre.yml
```

Reboot the nodes to disable Apparmor.

Prepare the Kubespray config.

```
$ kubespray prepare --nodes node1 node2 node3 --etcds node1 node2 node3 --masters node1
```

Edit variables. 

```
$ vi ~/.kubespray/inventory/group_vars/all.yml
```
 Uncomment the following line:
 `docker_storage_options: -s overlay2`
 
 Run Kubespray.
 
 ```
 $ kubespray deploy
 ```

### Post-Install ###

Define hosts in post configuration ansible file.
```
$ vi ~/k8s-kubespray/kubespray-post.yml
```

Identify the line:  
`- hosts: '*'`  
Change line to:  
`- hosts: 'ai-k8s-*'`

On the control node, run post-install steps.  This includes configuring Docker LVM thin pool storage provisioning.

```
$ ansible-playbook kubespray-post.yml
```

### Authorization ###

***WARNING\: Insecure permissions for development only!***

Run the following on the master node.
`$ kubectl -n kube-system edit service kubernetes-dashboard`

Identify the line:  
`type: CluserIP`  
Change to:  
`type: NodePort`  

Permissive RBAC Permissions.
`$ kubectl create clusterrolebinding permissive-binding --clusterrole=cluster-admin --user=admin --user=kubelet --group=system:serviceaccounts`

Get Kubernetes master IP address.  
`kubectl cluster-info`

Get dashboard port.  
`kubectl -n kube-system get service kubernetes-dashboard`

Access dashboard with url.  
`https://<master_ip>:<dashboard_port>/`

### Contact ###

* NetApp SolidFire Central Engineering
* Maintainer:  ronald.compos@netapp.com
