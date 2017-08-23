template {
  source = "/opt/devops-ctmpl/memcached/consul.d/memcached.json.ctmpl"
  destination = "/etc/consul.d/memcached.json"
  perms = 0755
  backup = true
  command = "/bin/bash -c 'chown consul:consul /etc/consul.d/memcached.json && systemctl reload consul-client'"
}
