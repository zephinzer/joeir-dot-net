# `ingress/default-backend`
This directory contains the deployment for a standard not found/down time page.

## Deployment
### Configurations
#### `DOMAIN`
Create a file at `./.config/.DOMAIN` containing the domain this deployment should listen at.

#### `SUBDOMAIN`
Create a file at `./.config/.SUBDOMAIN` containing the subdomain this deployment should listen at.

### Generating Deployment
Run `./.create-deployment.sh` to get started.

### Deploy Order
1. `deployment.yaml`
2. `service.yaml`
3. `ingress.yaml`