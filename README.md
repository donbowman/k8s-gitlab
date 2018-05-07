# k8s-gitlab

Run gitlab on Kubernetes with cert-manager and nginx Ingress.
Enable Google OAUTH2 (or other OAUTH).

This is an alternative to [gitlab-omnibus](https://gitlab.com/charts/charts.gitlab.io)
that doesn't require a DNS wildcard. It also re-uses/shares your Ingress.

It uses [cert-manager](https://github.com/jetstack/cert-manager/) to perform SSL.

## Notes

Don't make GITLAB_ROOT_EMAIL be a user you plan to login with OAUTH2

## Shoutouts

Thanks to [Let's Encrypt Tutorial](https://github.com/ahmetb/gke-letsencrypt)
Thanks to [sameerbsn gitlab](https://github.com/sameersbn/docker-gitlab)

## Setup

Copy values.yaml.sample to values.yaml, edit to suite.
Run ```helm install -f values.yaml --name git .```

## Persistent storage

By default this uses the auto-provisioner to create two persistent
volumes (1 for postgresql, 1 for the git repo).  This means that if
you delete the chart, you will delete the storage. If you wish,
you can manually create one or both volumes, and add them to the values.yaml
as
```
git-db-claim: pv-git-volume-claim
git-volume-claim: pv-git-volume-claim
```

And you may wish to create them as:

```
cat << EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: retained
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
reclaimPolicy: Retain
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-git-volume-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: retained
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-git-db-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: retained
EOF
```

## Manual steps

This assumes you have run these two commands:
```
helm install --name cert-manager --namespace kube-system stable/cert-manager
helm install stable/nginx-ingress --name ingress --set rbac.create=true
```

After setup, you will need to upload header logo (28-pixel height),
and then customise login page (640x360px logo)

In admin/application_settings:

 * set 'Enabled Git access protocols' to 'Only SSH'
 * Disable DSA keys
 * Increase Maximum attachment size
 * Set home page url
 * Set after sign out path
 * Enable plantuml

If you want to enable gitlab-runner, login to the web interface,
find the token, and then copy config-runner.yaml.sample to
config-runner.yaml, edit to add token, and then run:

```
helm install --namespace gitlab-runner --name gitlab-runner -f config-runner.yaml gitlab/gitlab-runner
```
