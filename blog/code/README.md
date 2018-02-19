# `blog/code`
This directory contains the deployment files for my software development blog located at https://code.joeir.net. I use this blog for writing about over-geeky stuff the general reader will probably not be interested in.

## Deployment

### Overview
This deployment is a Ghost application using a managed MySQL instance (CloudSQL on Google Cloud Platform - GCP). The deployment utilises a multi-container pod as recommended by GCP to provide a proxy container through which the application will connect to the database through.

There are two ways to deploy this the non-NFS-enabled way (single pod deployment), and the NFS-enabled way (highly available).

### Prerequisites
Before proceeding with this deployment, you'll need:

1. Nginx Ingress running in your cluster
2. CloudSQL managed database instance running
3. `blog/code-nfs` set up (*optional, only for the NFS-enabled deployment variant*)

#### Nginx Ingress Setup
You'll need the Nginx Ingress set up for the `ingress` resource here to work nicely. You can [check out the Nginx Ingress setup at this page](../../ingress/nginx). Take note of the static IP address you assigned the Nginx Ingress to, you'll need that to set up your subdomain in your DNS provider.

#### CloudSQL Setup
You'll need a Cloud SQL instance ready. Create it at the following page:
`https://console.cloud.google.com/sql/choose-instance-engine?project=%_PROJECT_ID_%` where `%_PROJECT_ID_%` is your Google Cloud Platform project ID. Remember the instance ID. Save the instance name to a file at `./.config/cloud_sql_instance_id` from this directory.

#### `blog/code-nfs` Setup
Set up the `code-nfs` NFS server deployment as documented in [`blog/code-nfs`](../code-nfs). This step is optional and only required if you desire a highly available blog.

### Configuration
At the end of this section you should have the following files in your `./.config` directory:

