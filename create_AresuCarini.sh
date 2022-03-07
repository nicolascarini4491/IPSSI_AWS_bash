#!/bin/bash

echo "Nom de votre groupe ?"
read GROUPE   #AresuCarini -> nom de notre groupe
echo "Numero de groupe ?"
read NBR      #14 -> numéro de notre groupe
CIDR_VPC="10.$NBR.0.0/16"

### MODE Interractif
#read CIDR_VPC   #10.14.0.0/16
#echo "CIDR de votre SUBNET A ?"
#read CIDR_SA #10.14.1.0/24
#echo "CIDR de votre SUBNET B ?"
#read CIDR_SB #10.14.2.0/24
#echo "CIDR de votre SUBNET C ?"
#read CIDR_SC #10.14.3.0/24
#echo "CIDR de votre SUBNET ADMIN ?"
#read CIDR_ADMIN #10.14.0.0/24

CIDR_VPC="10.$NBR.0.0/16"
CIDR_SA="10.$NBR.1.0/24"
CIDR_SB="10.$NBR.2.0/24"
CIDR_SC="10.$NBR.3.0/24"
CIDR_ADMIN="10.$NBR.0.0/24"

echo $GROUPE
echo $CIDR_VPC
echo $CIDR_SA
echo $CIDR_SB
echo $CIDR_SC
echo $CIDR_ADMIN

#Création du VPC
echo "Création du VPC {'$GROUPE'_VPC_EVAL} en cours"
VPC_ID=$(aws ec2 create-vpc --cidr-block $CIDR_VPC --query Vpc.VpcId --output text --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value='$GROUPE'_VPC_EVAL}]')
echo "VPC créé avec l'ID suivant:"
echo $VPC_ID

#Création des différents subnets
echo "Création du subnet {'$GROUPE'_SubnetA_EVAL}"
SUBNET_A_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $CIDR_SA --availability-zone-id euw3-az1 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value='$GROUPE'_SubnetA_EVAL}]' --output text --query 'Subnet.SubnetId')
echo "Subnet A créé dans la zone Europe de l'Ouest 1 avec l'ID"
echo $SUBNET_A_ID
echo "Création du subnet {'$GROUPE'_SubnetB_EVAL}"
SUBNET_B_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $CIDR_SB --availability-zone-id euw3-az2 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value='$GROUPE'_SubnetB_EVAL}]' --output text --query 'Subnet.SubnetId')
echo "Subnet B créé dans la zone Europe de l'Ouest 2 avec l'ID:"
echo $SUBNET_B_ID
echo "Création du subnet {'$GROUPE'_SubnetC_EVAL}"
SUBNET_C_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $CIDR_SC --availability-zone-id euw3-az3 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value='$GROUPE'_SubnetC_EVAL}]' --output text --query 'Subnet.SubnetId')
echo "Subnet C créé dans la zone Europe de l'Ouest 3 avec l'ID:"
echo $SUBNET_C_ID
echo "Création du subnet {'$GROUPE'_Subnet-Admin_EVAL}"
SUBNET_ADMIN_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $CIDR_ADMIN --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value='$GROUPE'_SubnetADMIN_EVAL}]' --output text --query 'Subnet.SubnetId')
echo "Subnet Admin créé avec l'ID:"
echo $SUBNET_ADMIN_ID

#Création de la passerelle Internet
echo "Création de la passerelle Internet {'$GROUPE'_IGW_EVAL}"
IGW_ID=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value='$GROUPE'_IGW_EVAL}]')
echo "Passerelle Internet créée avec l'ID suivant:"
echo $IGW_ID

#Attachement de la passerelle Internet au VPC
echo "Attachement de la passerelle Internet {'$GROUPE'_IGW_EVAL} au VPC {'$GROUPE'_VPC_EVAL}"
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
echo "Passerelle Internet {'$GROUPE'_IGW_EVAL} au VPC attachée"

#Création de la table de routage Principale
echo "Création de la table de routage {'$GROUPE'_Route_EVAL}"
ROUTE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query RouteTable.RouteTableId --output text --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value='$GROUPE'_Route_EVAL}]')
echo "Table de routage principale {'$GROUPE'_Route_EVAL} créée avec l'ID:"
echo $ROUTE_ID

#Définir la route par défaut de la table de routage principale
echo "Création de la route par défaut de la table de routage principale"
aws ec2 create-route --route-table-id $ROUTE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID
echo "Route par défaut créée"

#Demande d'adresse IP Publique
echo "Allocation d'IP Elastic"
ALLOCATION_ID=$(aws ec2 allocate-address --output text --query AllocationId)
#ALLOCATION_ID=eipalloc-02bbe9f7bce1a1c3d
echo "Allocation d'IP Elastic réussie avec l'ID suivant:"
echo $ALLOCATION_ID

