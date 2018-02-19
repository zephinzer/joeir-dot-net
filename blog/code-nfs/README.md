# `blog/code-nfs`
This directory contains the deployment manifests for an NFS server that the project `blog/code` uses. This allows us to have a highly available Ghost deployment by allowing true `ReadWriteMany` volume mounts.

## Deployment
### Overview
This project deploys an NFS server which other `PersistentVolumes` can use via the `nfs` property. Unlike the official example by Kubernetes on GitHub, this deployment uses a pre-provisioned persistent disk instead of a dynamically created one for the volume.

### Prerequisites
None.

### Configuration
At the end of this section you should have the following files in your `./.config` directory:

- [ ] `.GCE_PERSISTENT_DISK_NAME`
- [ ] `.GCE_PERSISTENT_DISK_SIZE`

#### `GCE_PERSISTENT_DISK_NAME`
Create a file at `./.config/.GCE_PERSISTENT_DISK_NAME` relative to this project's root.

Go to the following URL: `https://console.cloud.google.com/compute/disks?project=%_PROJECT_ID_%` where `%_PROJECT_ID_%` is your GCP project's ID.

Create a new disk (**Create Disk**) and set a name. Copy and paste the name into the file at `./.config/.GCE_PERSISTENT_DISK_NAME`.

#### `GCE_PERSISTENT_DISK_SIZE`
Create a file at `./.config/.GCE_PERSISTENT_DISK_SIZE` relative to this project's root.

Following the [steps for setting up the `GCE_PERSISTENT_DISK_NAME`](#gce_persistent_disk_name), set the zone to where your cluster is, and select **None (blank disk)** for the disk type. Set a size and copy and paste the size into the file at `./.config/.GCE_PERSISTENT_DISK_SIZE`.

For disk sizes, gigabytes are denoted with `Gi` so if you have 50 gigabytes, the size should be `50Gi`.

### Generating Deployment
Run `./.create-deployment.sh` to get started. A relative path to the deployment directory should be printed when the script is done. Copy it and `cd %_DEPLOYMENT_PATH_%`. Then proceed to deploy:

### Deploy Order
Run the `kubectl apply -f %_FILENAME_%` from inside the generated deployment directory at `./.deployments/%_TIMESTAMP_%/*`. For the first deployment, deploy the manifests in the following order so that dependent services and resources are available first:

1. `persistent-volume.yaml`
2. `persistent-volume-claim.yaml`
3. `deployment.yaml`
4. `service.yaml`

## Reference Links
- [Kubernetes Volume v1 Reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.9/#volume-v1-core)
- [Official Kubernetes NFS Volume Example on GitHub](https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/nfs)