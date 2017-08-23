template {
  source = "/opt/devops-ctmpl/httpd/consul.d/httpd.json.ctmpl"
  destination = "/etc/consul.d/httpd.json"
  perms = 0755
  backup = true
  command = "/bin/bash -c 'chown consul:consul /etc/consul.d/httpd.json && systemctl reload consul-client'"
}
