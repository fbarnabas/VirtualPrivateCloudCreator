
#!/bin/bash
Tags="falusi.barnabas-Trial1"
KeyName="falusi.barnabas@gmail.com"
CidrBlock="10.0.0.0/24" 
Zone="eu-central-1a"

#https://unix.stackexchange.com/questions/314365/get-elapsed-time-in-bash
echo $SECONDS The Virtual Private Cloud Creator script has started

VPCparametersarray=(`aws ec2 create-vpc \
    --cidr-block $CidrBlock  --output text`)
 VPCId=${VPCparametersarray[7]}
 aws ec2 create-tags --resources $VPCId \
    --tags Key=Name,Value="$Tags"
 echo $SECONDS $VPCId VPC created 

Subnetparametersarray=(`aws ec2 create-subnet \
    		--vpc-id $VPCId \
    		--cidr-block $CidrBlock \
		--availability-zone $Zone \
		--output text`)
 SubnetId=${Subnetparametersarray[11]}
 aws ec2 create-tags --resources $SubnetId \
   --tags Key=Name,Value=$Tags
 aws ec2 modify-subnet-attribute \
    --subnet-id $SubnetId \
    --map-public-ip-on-launch
echo $SECONDS $SubnetId subnet created 

Sgparametersarray=(`aws ec2 create-security-group \
   --group-name $Tags \
   --description $Tags \
   --vpc-id $VPCId \
   --output text`)
 SgId=${Sgparametersarray[0]}
 aws ec2 create-tags --resources $SgId \
   --tags Key=Name,Value=$Tags
echo $SECONDS $SgId security group created

aws ec2 authorize-security-group-ingress \
    --group-id $SgId \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id $SgId \
    --protocol icmp \
    --port all \
    --cidr 0.0.0.0/0
echo $SECONDS security group protocols setup completed

Instaparametersarray=(`aws ec2 run-instances \
    --image-id ami-0e0102e3ff768559b \
    --count 1 \
    --instance-type t2.micro \
    --subnet-id $SubnetId \
    --key-name $KeyName \
    --security-group-ids $SgId \
    --output text`)
 InstId=${Instaparametersarray[10]}
 aws ec2 create-tags --resources $InstId \
   --tags Key=Name,Value="$Tags"
echo $SECONDS $InstId instance created
