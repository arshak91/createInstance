#!/bin/bash

function createRouteTable() {
    routeTableName="$1 Route Table"
    vpcId=$2
    gatewayId=$3
    subnetId=$4
    destinationCidrBlock=$5

    routeTableId=0

    #create route table for vpc
    route_table_response=$(aws ec2 create-route-table \
    --vpc-id "$vpcId" \
    --output json)
    routeTableId=$(echo -e "$route_table_response" |  /usr/bin/jq '.RouteTable.RouteTableId' | tr -d '"')

    #name the route table
    aws ec2 create-tags \
    --resources "$routeTableId" \
    --tags Key=Name,Value="$routeTableName"

    #add tbd tag
    aws ec2 create-tags \
    --resources "$routeTableId" \
    --tags Key=tbd,Value="true"

    #add route for the internet gateway
    route_response=$(aws ec2 create-route \
    --route-table-id "$routeTableId" \
    --destination-cidr-block "$destinationCidrBlock" \
    --gateway-id "$gatewayId")

    #add route to subnet
    associate_response=$(aws ec2 associate-route-table \
        --subnet-id "$subnetId" \
        --route-table-id "$routeTableId"
    )

    if [ "${routeTableId}" == 0 ]; then
        message="create Route Table Error"
    fi
}