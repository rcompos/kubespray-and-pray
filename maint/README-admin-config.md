## Kubernetes On-Prem Kubernetes Config ##

Kubernetes on-premise admin command-line config.

## Description ##

Setup command-line authentication for on-prem Kubernetes clusters.

## Requirements ##

1. Existing Kubernetes cluster 

## Copy Kubeconfig ##

Copy the kubernetes admin config file to your local machine.  

1. __Move Kubeconfig__ 

   Move Kubernetes admin config file on any master node in the cluster.  Substitute actual master node name for _\<master\>_.

   `$ ssh -t <user>@<master> "sudo cp /etc/kubernetes/admin.conf /home/<user>/config; sudo chown <user> config"`

2. __Copy Kubeconfig__ 

   Copy Kubernetes config file from the master node used in previous step.  Substitute actual master node name for _\<master\>_.

   `$ scp <user>@<master>:config ~/.kube`

1. __Delete Kubeconfig__ 

   Delete duplicate config file on same master node from prior step.  Substitute actual master node name for _\<master\>_.

   `$ ssh -t <user>@<master> "sudo rm config"`


3. __Verify Target Cluster__

   Verify kubectl works as expected with the remote cluster.

   `$ kubectl get nodes` 

Expected results:
```
NAME         STATUS   ROLES         AGE    VERSION
do-nitro-1   Ready    master,node   1d   v1.10.4
do-nitro-2   Ready    master,node   1d   v1.10.4
do-nitro-3   Ready    master,node   1d   v1.10.4
```