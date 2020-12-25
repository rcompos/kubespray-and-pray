#!/usr/bin/env bash

NAMESPACE="logging"

for pv in `kubectl get pvc -n "$NAMESPACE" -o jsonpath='{.items[*].spec.volumeName}'`;
  do kubectl patch pv "$pv" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}';
done
