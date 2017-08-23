#!/bin/sh
yum -y install devops-cpe-base-os
yum -y localinstall build/distributions/*.rpm
/usr/local/bin/goss -g tests/goss.yaml v --format documentation