#Création de la passerelle NAT
echo "Création de la passerelle NAT {'$GROUPE'_NGW_EVAL}"
NGW_ID=$(aws ec2 create-nat-gateway --subnet-id $SUBNET_ADMIN_ID --allocation-id $ALLOCATION_ID --output text --query NatGateway.NatGatewayId --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value='$GROUPE'_NGW_EVAL}]')
echo "Passerelle NAT créée avec l'ID suivant:"
echo $NGW_ID

#Création de la table de routage NAT
echo "Création de la table de routage NAT {'$GROUPE_Route_NAT'}"
ROUTE_NAT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query RouteTable.RouteTableId --output text --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value='$GROUPE'_ROUTE_NAT_EVAL}]')
echo "Table de routage NAT créée avec l'ID:"
echo $ROUTE_NAT_ID

#Définir la route par défaut de la table de routage NAT
echo "Création de la route par défaut de la table de routage NAT"
NGW_ID=$(aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=AresuCarini*" "Name=state,Values=available" --output text --query "NatGateways[].NatGatewayId")
for i in $NGW_ID
do
        aws ec2 create-route --route-table-id $ROUTE_NAT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $i
done
echo "Route par défaut créée"

#Jusqu'ici cest bon

#Associations des subnets aux bonnes tables de routage pour permettre aux futurs instances de faire des installations
echo "Associations des subnets aux bonnes tables de routage pour permettre aux subnets de faire des installations"
RTB_ASSOC_A=$(aws ec2 associate-route-table --subnet-id $SUBNET_A_ID --route-table-id $ROUTE_NAT_ID --output text --query 'AssociationId')
RTB_ASSOC_B=$(aws ec2 associate-route-table --subnet-id $SUBNET_B_ID --route-table-id $ROUTE_NAT_ID --output text --query 'AssociationId')
RTB_ASSOC_C=$(aws ec2 associate-route-table --subnet-id $SUBNET_C_ID --route-table-id $ROUTE_NAT_ID --output text --query 'AssociationId')
RTB_ASSOC_ADMIN=$(aws ec2 associate-route-table --subnet-id $SUBNET_ADMIN_ID --route-table-id $ROUTE_ID --output text --query 'AssociationId')
echo "Subnets A, B et C associés à la table de routage {'$GROUPE'_Route_EVAL} avec les rtb_assocs suivants:"
echo $RTB_ASSOC_A
echo $RTB_ASSOC_B
echo $RTB_ASSOC_C
echo $RTB_ASSOC_ADMIN

#Création d'une paire de clés pour accéder à la machine Admin
echo "Création de la paire de clés pour accéder à la machine Admin"
aws ec2 create-key-pair --key-name "$GROUPE"_Admin_SSH_EVAL --query "KeyMaterial" --output text > "$GROUPE"-admin-ssh.pem
echo "Paire de clés créé"
#Création d'une paire de clés pour accéder aux Serveurs Appache
echo "Création de la paire de clés pour accéder aux Serveurs Appache"
aws ec2 create-key-pair --key-name "$GROUPE"_web_SSH_EVAL --query "KeyMaterial" --output text > "$GROUPE"-web-ssh.pem
echo "Paire de clés créée"

#Créer un groupe de sécurité
echo "Création des différents groupes de sécurité"
SG_ADMIN_ID=$(aws ec2 create-security-group --group-name "$GROUPE"_SG_ADMIN_EVAL --description "Autorise SSH" --vpc-id $VPC_ID --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value='$GROUPE'_SG_ADMIN_EVAL}]' --output text --query 'GroupId')
SG_WEB_ID=$(aws ec2 create-security-group --group-name "$GROUPE"_SG_WEB_EVAL --description "Autorise HTTP HTTPS pour LoadBalancer" --vpc-id $VPC_ID --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value='$GROUPE'_SG_WEB_EVAL}]' --output text --query 'GroupId')
SG_LB_ID=$(aws ec2 create-security-group --group-name "$GROUPE"_SG_LB_EVAL --description "Autorise HTTP HTTPS" --vpc-id $VPC_ID --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value='$GROUPE'_SG_LB_EVAL}]' --output text --query 'GroupId')
echo "Groupes de sécurité créés avec les ID suivants:"
echo $SG_ADMIN_ID
echo $SG_WEB_ID
echo $SG_LB_ID

#Ajoute une règle dans le groupe de sécurité
echo "Ajout des règles de sécurité"
aws ec2 authorize-security-group-ingress --group-id $SG_ADMIN_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SG_WEB_ID --protocol tcp --port 80 --source-group $SG_LB_ID
aws ec2 authorize-security-group-ingress --group-id $SG_WEB_ID --protocol tcp --port 22 --cidr $CIDR_ADMIN
aws ec2 authorize-security-group-ingress --group-id $SG_LB_ID --protocol tcp --port 80 --cidr 0.0.0.0/0
echo "Règles de sécurité ajoutées"

