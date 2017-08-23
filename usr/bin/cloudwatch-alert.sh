#!/bin/bash
set -x
source /etc/environment  >> /dev/null
source /etc/instancetags >> /dev/null
OUTPUT=$CLOUD_PROVIDER
if [ "$OUTPUT" != "aws" ]
then
     echo "It is not AWS"
     exit 1
 else
     echo "It is AWS!! Good to proceed for creating alerts"
fi
aws cloudwatch describe-alarms --alarm-names $CLOUD_SERVER_GROUP-HIGH-CPUAlarm --region $EC2_REGION | grep AlarmActions >> /dev/null
if [ $? -eq 0 ]
then
      echo "CloudWatch alert is alredy created."
else
     aws cloudwatch put-metric-alarm --alarm-name $CLOUD_SERVER_GROUP-HIGH-CPUAlarm --alarm-description "HIGH CPU Utilitation" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 60 --comparison-operator GreaterThanThreshold --dimensions  Name=AutoScalingGroupName,Value=$CLOUD_SERVER_GROUP --evaluation-periods 4 --alarm-actions $SNSTopic --unit Percent --region $EC2_REGION

     aws cloudwatch put-metric-alarm --alarm-name $CLOUD_SERVER_GROUP-LOW-CPUAlarm --alarm-description "LOW CPU Utilitation" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 900 --threshold 50 --comparison-operator LessThanThreshold --dimensions  Name=AutoScalingGroupName,Value=$CLOUD_SERVER_GROUP --evaluation-periods 2 --alarm-actions $SNSTopic --unit Percent --region $EC2_REGION

     aws cloudwatch put-metric-alarm --alarm-name $CLOUD_SERVER_GROUP-HIGH-MemoryAlarm --alarm-description "HIGH Memory Utilitation" --metric-name MemoryUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 75 --comparison-operator GreaterThanThreshold --dimensions  Name=AutoScalingGroupName,Value=$CLOUD_SERVER_GROUP --evaluation-periods 1 --alarm-actions $SNSTopic --unit Percent --region $EC2_REGION

     aws cloudwatch put-metric-alarm --alarm-name $CLOUD_SERVER_GROUP-LOW-MemoryAlarm --alarm-description "LOW Memory Utilitation" --metric-name MemoryUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 70 --comparison-operator LessThanThreshold --dimensions  Name=AutoScalingGroupName,Value=$CLOUD_SERVER_GROUP --evaluation-periods 2 --alarm-actions $SNSTopic --unit Percent --region $EC2_REGION

fi
