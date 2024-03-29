#!/bin/bash

function createVpc() {
    vpc_name="$1 VPC"
    vpcCidrBlock=$2
    vpcId=0
    aws_response=$(
        aws ec2 create-vpc \
        --cidr-block "$vpcCidrBlock" \
        --output json
    )

    vpcId=$(echo -e "$aws_response" | /usr/bin/jq '.Vpc.VpcId' | tr -d '"')

    #name the vpc
    aws ec2 create-tags \
    --resources "$vpcId" \
    --tags Key=Name,Value="$vpc_name" \
    --tags Key=tbd,Value="true"

    #add dns support
    modify_response=$(aws ec2 modify-vpc-attribute \
        --vpc-id "$vpcId" \
        --enable-dns-support "{\"Value\":true}")

    #add dns hostnames
    modify_response=$(aws ec2 modify-vpc-attribute \
        --vpc-id "$vpcId" \
        --enable-dns-hostnames "{\"Value\":true}")

    if [ "${vpcId}" == 0 ]; then
        message="create VPC Error"
    fi
}