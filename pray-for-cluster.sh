#!/bin/bash
USER=$1

export PYTHONUNBUFFERED=1

ansible-playbook prep-cluster.yml -k -K -e user=$USER
kubespray deploy -y -u $USER
