# `ingress/nginx`
This directory contains the nginx ingress controller for all deployments. 

## Deployment
### Overview
This deployment deploys an Nginx Ingress to the cluster so that it can handle incoming connections based on hostnames. After deploying this, we can use the following annotations in our ingresses to indicate that we should use the Nginx Ingress:

```
...
    annotations:
      kubernetes.io/ingress.class: "nginx"
...
```

### Configuration
#### `LOAD_BALANCER_IP`
Create a static IP address for the Ingress Nginx to listen to. On GCP, you can do this via the GCloud CLI tool:

```bash
ADDRESS_NAME='ip-address-name';
REGION='your-region-1';
gcloud compute addresses create "${ADDRESS_NAME}" --region=${REGION};
```

Then check the IP address using:

```bash
gcloud compute addresses list;
```

Copy the IP address and paste it into the file at `./.config/.LOAD_BALANCER_IP`.

### Generating Deployment
Run `./.create-deployment.sh` to get started. A relative path to the deployment directory should be printed when the script is done. Copy it and `cd %_DEPLOYMENT_PATH_%`. Then proceed to deploy:

### Deploy Order
Run the `kubectl apply -f %_FILENAME_%` from inside the generated deployment directory at `./.deployments/%_TIMESTAMP_%/*`. For the first deployment, deploy the manifests in the following order so that dependent services and resources are available first:

1. `config-map.yaml`
2. `config-map.tcp.yaml`
3. `config-map.udp.yaml`
4. `deployment.yaml`
5. `service.yaml`

## Reference Links
- [`ingress-nginx` on GitHub](https://github.com/kubernetes/ingress-nginx/)