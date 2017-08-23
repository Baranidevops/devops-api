#!/bin/sh

#  Start SELinux in Permissive Mode
sed -i -e 's/^[[:space:]]*SELINUX[[:space:]]*=.*$/SELINUX=permissive/' /etc/selinux/config

# Copy War and config files
#cp -rf **/**/source/tmp/* /usr/share/tomcat/webapps/ || :
cd /usr/share/ && tar -xf apr_centos7.tar.gz
cp -rf /usr/tmp-cpl/share/tomcat/bin/* /usr/share/tomcat/bin || :
cp -rf /usr/tmp-cpl/share/tomcat/conf/* /usr/share/tomcat/conf || :
cp -rf /etc/tmp-cpl/httpd/* /etc/httpd/
cp -rf /etc/tmp-cpl/systemd/system/* /etc/systemd/system/
# httpd change
mv /opt/devops-ctmpl/httpd/config/httpd.conf.ctmpl /opt/devops-ctmpl/httpd/config/httpd.conf.ctmpl.bak
mv /opt/devops-ctmpl/httpd/config/adaptive-httpd.conf.ctmpl /opt/devops-ctmpl/httpd/config/httpd.conf.ctmpl
# logging.properties change
mv /opt/devops-ctmpl/tomcat/conf/logging.properties.ctmpl /opt/devops-ctmpl/tomcat/conf/logging.properties.ctmpl.bak
mv /opt/devops-ctmpl/tomcat/conf/adaptive.logging.properties.ctmpl /opt/devops-ctmpl/tomcat/conf/logging.properties.ctmpl
#server.xml change
mv /opt/devops-ctmpl/tomcat/conf/server.xml.ctmpl /opt/devops-ctmpl/tomcat/conf/server.xml.ctmpl.bak
mv /opt/devops-ctmpl/tomcat/conf/adaptive-server.xml.ctmpl /opt/devops-ctmpl/tomcat/conf/server.xml.ctmpl

#Consul tomcat changes
#mv /opt/devops-ctmpl/tomcat/consul.d/app.json.ctmpl /opt/devops-ctmpl/tomcat/consul.d/app.json.ctmpl.bak
#mv /opt/devops-ctmpl/tomcat/consul.d/adaptive_app.json.ctmpl /opt/devops-ctmpl/tomcat/consul.d/app.json.ctmpl
#Consul memcached changes
#mv /opt/devops-ctmpl/memcached/consul-service.json.ctmpl /opt/devops-ctmpl/memcached/consul-service.json.ctmpl.bak
#mv /opt/devops-ctmpl/memcached/adaptive_consul-service.json.ctmpl /opt/devops-ctmpl/memcached/consul-service.json.ctmpl

systemctl restart consul-template
sleep 20
chmod 755 /etc/httpd/generate-ssl.sh
/etc/httpd/generate-ssl.sh
/usr/share/script/artifactorySync.sh

#Removing base rpm logstash file
rm -rf /etc/logstash/conf.d/05_tomcat
rm -rf /etc/logstash/conf.d/httpd
rm -rf /etc/consul-template.d/tomcat/logstash.hcl
rm -rf /etc/consul-template.d/httpd/logstash.hcl

#Removing base rpm consul-client file
rm -rf /etc/consul-template.d/tomcat/consul_app.hcl
rm -rf /etc/consul.d/app.json
rm -rf /etc/consul-template.d/memcached/00_consul-service.json.hcl
rm -rf /etc/consul.d/90_memcached.json

chown -hR tomcat:tomcat /usr/share/tomcat/* || :
chown -R tomcat:tomcat /usr/share/tomcat/webapps/* || :
chown -R tomcat:tomcat /usr/share/apr/* || :
chown -R tomcat:tomcat /usr/share/tomcat/conf/*
chown -R tomcat:tomcat /usr/share/tomcat/lib/*
chown -R root:sensu /etc/sensu/conf.d/checks/ && chmod -R 755 /etc/sensu/conf.d/checks/
chown -R root:sensu /etc/sensu/plugins/ && chmod -R 755 /etc/sensu/plugins
sleep 10

# Tomcat should already be running but make sure it is
systemctl restart consul-template
sleep 20
systemctl enable httpd
systemctl enable configSync
systemctl enable logstash-agent
systemctl enable memcached
systemctl enable gettag.service
systemctl enable cloudwatch-alert.service
sleep 10
systemctl restart configSync
systemctl restart memcached
sleep 10
systemctl restart tomcat
systemctl restart httpd
systemctl restart logstash-agent

#Running cloudwatch alert script
#/usr/bin/cloudwatch-alert.sh >> /usr/bin/scriptOutput.log

(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/share/script/artifactorySync.sh") | crontab -
