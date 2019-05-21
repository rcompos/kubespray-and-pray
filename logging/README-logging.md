# Kubernetes On-Prem Logging #

Kubernetes on-premise logging setup with Elasticsearch Fluentd Kibana (EFK).

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

Setup logging for on-prem Kubernetes clusters.

## Requirements ##

1. Existing Kubernetes cluster 

## Install Nginx-Ingress ##

Install the logging with EFK for the cluster.  The ELK stack provides an out-of-box cluster logging option. 

1. __Change to Repo Directory__

    Change to the cloned repository directory.  All subsequent Ansible commands must be run from this directory. 

   `$ cd ~/kubespray-and-pray`  

2. __Specify Target Cluster__

   Specify target cluster. Substitute actual cluster name for _\<cluster\>_. 

   `$ ./kubespray-and-pray -i <cluster> -l`  

3. __Verify Target Cluster__

   Verify target cluster nodes all ping successfully via Ansible. Substitute actual cluster name for _\<cluster\>_. 

   `$ ansible all -m ping`  

4. __Clone logging repo__

   Clone the EFK code from:  

   `# cd ~/kubespray-and-pray`  
   `# git clone https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch`  


5. __Deploy Application__ 

    Run Ansible playbook to deploy EFK.

   `$ kubectl apply -f ~/kubespray-and-pray/fluentd-elasticsearch`  

6. __Get Port__

    Get node port of Kibana service.

   `$ kubectl get svc -n kube-system | grep kibana`  

Expected results.  The node port is the value _30159_.
```
NAME            TYPE      CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kibana-logging  NodePort  10.233.8.35  <none>  5601:30159/TCP  1d
```
6. __Access Kibana__

   Access Kibana service at a master nodes on the previously discovered port.

   `http://<master_node>:<port>`
