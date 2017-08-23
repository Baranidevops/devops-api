template {
  source = "/opt/devops-ctmpl/tomcat/conf/context.xml.ctmpl"
  destination = "/usr/share/tomcat/conf/context.xml"
  perms = 0750
  command = "/bin/bash -c 'chown tomcat:tomcat /etc/tomcat/context.xml && systemctl restart tomcat'"
}
