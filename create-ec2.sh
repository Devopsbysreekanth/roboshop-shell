#!/bin/bash

NAMES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
INSTANCE_TYPE=""
IMAGE_ID=ami-03265a0778a880afb
SECURITY_GROUP_ID=sg-0285ea5029e3b42a8
DOMAIN_NAME=devopsbysreekanth.online

for i in "${NAMES[@]}"
do

    # Check if instance already exists
    if aws ec2 describe-instances --filters "Name=tag:Name,Values=$i" --query "Reservations[].Instances[].InstanceId" --output text | grep -q '[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}'; then
        echo "$i instance already exists, skipping..."
        continue
    fi


    if [[$i == "mongodb" || $i == "redis" || $i == "mysql" || $i == "rabbitmq"$i == "catalogue" || $i == "user"$i == "cart" || $i == "shipping"$i == "payment" || $i == "web"]]
        then
        INSTANCE_TYPE="t2.micro"
    fi

    echo "creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "created $i instance: $IP_ADDRESS"

    aws route53 change-resource-record-sets --hosted-zone-id Z1003307YHLZ8XIIWXDL --change-batch '
    {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": "'$i.$DOMAIN_NAME'",
                            "Type": "A",
                            "TTL": 300,
                            "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
    }
    '
done
