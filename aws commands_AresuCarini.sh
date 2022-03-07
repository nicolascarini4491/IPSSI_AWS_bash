aws ec2 create-vpc --cidr-block 10.14.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=AresuCarini_VPC_EVAL -vpc}]'
aws ec2 create-subnet --vpc-id vpc-06711218f50b84610 --cidr-block 10.14.1.0/24 --availibility-zone-id euw3-az1 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=AresuCarini_SubnetA_EVAL}]'
aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=AresuCarini_IGW_EVAL}]'
aws ec2 attach-internet-gateway --vpc-id vpc-06711218f50b84610 --internet-gateway-id igw-0c399f524ead81473
aws ec2 create-route-table --vpc-id vpc-06711218f50b84610 --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=AresuCarini_Route_EVAL}]'
aws ec2 create-route --route-table-id rtb-0a9c25f74543e5374 --destination-cidr-block 0.0.0.0/0 --gateway-id igw-0c399f524ead81473
aws ec2 associate-route-table --subnet-id subnet-0e635c8648989fc8e --route-table-id rtb-0a9c25f74543e5374
aws ec2 associate-route-table --subnet-id subnet-0c2936ed9f6b3ccbc --route-table-id rtb-0a9c25f74543e5374
aws ec2 associate-route-table --subnet-id subnet-056c98f398617c08d --route-table-id rtb-0a9c25f74543e5374
aws ec2 create-key-pair --key-name AresuCarini_keypair_EVAL > AresuCarini_keypair.pem
aws ec2 create-security-group --group-name AresuCarini_SG_EVAL --description SSH OK --vpc-id vpc-06711218f50b84610 --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=AresuCarini_SG_EVAL}]'
aws ec2 authorize-security-group-ingress --group-id sg-0aabd6a129444c3ca --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 create-subnet --vpc-id vpc-06711218f50b84610 --cidr-block 10.14.0.0/24 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=AresuCarini_Subnet-Admin_EVAL}]'
aws ec2 associate-route-table --subnet-id subnet-079ea2e9072f83845 --route-table-id rtb-0a9c25f74543e5374
aws ec2 run-instances --image-id ami-0d1533530bc7a81ba --count 1 --instance-type t2.micro --key-name AresuCarini_keypair_Admin_EVAL --security-group-ids sg-0aabd6a129444c3ca --subnet-id subnet-079ea2e9072f83845 --user-data file://userdata --associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=AresuCarini_Admin_EVAL}]'
aws ec2 create-nat-gateway --subnet-id subnet-079ea2e9072f83845 --allocation-id eipalloc-0338db4c9f6378aad --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=AresuCarini_NatG_EVAL}]'
aws ec2 create-route-table --vpc-id vpc-06711218f50b84610 --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=AresuCarini_NAT-Route_EVAL}]'
aws ec2 create-route --route-table-id rtb-0113fc625c5efbe0b --destination-cidr-block 0.0.0.0/0 --gateway-id nat-0c6108673a7fb1ed3
aws ec2 associate-route-table --subnet-id subnet-0c2936ed9f6b3ccbc --route-table-id rtb-0113fc625c5efbe0b
aws ec2 authorize-security-group-ingress --group-id sg-0aabd6a129444c3ca --protocol tcp --port 403 --cidr 0.0.0.0/0
aws ec2 run-instances --image-id ami-0d1533530bc7a81ba --count 1 --instance-type t2.micro --key-name AresuCarini_keypair_EVAL --security-group-ids sg-0aabd6a129444c3ca --subnet-id subnet-0c2936ed9f6b3ccbc --user-data file://userdata --no-associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=AresuCarini_ServerA_EVAL}]'
aws ec2 run-instances --image-id ami-0d1533530bc7a81ba --count 1 --instance-type t2.micro --key-name AresuCarini_keypair_EVAL --security-group-ids sg-0aabd6a129444c3ca --subnet-id subnet-056c98f398617c08d --user-data file://userdata --no-associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=AresuCarini_ServerB_EVAL}]'
aws ec2 run-instances --image-id ami-0d1533530bc7a81ba --count 1 --instance-type t2.micro --key-name AresuCarini_keypair_EVAL --security-group-ids sg-0aabd6a129444c3ca --subnet-id subnet-0e635c8648989fc8e --user-data file://userdata --no-associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=AresuCarini_ServerC_EVAL}]'
aws ec2 create-subnet --vpc-id vpc-06711218f50b84610 --cidr-block 10.14.2.0/24 --availability-zone-id euw3-az2 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=AresuCarini_SubnetB_EVAL}]'
aws ec2 create-subnet --vpc-id vpc-06711218f50b84610 --cidr-block 10.14.3.0/24 --availability-zone-id euw3-az3 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=AresuCarini_SubnetC_EVAL}]'
aws ec2 associate-route-table --subnet-id subnet-0c2936ed9f6b3ccbc --route-table-id rtb-0a9c25f74543e5374
aws ec2 associate-route-table --subnet-id subnet-0330d9b424cf78570 --route-table-id rtb-0a9c25f74543e5374
aws ec2 associate-route-table --subnet-id subnet-0faf7bf94550d5937 --route-table-id rtb-0a9c25f74543e5374
aws ec2 associate-route-table --subnet-id subnet-0330d9b424cf78570 --route-table-id nat-0c6108673a7fb1ed3
aws ec2 associate-route-table --subnet-id subnet-0faf7bf94550d5937 --route-table-id rtb-0113fc625c5efbe0b
aws ec2 run-instances --image-id ami-0d1533530bc7a81ba --count 1 --instance-type t2.micro --key-name AresuCarini_keypair_EVAL --security-group-ids sg-0aabd6a129444c3ca --subnet-id subnet-0330d9b424cf78570 --user-data file://userdata --no-associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=AresuCarini_ServerB_EVAL}]'
aws ec2 run-instances --image-id ami-0d1533530bc7a81ba --count 1 --instance-type t2.micro --key-name AresuCarini_keypair_EVAL --security-group-ids sg-0aabd6a129444c3ca --subnet-id subnet-0faf7bf94550d5937 --user-data file://userdata --no-associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=AresuCarini_ServerC_EVAL}]'
aws elbv2 create-load-balancer --name AresuCarini-LB-EVAL --subnets subnet-0c2936ed9f6b3ccbc subnet-0330d9b424cf78570 subnet-0faf7bf94550d5937 --security-groups sg-0aabd6a129444c3ca
aws elbv2 create-target-group --name AresuCarini-TG --protocol HTTP --port 80 --vpc-id vpc-06711218f50b84610
aws elbv2 register-targets --target-group-arn arn:aws:elasticloadbalancing:eu-west-3:962615889483:targetgroup/AresuCarini-TG/24322aff7f1260ee --targets ID=i-0f620157a4fa722f6 ID=i-08ac4785ae9d5fe1d ID=i-0a555775033441e0b
aws elbv2 create-listener --load-balancer-arn arn:aws:elasticloadbalancing:eu-west-3:962615889483:loadbalancer/app/AresuCarini-LB-EVAL/8d2dbb8abea9f378 --protocol HTTP --port 80 --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:eu-west-3:962615889483:targetgroup/AresuCarini-TG/24322aff7f1260ee
aws ec2 associate-route-table --subnet-id subnet-0c2936ed9f6b3ccbc --route-table-id rtb-0a9c25f74543e5374
aws ec2 associate-route-table --subnet-id subnet-0330d9b424cf78570 --route-table-id rtb-0a9c25f74543e5374
aws ec2 associate-route-table --subnet-id subnet-0faf7bf94550d5937 --route-table-id rtb-0a9c25f74543e5374
aws ec2 create-security-group --group-name AresuCarini_SG-Web_EVAL --description SSH HTTP HTTPS ICMP OK --vpc-id vpc-06711218f50b84610 --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=AresuCarini_SG-Web_EVAL}]'
