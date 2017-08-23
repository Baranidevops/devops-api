template {
  source = "/opt/devops-ctmpl/tomcat/consul.d/tomcat.json.ctmpl"
  destination = "/etc/consul.d/tomcat.json"
  perms = 0755
  backup = true
  command = "/bin/bash -c 'chown consul:consul /etc/consul.d/tomcat.json && systemctl reload consul-client'"
}
