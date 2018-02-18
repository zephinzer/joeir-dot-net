# `blog/code`
This directory contains the deployment files for my software development blog located at https://code.joeir.net. I use this blog for writing about over-geeky stuff the general reader will probably not be interested in.

## Deployment
### Overview
This deployment is a Ghost application using a managed MySQL instance (CloudSQL on Google Cloud Platform - GCP). The deployment utilises a multi-container pod as recommended by GCP to provide a proxy container through which the application will connect to the database through.

### Prerequisites
Before proceeding with this deployment, you'll need:

1. Nginx Ingress running in your cluster
2. CloudSQL managed database instance running

#### Nginx Ingress Setup
You'll need the Nginx Ingress set up for the `ingress` resource here to work nicely. You can [check out the Nginx Ingress setup at this page](../../ingress/nginx). Take note of the static IP address you assigned the Nginx Ingress to, you'll need that to set up your subdomain in your DNS provider.

#### CloudSQL Setup
You'll need a Cloud SQL instance ready. Create it at the following page:
`https://console.cloud.google.com/sql/choose-instance-engine?project=%_PROJECT_ID_%` where `%_PROJECT_ID_%` is your Google Cloud Platform project ID. Remember the instance ID. Save the instance name to a file at `./.config/cloud_sql_instance_id` from this directory.

### Configuration
At the end of this section you should have the following files in your `./.config` directory:

- `.CLOUDSQL_CREDENTIALS.json`
- `.CLOUDSQL_INSTANCE_CONNECTION_NAME`
- `.DB_HOST`
- `.DB_NAME`
- `.DB_PASSWORD`
- `.DB_USERNAME`
- `.DOMAIN`
- `.SUBDOMAIN`
- `cloud_sql_instance_id` (from the [CloudSQL Setup step](#cloudsql-setup))

#### `CLOUDSQL_CREDENTIALS`
Create a file at `./.config/.CLOUD_CREDENTIALS.JSON` with your service account's credentials in here. To create a Cloud SQL service account, go to the following page: `https://console.cloud.google.com/iam-admin/serviceaccounts/project?project=%_PROJECT_ID%` where `%_PROJECT_ID_%` is your Google Cloud Platform project ID.

Create a new Service Account and set the role to Cloud SQL Client. Furnish a new set of credentials and select JSON. A file download will occur after the service account is created. Place the contents of this file into `./.config/.CLOUD_CREDENTIALS.json`.

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

#### `SUBDOMAIN`
Put your subdomain name into the file at `./.config/.SUBDOMAIN`.

If you're using Namecheap like me, place your domain name into `./.config/domain` relative to the root directory (not the current one!) and you can run the script:

```bash
../../.scripts/.namecheap.manage.dns.sh
```

This will open up your domain management panel for the domain specified so you can add the subdomain. Specify a new `A` record pointing to the static IP address your [Nginx Ingress](#nginx-ingress-setup) has been assigned and set the TTL to 1 minute. Once the website shows up and is stable, you can set it to `Automatic` or `60 minutes`.

### Generating Deployment
Run `./.create-deployment.sh` to get started. A relative path to the deployment directory should be printed when the script is done. Copy it and `cd %_DEPLOYMENT_PATH_%`. Then proceed to deploy:

### Deploy Order
Run the `kubectl apply -f %_FILENAME_%` from inside the generated deployment directory at `./.deployments/%_TIMESTAMP_%/*`. For the first deployment, deploy the manifests in the following order so that dependent services and resources are available first:

1. `config-map.yaml`
2. `secret.cloudsql.yaml`
3. `secret.db.yaml`
4. `deployment.yaml`
5. `service.yaml`
6. `ingress.yaml`

## Reference Links
- [Connecting from Google Kubernetes Engine](https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine)