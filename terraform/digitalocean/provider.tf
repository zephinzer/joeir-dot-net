variable "DO_TOKEN" {}

provider "digitalocean" {
  token = "${var.DO_TOKEN}"
}
