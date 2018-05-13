# `kube-system/kube-lego`
This directory contains the deployment files for Kube-Lego which helps me automatically provision my SSL certificates.

## Deployment
### Overview
This deployment is for automatic provisioning of SSL certificates via Let's Encrypt.

### Prerequisites
None.

### Configuration
#### `KUBE_LEGO_EMAIL`
Place a file named `.KUBE_LEGO_EMAIL` into the `./.config` directory with the email to use with Let's Encrypt.

### Generating Deployment
Run `./.create-deployment.sh` to generate the deployment files. They will be placed in the directory `./.deployments/%CURRENT_TIMESTAMP%/*.yaml`.

### Deploying Order
Run the `kubectl apply -f %_FILENAME_%` from inside the generated deployment directory at `./.deployments/%_TIMESTAMP_%/*`. For the first deployment, deploy the manifests in the following order so that dependent services and resources are available first:

1. `config-map.yaml`
2. `deployment.yaml`

## Reference Links
- [`kube-lego` on GitHub](https://github.com/jetstack/kube-lego)