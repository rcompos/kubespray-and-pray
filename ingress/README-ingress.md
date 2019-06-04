## Kubernetes On-Prem Ingress ##

Kubernetes on-premise ingress setup.

## Description ##

Setup ingress for on-prem Kubernetes clusters.

## Requirements ##

1. Existing Kubernetes cluster 
2. Software load balancer implemented

## Install Nginx-Ingress ##

Install the Nginx ingress controller to allow service exposure via ingress.  

1. __Change to Repo Directory__

    Change to the ingress dir within the cloned repository directory.  

   `$ cd ~/kubespray-and-pray`  

2. __Specify Target Cluster__

   Specify target cluster. Substitute actual cluster name for _\<cluster\>_. 

   `$ ./kubespray-and-pray -i <cluster> -l`  

3. __Verify Target Cluster__

   Verify target cluster. Substitute actual cluster name for _\<cluster\>_. 

   `$ ansible all -m ping`

4. __Deploy Ingress__

    Run Ansible playbook to deploy Nginx ingress.

   `$ ansible-playbook ingress/nginx-ingress-01-setup.yml`  

5. __Verify Ingress__

    Run Ansible playbook to validate Nginx ingress.

   `$ kubectl get all -n ingress`  

Expected results:
```
NAME                                                READY   STATUS    RESTARTS   AGE
pod/nginx-ingress-controller-7c94ff655c-8rctq       1/1     Running   1          1d
pod/nginx-ingress-default-backend-d676cbb5f-hzctm   1/1     Running   0          1d

NAME                                    TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                      AGE
service/nginx-ingress-controller        LoadBalancer   10.233.27.36   10.117.67.230   80:32193/TCP,443:31160/TCP   1d
service/nginx-ingress-default-backend   ClusterIP      10.233.57.72   <none>          80/TCP                       1d

NAME                                            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-ingress-controller        1         1         1            1           1d
deployment.apps/nginx-ingress-default-backend   1         1         1            1           1d

NAME                                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-ingress-controller-7c94ff655c       1         1         1       1d
replicaset.apps/nginx-ingress-default-backend-d676cbb5f   1         1         1       1d
```