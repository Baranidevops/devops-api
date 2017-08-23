template {
  source = "/opt/devops-ctmpl/tomcat/bin/setenv.sh.ctmpl"
  destination = "/usr/share/tomcat/bin/setenv.sh"
  perms = 0750
  command = "/bin/bash -c 'chown tomcat:tomcat /usr/share/tomcat/bin/setenv.sh && systemctl restart tomcat'"
}
