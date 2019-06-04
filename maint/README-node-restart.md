## Kubernetes On-Prem Node Restart ##

Kubernetes on-premise cluster node services restart.

## Description ##

Restart cluster services on-prem Kubernetes clusters services, including Kubernetes daemon kubelet and Docker daemon docker.

## Requirements ##

1. Existing Kubernetes cluster 

## Restart Kubernetes Services ##

Log onto the target machine and restart Kubernetes services.  

1. __Log onto cluster node.__

   `$ ssh <user>@<node>`  

2. __Check status of services.__ 

   Check status of vital services.  Substitute actual node name for _\<node\>_.

   `$ sudo systemctl status kubelet`
   `$ sudo systemctl status docker`

3. __Stop services.__

   Stop Kubernetes and Docker services.

   `$ sudo systemctl stop kubelet`
   `$ sudo systemctl stop docker`

4. __Start Docker service.__

   Start Docker services.

   `$ sudo systemctl start docker`

   Expected results: 

```
● docker.service - Docker Application Container Engine
   Loaded: loaded (/etc/systemd/system/docker.service; enabled; vendor preset: enabled)
  Drop-In: /etc/systemd/system/docker.service.d
           └─docker-dns.conf, docker-options.conf
   Active: active (running) since Fri 2019-05-24 16:30:06 MDT; 12s ago
     Docs: http://docs.docker.com
 Main PID: 7773 (dockerd)
    Tasks: 135
   Memory: 54.7M
      CPU: 746ms
   CGroup: /system.slice/docker.service
           ├─7773 /usr/bin/dockerd --insecure-registry=10.233.0.0/18 --graph=/var/lib/docker --log-opt max-size=50m --log-opt max-file=5 --iptables=false -s ov...
...
```

5. __Start Kubernetes service.__

   Start Kubernetes services.

   `$ sudo systemctl start kubelet`

   Check status of Kubernetes services.

   `$ systemctl status kubelet`

   Expected results: 

```
● kubelet.service - Kubernetes Kubelet Server
   Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2019-05-24 16:30:11 MDT; 12s ago
     Docs: https://github.com/GoogleCloudPlatform/kubernetes
  Process: 7909 ExecStartPre=/bin/mkdir -p /var/lib/kubelet/volume-plugins (code=exited, status=0/SUCCESS)
 Main PID: 7913 (kubelet)
    Tasks: 12
   Memory: 36.4M
      CPU: 765ms
   CGroup: /system.slice/kubelet.service
           └─7913 /usr/local/bin/kubelet --logtostderr=true --v=2 --address=10.117.70.65 --node-ip=10.117.70.65 --hostname-override=ci-test-1 --allow-privilege...
...
```
