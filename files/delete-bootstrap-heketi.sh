#!/bin/bash

kubectl get all,service,jobs,deployment,secret --selector=deploy-heketi
kubectl delete all,service,jobs,deployment,secret --selector=deploy-heketi
kubectl get all,service,jobs,deployment,secret --selector=deploy-heketi
