## Kubernetes Logging with EFK ##

Kubernetes logging setup with Elasticsearch Fluentd Kibana (EFK).

[Digital Ocean: How-to-set-up-an-elasticsearch-fluentd-and-kibana-efk-logging-stack-on-kubernetes](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-elasticsearch-fluentd-and-kibana-efk-logging-stack-on-kubernetes)

## Description ##

Setup EFK for Kubernetes clusters.

## Requirements ##

1. Existing Kubernetes cluster 

## Install EFK ##

Install the logging with EFK for the cluster.  The ELK stack provides an out-of-box cluster logging option. 

1. __Change to Repo Directory__

    Change to the logging directory.

   `cd ~/kubespray-and-pray/logging`  

2. __Create namespace__

   Create namespace logging.

   `cd ~/kubespray-and-pray/logging`  
   `kubectl apply -f logging-namespace.yaml`

3. __Create headless elasticsearch service__

   Run command to create headless service.
   `kubectl apply -f elasticsearch_svc.yaml`

4. __Create elasticsearch statefulset__

   Run command to create statefulset.
   `kubectl apply -f elasticsearch_statefulset.yaml`

5. __Deploy Kibana__ 

    Deploy Kibana.

   `kubectl apply -f kibana.yaml`

6. __Deploy Fluentd__

    Deploy Fluentd.

   `kubectl apply -f fluentd.yaml`

7. __Change persistent volume retain policy__

    Set persistent volumes to retain.

    `./patch-pv-retain.sh`

8. __Forward port__

    Identify the pod hosting the Kibana service and forward port.

    `kubectl port-forward pod/kibana-84cf7f59c-p97db 5601:5601 -n logging`

9. __Access Kibana__

   Access Kibana service on a master nodes at the previously discovered port.

   `http://localhost:5601`
