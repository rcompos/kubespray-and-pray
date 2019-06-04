## Kubernetes On-Prem Dashboard RBAC ##

Kubernetes on-premise dashboard RBAC configuration.

## Description ##

Setup Dashboard UI permissive authentication for on-prem Kubernetes clusters.  By default the Dashboard has a minimal RBAC configuration.  The Dashboard may be made accessible without a login for developmemt environments.   

For production environments, a separate admin user should be created, whose bearer token can be used for Dashboard logins.

```***  Permissive dashboard for development environments only.  ***```

## Requirements ##

1. Existing Kubernetes cluster 

## Configure Kubernetes Permissive Dashboard ##

Configure Kubernetes Dashboard service authentication to allow for permissive access.  

1. __Change to Repo Directory__

    Change to the cloned repository directory.  All subsequent Ansible commands must be run from this directory. 

   `$ cd ~/kubespray-and-pray`  

2. __Specify Target Cluster__

   Specify target cluster. Substitute actual cluster name for _\<cluster\>_. 

   `$ ./kubespray-and-pray.sh -i <cluster> -l`  

3. __Verify Target Cluster__

   Verify target cluster. Substitute actual cluster name for _\<cluster\>_. 

   `$ ansible all -m ping`  

4. __Permissive Dashboard__

    Run Ansible playbook to change Dashboard to a NodePort service and enable permissive access.

   `$ ansible-playbook kubespray-08-dashboard-permissive.yml`  

5. __Get Port__

    Get node port of Kibana service.

   `$ kubectl get svc -n kube-system kubernetes-dashboard`  

Expected value is the second port value.  The node port in this example is the value _32654_.
```
NAME            TYPE      CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes-dashboard  NodePort  10.233.51.86  <none>  443:32654/TCP  1d
```

6. __Access Dashboard UI__

    View the Dashboard UI on a master node at the previously discovered port.

   `https://<master_node>:<port>`

```

7. __Log into Dashboard UI__

    When selected with login options, select skip.

   `https://<master_node>:<port>`

```



