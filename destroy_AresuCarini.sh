#!/bin/bash

echo "Nom du groupe dont vous voulez supprimer l'infrastructure ?"
read GROUPE

echo $GROUPE

VPC_ID=$(aws ec2 describe-vpcs --filter "Name=tag:Name,Values="$GROUPE"_VPC_EVAL" --query "Vpcs[].VpcId" --output text)
echo "ID du VPC récupéré"
INSTANCES_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values="$GROUPE"_*" --query "Reservations[].Instances[].InstanceId" --output text)
echo "ID des instances récupérés"
LB_ARN=$(aws elbv2 describe-load-balancers --names "$GROUPE"-LB-EVAL --query 'LoadBalancers[].LoadBalancerArn' --output text)
echo "ARN du LoadBalancer récupéré"
TG_ARN=$(aws elbv2 describe-target-groups --names "$GROUPE"-TG-EVAL --query 'TargetGroups[].TargetGroupArn' --output text)
echo "ARN du Target Group récupéré"
SG_WEB_ID=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values="$GROUPE"_SG_WEB_EVAL" --query 'SecurityGroups[].GroupId' --output text)
echo "ID du Security Group des instances Web récupéré"
SG_ADMIN_ID=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values="$GROUPE"_SG_ADMIN_EVAL" --query 'SecurityGroups[].GroupId' --output text)
echo "ID du Security Group de l'instance Admin récupéré"
SG_LB_ID=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values="$GROUPE"_SG_LB_EVAL" --query 'SecurityGroups[].GroupId' --output text)
echo "ID du Security Group du Load-Balancer récupéré"
SUBNETS_ID=$(aws ec2 describe-subnets --filter "Name=tag:Name,Values="$GROUPE"*" --query 'Subnets[].SubnetId' --output text)
echo "ID des subnets récupérés sous forme de tableau"

SUBNET_A_ID=$(aws ec2 describe-subnets --filter "Name=tag:Name,Values="$GROUPE"_SubnetA_EVAL" --query 'Subnets[].SubnetId' --output text)
echo "ID du subnet A récupéré"
SUBNET_B_ID=$(aws ec2 describe-subnets --filter "Name=tag:Name,Values="$GROUPE"_SubnetB_EVAL" --query 'Subnets[].SubnetId' --output text)
echo "ID du subnet B récupéré"
SUBNET_C_ID=$(aws ec2 describe-subnets --filter "Name=tag:Name,Values="$GROUPE"_SubnetC_EVAL" --query 'Subnets[].SubnetId' --output text)
echo "ID du subnet C récupéré"
SUBNET_ADMIN_ID=$(aws ec2 describe-subnets --filter "Name=tag:Name,Values="$GROUPE"_SubnetADMIN_EVAL" --query 'Subnets[].SubnetId' --output text)
echo "ID du subnet Admin récupéré"

ROUTES_ID=$(aws ec2 describe-route-tables --filter "Name=tag:Name,Values="$GROUPE"*" --query "RouteTables[].RouteTableId" --output text)
echo "ID des tables de routage récupérés"

ROUTE_NAT_ID=$(aws ec2 describe-route-tables --filter "Name=tag:Name,Values="$GROUPE"_ROUTE_NAT_EVAL" --query "RouteTables[].RouteTableId" --output text)
echo "ID de la table de routage NAT récupéré"

ROUTE_ID=$(aws ec2 describe-route-tables --filter "Name=tag:Name,Values="$GROUPE"_Route_EVAL" --query "RouteTables[].RouteTableId" --output text)
echo "ID de la table de routage principal récupéré"


