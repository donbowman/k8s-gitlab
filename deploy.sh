#!/bin/bash

# I expect you have run these two out-of-band (manually)
# helm install --name cert-manager --namespace kube-system stable/cert-manager
# helm install stable/nginx-ingress --namespace gitlab --name gitlab --set rbac.create=true

# GITLAB_ROOT_EMAIL

. config

error() {
    >&2 echo "Error: $*"
    exit 1
}
kubectl version >/dev/null || error "Error: kubectl not setup"


kubectl create configmap gitlab-config --namespace gitlab --from-env-file=config

set -e

kubectl -n gitlab apply -f storage.yaml

for i in *yml
do
    echo "Create $i"
    sed -e "s?GITLAB_HOST?$GITLAB_HOST?g" $i | kubectl apply --namespace gitlab -f -
done

echo "Pod:"
kubectl get pod --namespace gitlab

echo "Deployment:"
kubectl get deployment --namespace gitlab

echo "Service:"
kubectl get svc --namespace gitlab

echo "Ingress:"
kubectl get ingress --namespace gitlab
kubectl get ingress -o=yaml --namespace gitlab

# Enable port 22 ingress
helm upgrade -f ssh-ingress.yaml --set rbac.create=true --namespace gitlab gitlab stable/nginx-ingress


if [ "$1" = "dotls" ]
then
    echo "setup tls"
    sed -e "s?GITLAB_HOST?$GITLAB_HOST?g" -e "s?GITLAB_ROOT_EMAIL?$GITLAB_ROOT_EMAIL?g" lets-encrypt-issuers.yaml | kubectl apply  -f -
    sed -e "s?GITLAB_HOST?$GITLAB_HOST?g" cert.yaml | kubectl apply --namespace gitlab  -f -
fi

# kubectl --namespace default get services --namespace gitlab -o wide -w gitlab-nginx-ingress-controller
# kubectl get pods --all-namespaces -l app=ingress --watch
# kubectl exec gitlab-nginx-ingress-controller-5dd9d5878c-2tmk9  cat /etc/nginx/nginx.conf
