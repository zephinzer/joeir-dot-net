# Terraform Configuration

## Pre-Use

### Get Terraform
Download Terraform from https://www.terraform.io/downloads.html.

Alternatively, the following script downloads it and installs it automatically for Linux systems:

```sh
wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip;
unzip ./terraform_0.11.7_linux_amd64.zip;
chmod +x ./terraform;
mv ./terraform /opt/terraform;
ln -s /opt/terraform /usr/bin/terraform;
```

### Get API Keys
Create your DigitalOcean tokens from this page: https://cloud.digitalocean.com/settings/api/tokens

## Usage
> Perform this step in an administration server for production uses.

`cd` into the directory and run `terraform init` to download the provider plugins.

Set the following variables:

```sh
export TF_VAR_DO_TOKEN="${YOUR_DIGITALOCEAN_API_TOKEN}"
```

Run the following to validate the script and view the execution plan:

```sh
terraform validate && terraform plan;
```

If acceptable, run:

```sh
terraform apply
```

## Resources
- [Terraform - DigitalOcean Provider](https://www.terraform.io/docs/providers/do/index.html)