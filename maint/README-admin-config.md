# NetApp CIBU K8s #
## Kubernetes On-Prem Kubernetes Config ##

Kubernetes on-premise admin command-line config.

```
   ~~~~~~~~~~~~~~~~~~~~~~~
 (     NetApp CIBU K8s     )
   ~~~~~~~~~~~~~~~~~~~~~~~
          \   ^__^
           \  (oo)\_______
              (__)\       )\/\
                  ||----w |
                  ||     ||
```

## Description ##

Setup command-line authentication for on-prem Kubernetes clusters.

## Requirements ##

1. Existing Kubernetes cluster 

## Copy Kubeconfig ##

Copy the kubernetes admin config file to your local machine.  

1. __Change to Kubectl Directory__

    Change to the kubectl dir.  

   `$ cd ~/.kube`  

2. __Copy Kubeconfig__ 

   Copy Kubernetes admin config file from any master node in the cluster.  Substitute actual master node name for _\<master\>_.

   `$ scp <user>@<master>:/etc/kubernetes/admin.conf config`

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