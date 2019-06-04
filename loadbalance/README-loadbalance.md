## Kubernetes On-Prem Load-Balancer ##

Kubernetes on-premise load balancer setup.

## Description ##

Setup software load balancer for on-prem Kubernetes clusters.

## Requirements ##

1. Existing Kubernetes cluster 

## Install MetalLB ##

Install the software load balancer MetalLB in the cluster.  This provides external IP address when a service is defined as a LoadBalanced Kubernetes service.

1. __Change to Repo Directory__

    Change to the cloned repository directory.  All subsequent Ansible commands must be run from this directory. 

   `$ cd ~/kubespray-and-pray`  

2. __Specify Target Cluster__

   Specify target cluster. Substitute actual cluster name for _\<cluster\>_. 

   `$ ./kubespray-and-pray -i <cluster> -l`  

3. __Verify Target Cluster__

   Verify target cluster. Substitute actual cluster name for _\<cluster\>_. 

   `$ ansible all -m ping`  

4. __Define IP Block__

    Edit config file located in _inventory/\<cluster\>_. Substitute actual cluster name for _\<cluster\>_.

   `$ nano inventory/<cluster>/loadbalance/metallb-config.yaml`  

    Edit the last line of file with the IP address block reserved for this cluster.  The following is an example of IP address block specification.

   `   addresses:`  
   `   - 10.117.67.230-10.117.67.234`  
   

5. __Deploy Load Balancer__

    Run Ansible playbook to deploy load balancer.

   `$ ansible-playbook metallb-01-setup.yml`  

6. __Verify Load Balancer__

    Verify deployment of load balancer.

   `$ kubectl get all -n load-balance`  

Expected results:
```
NAME                                      READY   STATUS    RESTARTS   AGE
pod/metallb-controller-665dc6c5cf-tqgf9   1/1     Running   0          1d
pod/metallb-speaker-29j7n                 1/1     Running   0          1d 
pod/metallb-speaker-kggml                 1/1     Running   0          1d
pod/metallb-speaker-lcbmx                 1/1     Running   0          1d 

NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/metallb-speaker   3         3         3       3            3           <none>          1d

NAME                                 DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/metallb-controller   1         1         1            1           1d

NAME                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/metallb-controller-665dc6c5cf   1         1         1       1d
```



