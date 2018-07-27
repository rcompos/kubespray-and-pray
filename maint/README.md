# Kubernetes Cluster Backup and Restore with Heptio Ark and Restic# 

Kubernetes Backup and Restore

## Description ##

Kubernetes Backup and Restore


__Kubernetes Node Operating Systems Supported:__

* Ubuntu 16.04 Xenial
* CentOS 7

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

    `$ cd; git clone https://github.com/scandalizer/kubespray-and-pray`

## TLDR ##
---

Deploy Heptio Ark and Restic to cluster.

1. Deploy Ark 
    Deploy cluster.  
   
        $ ansible-playbook maint/ark-setup.yml

## Install Ark ##

Deploy Heptio Ark for backups and restores.  This approach backs up to local Minio S3-ish storage.

Run on master or with appropriate _~/.kube/config_.

1. __Deploy Ark__

   From __control node__, run playbook to deploy ark and create daily backup schedule.  Run command from _kubespray-and-pray_ directory.

    `$ ansible-playbook maint/ark-setup.yml`

2. __Ark Client__

    From **master** or with appropriate _~/.kube/config_ (i.e. you can run kubectl), run ark client command to validate backups.

    `# ark get backups`

5. __Ark Restore__

    From **master** or with appropriate _~/.kube/config_ (i.e. you can run kubectl), run ark client command to restore a backup.  Substitute actual backup name for <backup_name>.

    `# ark restore create --from-backup <backup_name>`
    `# ark restore get`

## References ##

_https://heptio.github.io/ark/_