#Créer les serveurs web dans les différentes zones
echo "Création des différentes instances"
INSTANCE_A_ID=$(aws ec2 run-instances --image-id ami-0d3c032f5934e1b41 --count 1 --instance-type t2.micro --key-name "$GROUPE"_web_SSH_EVAL --security-group-ids $SG_WEB_ID --subnet-id $SUBNET_A_ID --user-data file://webserver.txt --associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$GROUPE'_INSTANCE_A_EVAL}]' --output text --query 'Instances[*].InstanceId')
INSTANCE_B_ID=$(aws ec2 run-instances --image-id ami-0d3c032f5934e1b41 --count 1 --instance-type t2.micro --key-name "$GROUPE"_web_SSH_EVAL --security-group-ids $SG_WEB_ID --subnet-id $SUBNET_B_ID --user-data file://webserver.txt --associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$GROUPE'_INSTANCE_B_EVAL}]' --output text --query 'Instances[*].InstanceId')
INSTANCE_C_ID=$(aws ec2 run-instances --image-id ami-0d3c032f5934e1b41 --count 1 --instance-type t2.micro --key-name "$GROUPE"_web_SSH_EVAL --security-group-ids $SG_WEB_ID --subnet-id $SUBNET_C_ID --user-data file://webserver.txt --associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$GROUPE'_INSTANCE_C_EVAL}]' --output text --query 'Instances[*].InstanceId')
INSTANCE_ADMIN_ID=$(aws ec2 run-instances --image-id ami-0d3c032f5934e1b41 --count 1 --instance-type t2.micro --key-name "$GROUPE"_Admin_SSH_EVAL --security-group-ids $SG_ADMIN_ID --subnet-id $SUBNET_ADMIN_ID --associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$GROUPE'_INSTANCE_ADMIN_EVAL}]' --output text --query 'Instances[*].InstanceId')
sleep 60
echo "Les différentes instances sont créées avec les ID suivants:"
echo $INSTANCE_A_ID
echo $INSTANCE_B_ID
echo $INSTANCE_C_ID
echo $INSTANCE_ADMIN_ID

#Désassociations des subnets aux tables de routage permettant aux instances de faire des installations
echo "Désassociations des subnets aux tables de routage permettant aux instances de faire des installations"
aws ec2 disassociate-route-table --association-id $RTB_ASSOC_A
aws ec2 disassociate-route-table --association-id $RTB_ASSOC_B
aws ec2 disassociate-route-table --association-id $RTB_ASSOC_C
echo "Désassociations terminées"

#Associations des subnets aux bonnes tables de routage pour permettre au futur LB de fonctionner correctement
echo "Associations des subnets aux bonnes tables de routage pour permettre au futur LoadBalancer de fonctionner correctement"
RTB_ASSOC_A=$(aws ec2 associate-route-table --subnet-id $SUBNET_A_ID --route-table-id $ROUTE_ID --output text --query 'AssociationId')
RTB_ASSOC_B=$(aws ec2 associate-route-table --subnet-id $SUBNET_B_ID --route-table-id $ROUTE_ID --output text --query 'AssociationId')
RTB_ASSOC_C=$(aws ec2 associate-route-table --subnet-id $SUBNET_C_ID --route-table-id $ROUTE_ID --output text --query 'AssociationId')
echo "Subnets A, B et C associés à la table de routage {'$GROUPE'_Route_EVAL} avec les rtb_assocs suivants:"
echo $RTB_ASSOC_A
echo $RTB_ASSOC_B
echo $RTB_ASSOC_C

#Création du Load-Balancer
echo "Création du Load-Balancer {"$GROUPE"_LB_EVAL}"
LB_ARN=$(aws elbv2 create-load-balancer --name "$GROUPE"-LB-EVAL --subnets $SUBNET_A_ID $SUBNET_B_ID $SUBNET_C_ID --security-groups $SG_LB_ID --output text --query 'LoadBalancers[*].LoadBalancerArn')
echo "Load-Balancer créé avec l'ARN suivant:"
echo $LB_ARN

#Création du Target Group
echo "Création du Target Group {"$GROUPE"_TG_EVAL}"
TG_ARN=$(aws elbv2 create-target-group --name "$GROUPE"-TG-EVAL --protocol HTTP --port 80 --vpc-id $VPC_ID --output text --query 'TargetGroups[*].TargetGroupArn')
echo "Target Group créé avec l'ARN suivant:"
echo $TG_ARN

#Création de la liaison entre les instances et le Target Group
echo "Création de la liaison entre les instances et le Target Group"
aws elbv2 register-targets --target-group-arn $TG_ARN --targets Id=$INSTANCE_A_ID Id=$INSTANCE_B_ID Id=$INSTANCE_C_ID
echo "Liaison terminée"

#Création du listener vers le Target Group
aws elbv2 create-listener --load-balancer-arn $LB_ARN --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=$TG_ARN

echo "Le dépoiement de votre infrastructure s'est achevé avec succès !"