# Kubernetes On-Prem Trident Storage Orchestrator #

Kubernetes on-premise persistent storage with NetApp Trident storage orchestrator.

## Description ##

Deploy Trident on-prem Kubernetes cluster persistent storage orchestrator.

## Requirements ##

1. Existing Kubernetes cluster 

## Install Trident ##

Deploy Trident to the cluster.  

1. __Change to Repo Directory__

    Change to the cloned repository directory.  All subsequent Ansible commands must be run from this directory. 

   `$ cd ~/kubespray-and-pray`  

2. __Specify Target Cluster__

   Specify target cluster. Substitute actual cluster name for _\<cluster\>_. 

   `$ ./kubespray-and-pray -i <cluster> -l`  

3. __Verify Target Cluster__

   Verify target cluster. Substitute actual cluster name for _\<cluster\>_. 

   `$ ansible all -m ping`  

4. __Deploy Requirements__

    Run Ansible playbook to deploy NetApp Trident pre-requisites.

   `$ ansible-playbook trident/trident-01-pre.yml`  

5. __Deploy ONTAP Storage Driver__

    Run Ansible playbook to deploy NetApp Trident storage driver for ONTAP.

   `$ ansible-playbook trident/trident-02-ontap-nas.yml`  

6. __Deploy SolidFire Storage Driver__

    Run Ansible playbook to deploy NetApp Trident storage driver for SolidFire.

   `$ ansible-playbook trident/trident-03-solidfire-san.yml`  

7. __Verify Trident__ 

    Verify Trident resources.

   `$ kubectl get all -n trident`

Expected results:
```
NAME                          READY   STATUS    RESTARTS   AGE
pod/trident-8584977f6-rg5g2   2/2     Running   0         1d

NAME                      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/trident   1         1         1            1           1d

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/trident-8584977f6   1         1         1       1d
```