IGW_ID=$(aws ec2 describe-internet-gateways --filter "Name=tag:Name,Values="$GROUPE"_IGW_EVAL" --query "InternetGateways[].InternetGatewayId" --output text)
echo "ID de la passerelle Internet récupérée"
NGW_ID=$(aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=AresuCarini*" "Name=state,Values=available" --output text --query "NatGateways[].NatGatewayId")
echo "ID de la passerelle NAT récupérée"
ALLOCATION_ID=$(aws ec2 describe-addresses --filters "Name=tag:Name,Values=AresuCarini*" --output text --query 'Addresses[].AllocationId')
echo "ID de l'allocation d'adresse IP Elastic récupérée"
RTB_ASSOC_A=$(aws ec2 associate-route-table --subnet-id $SUBNET_A_ID --route-table-id $ROUTE_ID --output text --query 'AssociationId')
RTB_ASSOC_B=$(aws ec2 associate-route-table --subnet-id $SUBNET_B_ID --route-table-id $ROUTE_ID --output text --query 'AssociationId')
RTB_ASSOC_C=$(aws ec2 associate-route-table --subnet-id $SUBNET_C_ID --route-table-id $ROUTE_ID --output text --query 'AssociationId')
RTB_ASSOC_ADMIN=$(aws ec2 associate-route-table --subnet-id $SUBNET_ADMIN_ID --route-table-id $ROUTE_ID --output text --query 'AssociationId')
echo "ID des associations de subnets aux tables de routage récupérés"


echo "Suppression des clés SSH..."
aws ec2 delete-key-pair --key-name "$GROUPE"_Admin_SSH_EVAL
aws ec2 delete-key-pair --key-name "$GROUPE"_web_SSH_EVAL
echo "Clés SSH supprimées"

echo "Résiliation des instances en cours"
aws ec2 terminate-instances --instance-ids $INSTANCES_ID
#sleep 90
echo "Les instances sont résiliées"

echo "Suppression du Load-Balancer"
aws elbv2 delete-load-balancer --load-balancer-arn $LB_ARN
sleep 5
echo "Load-Balancer supprimé"

echo "Suppresion du Target Group"
aws elbv2 delete-target-group --target-group-arn $TG_ARN
sleep 5
echo "Target Group supprimé"

echo "Suppression de la passerelle NAT"
for i in $NGW_ID
do
        aws ec2 delete-nat-gateway --nat-gateway-id $i
        sleep 1
done
echo "Passerelle NAT supprimée"
sleep 3

echo "Libération de l'adresse IP Elastic"
aws ec2 release-address --allocation-id $ALLOCATION_ID
echo "Adresse IP Elastic libérée"
sleep 3

echo "Désassociations des subnets aux tables de routage permettant aux instances de faire des installations"
aws ec2 disassociate-route-table --association-id $RTB_ASSOC_A
aws ec2 disassociate-route-table --association-id $RTB_ASSOC_B
aws ec2 disassociate-route-table --association-id $RTB_ASSOC_C
aws ec2 disassociate-route-table --association-id $RTB_ASSOC_ADMIN
echo "Désassociations terminées"

echo "Suppresion des Security Groups"
sleep 5
aws ec2 delete-security-group --group-id $SG_ADMIN_ID
sleep 5
aws ec2 delete-security-group --group-id $SG_WEB_ID
sleep 5
aws ec2 delete-security-group --group-id $SG_LB_ID
sleep 5
echo "Security Groups supprimés"

echo "Suppression des subnets"
subnet_presence=$(aws ec2 describe-subnets | egrep 'VpcId|SubnetId' | grep $VPC_ID -A1 | grep SubnetId | cut -d'"' -f4)
for i in $subnet_presence
do
        flag=1
        echo "deleting subnet $i..."
        while [ $flag -eq 1 ]
        do
                aws ec2 delete-subnet --subnet-id $i > /dev/null 2>&1
                if [ "$?" == "0" ]
                then
                        flag=0
                fi
                sleep 2
        done
        echo $i
        echo $VPC_ID
done
echo "Subnets supprimés"

echo "Suppresion des tables de routage"
for i in $ROUTES_ID
do
        aws ec2 delete-route-table --route-table-id $i
        sleep 2
done
echo "Tables de routage supprimées"

echo "Détachement de la passerelle Internet"
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
sleep 3
echo "Passerelle Internet détachée"
echo "Suppresion de la passerelle Internet"
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID
sleep 3
echo "Passerelle Internet supprimée"

echo "Suppresion du VPC"
aws ec2 delete-vpc --vpc-id $VPC_ID
echo "VPC supprimé"
