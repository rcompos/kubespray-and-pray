## Kubernetes On-Prem Kubernetes Config ##

Kubernetes node fully qualified domain name. 

## Description ##

Configure fully-qualified domain name resolution for Kubernetes cluster nodes.

## Requirements ##

1. Existing Kubernetes cluster 

## Set FQDN ##

Set cluster node fully-qualified hostname.

Run on master or with appropriate _~/.kube/config_.

1. __Run Playbook__

   From __control node__, run playbook to add entry to _/etc/hosts_ file.  Run command from _kubespray-and-pray_ directory.  Substitute actual domain for _my-domain.com_.

    `$ ansible-playbook maint/add-etc-hosts-entry.yml -e domain=<my-domain.com>`

3. _Validate Hostname_

    Get hostname from node.  Substitute actual user name for <user>.  Substitute actual cluster node name for <my-cluster-fqdn>.

    `# ssh <user>@<my-cluster-fqdn> hostname`

    Expected result is the short hostname (i.e. my-cluster-1).

    Get fully-qualified hostname from node.  Substitute actual user name for <user>.  Substitute actual cluster node name for <my-cluster-fqdn>.

    `# ssh <user>@<my-cluster-fqdn> hostname -f`

    Expected result is the FQDN (i.e. my-cluster-1.my-domain.com).