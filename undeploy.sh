#!/bin/bash

error() {
    >&2 echo "Error: $*"
    exit 1
}
kubectl version >/dev/null || error "Error: kubectl not setup"

kubectl delete configmap gitlab-config --namespace gitlab

for i in *yml
do
    echo "Create $i"
    kubectl --namespace gitlab -f $i delete
done

