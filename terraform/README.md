# Terraform Configuration

## Pre-Use

Download Terraform from https://www.terraform.io/downloads.html.

Alternatively, the following script downloads it and installs it automatically for Linux systems:

```sh
wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip;
unzip ./terraform_0.11.7_linux_amd64.zip;
chmod +x ./terraform;
mv ./terraform /opt/terraform;
ln -s /opt/terraform /usr/bin/terraform;
```

## Usage

`cd` into the directory and run `terraform init` to download the provider plugins.
