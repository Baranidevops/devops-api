template {
  source = "/opt/devops-ctmpl/artifactorySync.sh.ctmpl"
  destination = "/usr/share/script/artifactorySync.sh"
  perms = 0755
  command = "systemctl reload httpd"
}
