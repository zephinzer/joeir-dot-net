# Namespace `ingress`
This namespace contains deployments related to handling the ingress.

## Get Started
Create the `ingress` namespace using:

```bash
kubectl apply -f ./namespace.yaml
```

## Deployments

### `ingress/default-backend`
This contains a default backend so I can make my downtime pages a little prettier. See the code at [./default-backend](./default-backend).

### `ingress/nginx`
This contains the Nginx deployment which handles Ingresses. See the code at [./nginx](./nginx).