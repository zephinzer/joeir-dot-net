resource "digitalocean_ssh_key" "default" {
  name       = "Administrator"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}
