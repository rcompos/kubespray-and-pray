## Kubernetes On-Prem Monitoring ##

Kubernetes on-premise monitoring with Prometheus and Grafana.

## Description ##

Setup cluster monitoring with Prometheus and Grafana for on-prem Kubernetes clusters.

## Requirements ##

1. Existing Kubernetes cluster 

## Install Prometheus and Grafana ##

Deploy cluster monitoring solution with Prometheus and Grafana.  

1. __Change to Repo Directory__

    Change to the cloned repository directory.  All subsequent Ansible commands must be run from this directory. 

   `$ cd ~/kubespray-and-pray`  

2. __Specify Target Cluster__

   Specify target cluster. Substitute actual cluster name for _\<cluster\>_. 

   `$ ./kap.sh -i <cluster> -l`  

3. __Verify Target Cluster__

   Verify target cluster. Substitute actual cluster name for _\<cluster\>_. 

   `$ ansible all -m ping`  

5. __Deploy Monitoring Solution__

    Run Ansible playbooks to deploy monitoring services.

   `$ ansible-playbook monitoring/metrics-server-01-setup.yml`  

   `$ ansible-playbook monitoring/prometheus-01-setup.yml`  

6. __Verify Load Balancer__

    Verify deployment of monitoring services.

   `$ kubectl get all -n monitoring`  

Expected results:
```
NAME                                                       READY   STATUS    RESTARTS   AGE
pod/alertmanager-kube-prometheus-0                         2/2     Running   0          1d
pod/kube-prometheus-exporter-kube-state-556565655c-96b5l   2/2     Running   2          1d
pod/kube-prometheus-exporter-node-dgczj                    1/1     Running   4          1d
pod/kube-prometheus-exporter-node-gq9kd                    1/1     Running   4          1d
pod/kube-prometheus-exporter-node-z9pcd                    1/1     Running   6          1d
pod/kube-prometheus-grafana-57d5b4d79f-jtg8v               2/2     Running   0          1d
pod/prometheus-kube-prometheus-0                           3/3     Running   0          1d
pod/prometheus-operator-98c54768b-9vw5r                    1/1     Running   1          1d

NAME                                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/alertmanager-operated                 ClusterIP   None            <none>        9093/TCP,6783/TCP   1d
service/kube-prometheus                       ClusterIP   10.233.38.135   <none>        9090/TCP            1d
service/kube-prometheus-alertmanager          ClusterIP   10.233.21.206   <none>        9093/TCP            1d
service/kube-prometheus-exporter-kube-state   ClusterIP   10.233.39.178   <none>        80/TCP              1d
service/kube-prometheus-exporter-node         ClusterIP   10.233.46.41    <none>        9100/TCP            1d
service/kube-prometheus-grafana               NodePort    10.233.49.103   <none>        80:32730/TCP        1d
service/prometheus-operated                   ClusterIP   None            <none>        9090/TCP            1d

NAME                                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/kube-prometheus-exporter-node   3         3         3       3            3           <none>          1d

NAME                                                  DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kube-prometheus-exporter-kube-state   1         1         1            1           1d
deployment.apps/kube-prometheus-grafana               1         1         1            1           1d
deployment.apps/prometheus-operator                   1         1         1            1           1d

NAME                                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/kube-prometheus-exporter-kube-state-556565655c   1         1         1       1d
replicaset.apps/kube-prometheus-exporter-kube-state-844bb6f589   0         0         0       1d
replicaset.apps/kube-prometheus-grafana-57d5b4d79f               1         1         1       1d
replicaset.apps/prometheus-operator-98c54768b                    1         1         1       1d

NAME                                            DESIRED   CURRENT   AGE
statefulset.apps/alertmanager-kube-prometheus   1         1         1d
statefulset.apps/prometheus-kube-prometheus     1         1         1d
<<<<<<< HEAD
```
=======
```
>>>>>>> 687e4a666a93435cce95921ffc3dd60576f0be7c
