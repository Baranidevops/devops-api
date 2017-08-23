#!/bin/sh
# TAG_NAME="WhichEnv"
#INSTANCE_ID="`wget -qO- http://instance-data/latest/meta-data/instance-id`"
#REGION="`wget -qO- http://instance-data/latest/meta-data/placement/availability-zone | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
#TAG_VALUE="`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$TAG_NAME" --region $REGION --output=text | cut -f5`"

echo envcheck:$CLOUD_SERVER_GROUP >> /var/log/checkvalue.log

if [ -z ${CLOUD_PROVIDER} ]; then
  echo "CLOUD_PROVIDER is not set"
  exit 1
# In GCE we're setting this via Spinnaker Custom MetaData
# elif [ "$CLOUD_PROVIDER" == "gce" ]; then
elif [ "$CLOUD_PROVIDER" == "aws" ]; then
  TAG_NAME="`source /etc/environment; aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=WhichEnv" --region=$EC2_REGION --output=text | cut -f5`"
  echo WHICH_ENV=$TAG_NAME >> /etc/environment
  echo WHICH_ENV=$TAG_NAME >> /var/log/envtag.log
else
  echo "CLOUD_PROVIDER is not a valid value"
fi