- [ ] `.CLOUDSQL_CREDENTIALS.json`
- [ ] `.CLOUDSQL_INSTANCE_CONNECTION_NAME`
- [ ] `.DB_HOST`
- [ ] `.DB_NAME`
- [ ] `.DB_PASSWORD`
- [ ] `.DB_USERNAME`
- [ ] `.DOMAIN`
- [ ] `.GCE_PERSISTENT_DISK_NAME` (*optional: only if doing a non-NFS-enabled deployment*)
- [ ] `.GCE_PERSISTENT_DISK_SIZE`
- [ ] `.GHOST_PRODUCTION_CONFIG.json`
- [ ] `.NFS_SERVER` (*optional: only if doing an NFS-enabled deployment*)
- [ ] `.SUBDOMAIN`
- [ ] `cloud_sql_instance_id` (from the [CloudSQL Setup step](#cloudsql-setup))

#### `CLOUDSQL_CREDENTIALS`
Create a file at `./.config/.CLOUDSQL_CREDENTIALS.json` with your service account's credentials in here.

To create a Cloud SQL service account, go to the following page: `https://console.cloud.google.com/iam-admin/serviceaccounts/project?project=%_PROJECT_ID%` where `%_PROJECT_ID_%` is your Google Cloud Platform project ID.

Create a new Service Account and set the role to Cloud SQL Client. Furnish a new set of credentials and select JSON. A file download will occur after the service account is created. Place the contents of this file into `./.config/.CLOUDSQL_CREDENTIALS.json`.

#### `CLOUDSQL_INSTANCE_CONNECTION_NAME`
> This step assumes `./.config/cloud_sql_instance_id` is present relative to this directory and correct.

To retrieve the connection name, run the script from this directory:

```bash
../../.scripts/.cloudsql-get-instance-connection-name.sh
```

Save the resultant string into the file at `./.config/CLOUDSQL_INSTANCE_CONNECTION_NAME`. It should follow the format:

```
%_PROJECT_ID_%:%_INSTANCE_REGION_%:%_CLOUDSQL_INSTANCE_ID_%
```

#### `DB_HOST`
Paste the following into the file at `./.config/.DB_HOST`:

```
127.0.0.1
```

Since we're using the CloudSQL proxy from the same pod, this targets the other container within the pod.

#### `DB_NAME`
Paste the following into the file at `./.config/.DB_NAME`:

```
ghost_code
```

This defines the database schema we'll be using for the blog. We append `code` to `ghost` so that other Ghost installations can be run using the same database. Similar to how Wordpress does their installations on the same MySQL instance.

#### `DB_USERNAME`
> This step assumes `./.config/cloud_sql_instance_id` is present relative to this directory and correct.

Paste the following into the file at `./.config/.DB_USERNAME`:

```
ghost_code_user
```

Now we create the proxy user. Run the script:

```bash
../../.scripts/.cloudsql-create-proxy-user.sh
```

The script will request for a username and a password. Enter `ghost_code_user` as the username and generate password using:

```bash
uuidgen | sed 's|\-||g'
```

#### `DB_PASSWORD`
Following the steps above in `DB_USERNAME`, paste the password into the file at `./.config/.DB_PASSWORD`.

#### `DOMAIN`
Put your domain name into the file at `./.config/.DOMAIN`.

If you're using Namecheap like me, place your domain name into `./.config/domain` relative to the root directory (not the current one!) and you can run the script:

```bash
../../.scripts/.namecheap.manage.dns.sh
```

This will open up your domain management panel for the domain specified.

#### `GCE_PERSISTENT_DISK_NAME`
> This is only required if you are going with the non-NFS-enabled deployment.

Create a new Persistent Disk from GCP at the following URL, changing `%_PROJECT_ID_%` to your GCP project's ID: `https://console.cloud.google.com/compute/disks?project=%_PROJECT_ID_%`.

Take note of the name and place it into the file at `./.config/.GCE_PERSISTENT_DISK_NAME`.

#### `GCE_PERSISTENT_DISK_SIZE`
Following the steps from [`GCE_PERSISTENT_DISK_NAME`](#gce_persistent_disk_name), place the disk size inside here. If it's 50 gigabytes, abbreviate it as `50Gi`.

> If you've opted for the NFS-enabled deployment way, set this to a size equal to or lower than the bound persistent volume from the deployment at `%_REPO_ROOT_%/blog/code-nfs`.

#### `.GHOST_PRODUCTION_CONFIG`
Create a file at `./.config/.GHOST_PRODUCTION_CONFIG.json` with the following content:

```json
{
  "url": "https://code.joeir.net",
  "server": {
    "port": 2368,
    "host": "0.0.0.0"
  },
  "mail": {
    "transport": "Direct"
  },
  "logging": {
    "transports": [
      "stdout"
    ]
  },
  "process": "systemd"
}
```

Replace the `"url"` property with the URL of your own site. If you need any other modifications to the configuration file, this JSON file will be copied in wholesale, so modify it to your needs. The documentation for configuring Ghost can be found at: https://docs.ghost.org/docs/config#section-configuration-options.

#### `NFS_SERVER`
> This step is not required if you've chosen the non-NFS-enabled deployment way.

Create a file at `./.config/.NFS_SERVER`. The contents of this file should equal to the Cluster IP of the service `code-nfs` which can be retrieved using the command `kubectl get svc -n blog` once the [`blog/code-nfs` deployment](../code-nfs) is up.

This file is also how the `./.create-deployment.sh` script checks if we are doing an NFS-enabled deployment. If the file is present, an NFS-enabled deployment will be generated, otherwise, the non-NFS-enabled variant will be.

#### `SUBDOMAIN`
Put your subdomain name into the file at `./.config/.SUBDOMAIN`.

If you're using Namecheap like me, place your domain name into `./.config/domain` relative to the root directory (not the current one!) and you can run the script:

```bash
../../.scripts/.namecheap.manage.dns.sh
```

This will open up your domain management panel for the domain specified so you can add the subdomain. Specify a new `A` record pointing to the static IP address your [Nginx Ingress](#nginx-ingress-setup) has been assigned and set the TTL to 1 minute. Once the website shows up and is stable, you can set it to `Automatic` or `60 minutes`.

### Generating Deployment
Run `./.create-deployment.sh` to get started. A relative path to the deployment directory should be printed when the script is done. Copy it and `cd %_DEPLOYMENT_PATH_%`. 

Then proceed to deploy:

### Deploy Order
Run the `kubectl apply -f %_FILENAME_%` from inside the generated deployment directory at `./.deployments/%_TIMESTAMP_%/*`. For the first deployment, deploy the manifests in the following order so that dependent services and resources are available first:

#### NFS-enabled

1. `config-map.yaml`
2. `config-map.ghost-config.yaml`
3. `persistent-volume.nfs.yaml` (*note the `.nfs`*)
4. `persistent-volume-claim.nfs.yaml` (*note the `.nfs`*)
5. `secret.cloudsql.yaml`
6. `secret.db.yaml`
7. `deployment.yaml`
8. `service.yaml`
9. `ingress.yaml`

#### Non-NFS-enabled
> For the non-NFS-enabled deployment, also edit the `deployment.yaml` and set the property at `spec.replicas` to `1` instead of `2` since a non-NFS persistent volume claim can only be mounted to one pod at a time.

1. `config-map.yaml`
2. `config-map.ghost-config.yaml`
3. `persistent-volume.yaml`
4. `persistent-volume-claim.yaml`
5. `secret.cloudsql.yaml`
6. `secret.db.yaml`
7. `deployment.yaml`
8. `service.yaml`
9. `ingress.yaml`

## Reference Links
- [Connecting from Google Kubernetes Engine](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine)
- [Ghost Configuration Options](https://docs.ghost.org/docs/config#section-configuration-options)
- [Official Kubernetes NFS Volume Example on GitHub](https://github.com/kubernetes/kubernetes/tree/master/examples/volumes/nfs)