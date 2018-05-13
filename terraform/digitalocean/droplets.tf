resource "digitalocean_droplet" "web" {
  image  = "ubuntu-16-04-x64"
  name   = "www-dot-joeir-dot-net"
  region = "sgp1"
  size   = "1gb"
  tags   = ["${digitalocean_tag.website.id}"]
}
