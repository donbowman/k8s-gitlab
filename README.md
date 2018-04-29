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

## Manual steps

After setup, you will need to upload header logo (28-pixel height),
and then customise login page (640x360px logo)

In admin/application_settings:

 * set 'Enabled Git access protocols' to 'Only SSH'
 * Disable DSA keys
 * Increase Maximum attachment size
 * Set home page url
 * Set after sign out path
 * Enable plantuml

