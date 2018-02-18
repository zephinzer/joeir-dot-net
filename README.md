# My Infrastructure
So I decided to go full on into Kubernetes for my personal web infrastructure, and here are my deployment manifests. Some goals I had while deciding to go this path instead of continuing on my Digital Ocean droplet:

1. Versioned deployments via Git
2. Container based deployments via Docker
3. Automatic SSL provisioning from Let's Encrypt via `kube-lego`
4. No server software updates/maintenance required
5. Having my infrastructure as code

## Open-Source
Why am I open-sourcing this? I must be crazy, this is infrastructure! But no, I'm not. I just find no point in keeping knowledge I've gained to myself and I hope that this repository can also serve as examples for others to run your own cluster/get up your own applications using Kubernetes for container orchestration.

## General Ideas
Some conventions for the deployments here so that I do not forget them as my infrastructure progresses:

### Directory Hierarchy
Root level directories in this repository indicate the namespaces for which the contained projects shall be deployed in. These directories should contain a `namespace.yaml` manifest which should be run before deploying any of the contained projects to create the namespace.

Directories in the namespace directories contain deployment projects and has manifests named after their resource types. For example, a `Deployment` should be named `deployment.yaml`, a `ConfigMap` should be named `config-map.yaml`. So on and so forth. If multiple `ConfigMap`s are required, the intent of the `ConfigMap` shall be added to the filename using dot notation. For example a `ConfigMap` for the database should be named `config-map.database.yaml` or something to that effect.

No deployment directory shall be nested more than 2 levels deep.

### Filename Conventions
All directories prefixed with a period are considered deployment sensitive and contain state-dependent resources. For example, `./.config` contains configurations, `./.deployments` contains deployment-ready manifests and `./.scripts` contain general scripts that can be run.

Filenames in **UPPERCASE** are considered to be variables used in the deployment manifests. Filenames in **lowercase** contain variable values that scripts use to generate files/output results not directly related to the deployment manifests.

### Code Discipline
As far as possible, we keep secrets and keys out of the deployment manifests in `./.config` and `./.deployments` directories which are universally ignored using `.gitignore`. This allows me to open-source this repository without fear you'll hunt down my servers.

### Configuration
All configuration should be held in a `./.config` directory relative to the deployment and it should have a `.gitignore` file which ignores all files other than the `.gitignore`. This directory will contain keys and other sensitive information required for generating the final deployment files, so **remember the `.gitignore`**.

Configurations involved in the deployment generation should be named in uppercase. For example a variable named `DB_HOSTNAME` in the deployment template will be assigned a value matching the contents of the file at `./.config/.DB_HOSTNAME`.

### Deployment Generation
All deployment directories should have a `./.create-deployment.sh` script which is compatible with dash (`sh`). This is because I use a minimal jump server to administer updates and `bash` is too heavy.

The `./.create-deployment.sh` script should read variables from the configuration directory at `./.config` and generate deployment-ready manifests into a directory named after the datetime stamp when the script was run, in the deployment manifests directory.

### Deployment Manifests
All deployments should be held in a `./.deployments` directory relative to the deployment and it should have a `.gitignore` file which ignores all files other than the `.gitignore`. This directory will contain other directories named according to when the deployment was generated. The deployment manifests in these directories will contain the keys/secrets from the `./.config` directory, so **remember the `.gitignore`**.

### Documentation
Every directory should have a `README.md` describing the directory. For namespace directories, instructions to create the namespace and other quirks should be present. For deployment directories, instructions to deploy should contain:

1. IP address/hostname to access the deployment
2. System level pre-requisites
3. Variables required for the deployment to be generated
4. Deployment manifest deploy order
5. Reference links to any tutorials useful to a reader

Before a deployment project is published, there should have been one successful deployment whose access method should be placed in the `README.md` in the directory root.

## Getting Started
This repository was created for Kubernetes deployments on Google Cloud Platform (GCP). You'll need to create an account with them first.

### Prerequisite Software
You'll need the following software installed:

1. `gcloud` - get it from https://cloud.google.com/sdk/downloads
2. `kubectl` - should come installed with `gcloud`: run `gcloud components install kubectl` after `gcloud` is installed.

### Google Cloud Platform Configuration
To get started, create the following files relative to the repository root:

#### `./.config/domain`
This repository assumes we are deploying our infrastructure on a single domain, as I am. This file contains the primary domain name to use the scripts in `./.scripts` with.

#### `./.config/gcloud_account`
This file contains the Google account which the GCloud SDK can use (`xxxxx@gmail.com`).

#### `./.config/gcloud_project_id`
This file contains the default GCloud project ID.

#### `./.config/gcloud_zone`
This file contains the default GCloud zone we'll be using.

### Google Cloud Platform Initialisation
You'll need to have completed the [Google Cloud Platform Configuration](#google-cloud-platform-configuration) to use the scripts in `./.scripts`. To login to your GCloud account via the GCloud CLI, run the following from the root of this repository:

```bash
./.scripts/.gcp-login.sh
```

Next go to the GCP user interface and create a new cluster. Remember the name of your cluster. Once the cluster is created in GCP, run the following to get access to it via your local `kubectl` (assuming you've logged in via the `./.scripts/.gcp-login.sh` script):

```bash
gcloud container clusters get-credentials %_CLUSTER_NAME_%;
```

Replace `%_CLUSTER_NAME_%` with your cluster name.

### Verify Initialisation
Run the following to verify your `kubectl` has the correct credentials:

```bash
kubectl config current-context
```

That should return a line formatted as:

```
gke_%PROJECT_ID%_%PROJECT_REGION%_%CLUSTER_NAME%
```

This means the `kubectl` context has been set.

## Reference/Tutorial Links

- [Kubernetes API Reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.9/)