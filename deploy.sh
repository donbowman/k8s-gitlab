#!/bin/bash

# I expect you have run these two out-of-band (manually)
# helm install --name cert-manager --namespace kube-system stable/cert-manager
# helm install stable/nginx-ingress --name gitlab --set rbac.create=true

# GITLAB_ROOT_EMAIL

. config

error() {
    >&2 echo "Error: $*"
    exit 1
}
kubectl version >/dev/null || error "Error: kubectl not setup"

set -e

kubectl create configmap gitlab-config --from-env-file=config


for i in *yml
do
    echo "Create $i"
    sed -e "s?GITLAB_HOST?$GITLAB_HOST?g" $i | kubectl apply -f -
done

echo "Pod:"
kubectl get pod

echo "Deployment:"
kubectl get deployment

echo "Service:"
kubectl get svc

echo "Ingress:"
kubectl get ingress
kubectl get ingress -o=yaml

# Enable port 22 ingress
helm upgrade -f ssh-ingress.yaml --set rbac.create=true gitlab stable/nginx-ingress


if [ "$1" = "dotls" ]
then
    echo "setup tls"
    sed -e "s?GITLAB_HOST?$GITLAB_HOST?g" -e "s?GITLAB_ROOT_EMAIL?$GITLAB_ROOT_EMAIL?g" lets-encrypt-issuers.yaml | kubectl apply  -f -
    sed -e "s?GITLAB_HOST?$GITLAB_HOST?g" cert.yaml | kubectl apply  -f -
fi

# kubectl --namespace default get services -o wide -w gitlab-nginx-ingress-controller
# kubectl get pods --all-namespaces -l app=ingress --watch
# kubectl exec gitlab-nginx-ingress-controller-5dd9d5878c-2tmk9  cat /etc/nginx/nginx.conf
