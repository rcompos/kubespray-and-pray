## Kubernetes Ingress Nginx ##

Kubernetes ingress-nginx setup.

## Description ##

Setup ingress-nginx for Kubernetes clusters.

## Requirements ##

1. Existing Kubernetes cluster 
2. Software load balancer implemented

## Install Nginx-Ingress ##

Install the ingress-ngxin controller to allow service exposure via ingress.  

1. __Change to Repo Directory__

    Change to the ingress dir within the cloned repository directory.  

   `cd ~/kubespray-and-pray`  

2. __Specify Target Cluster__

   Specify target cluster. Substitute actual cluster name for _\<cluster\>_. 

   `./kap.sh -i <cluster> -l`  

3. __Verify Target Cluster__

   Verify target cluster. Substitute actual cluster name for _\<cluster\>_. 

   `ansible all -m ping`

4. __Deploy Ingress__

    Run Ansible playbook to deploy ingress-nginx.

   `ansible-playbook ingress/ingress-nginx-01-setup.yml`  

5. __Verify Ingress__

    Run Ansible playbook to validate Nginx ingress.

   `kubectl get all -n ingress`  

6. __Detect installed version__

    Run command to get installed ingress-nginx version.  Substitute your actual namespace.

    ```
    POD_NAME=$(kubectl -n ingress-nginx get pods -l app.kubernetes.io/name=ingress-nginx -o jsonpath='{.items[0].metadata.name}')
	kubectl -n ingress-nginx exec -it $POD_NAME -- /nginx-ingress-controller --version
    ```
