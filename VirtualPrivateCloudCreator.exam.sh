
#!/bin/bash
Tags="falusi.barnabas-Trial1"
# Function Definitions

CreateVPC () {
 VPCparametersarray=(`aws ec2 create-vpc \
    --cidr-block 10.0.0.0/24  --output text`)
 export VPCId=${VPCparametersarray[7]}
 aws ec2 create-tags --resources $VPCId \
    --tags Key=Name,Value="$1"
 echo $VPCId;
}

createsubnet () {
 Subnetparametersarray=(`
	aws ec2 create-subnet \
    		--vpc-id $VPCId \
    		--cidr-block $2 \
		--availability-zone $3 \
		--output text
 `)
 SubnetId=${Subnetparametersarray[11]}
 aws ec2 create-tags --resources $SubnetId \
   --tags Key=Name,Value="$1"
 echo $SubnetId 
 #echo ${Subnetparametersarray[11]}
}

createigw () {
 Igwparametersarray=(`aws ec2 create-internet-gateway --output text`)
 IgwId=${Igwparametersarray[1]}
 aws ec2 create-tags --resources $IgwId \
   --tags Key=Name,Value="$1"
 echo $IgwId 
}

allocate_eip () {
 EIPparametersarray=(`aws ec2 allocate-address --output text`)
 EIPId=${EIPparametersarray[0]}
 echo $EIPId
 aws ec2 create-tags --resources $EIPId \
   --tags Key=Name,Value="$1"
}

#https://docs.aws.amazon.com/cli/latest/reference/ec2/create-nat-gateway.html 
createngw () {
 Ngwparametersarray=(`aws ec2 create-nat-gateway \
   --subnet-id $2 \
   --allocation-id $3 \
   --output text`)
 NgwId=${Ngwparametersarray[3]}
 # echo ${Ngwparametersarray[1]}
 # echo ${Ngwparametersarray[2]}
 # echo ${Ngwparametersarray[3]}
 aws ec2 create-tags --resources $NgwId \
   --tags Key=Name,Value="$1"
 echo $NgwId
}
createsg () {
 sgparametersarray=(`aws ec2 create-security-group \
   --group-name $2 \
   --description $3 \
   --vpc-id $1 \
   --output text`)
SgId=${sgparametersarray[0]}
# echo ${sgparametersarray[0]}
# echo ${sgparametersarray[1]}
echo $SgId
 aws ec2 create-tags --resources $SgId \
   --tags Key=Name,Value="$4"
}

#The main program starts here

#https://unix.stackexchange.com/questions/314365/get-elapsed-time-in-bash

echo $SECONDS The Virtual Private Cloud Creator script has started 

#https://linuxize.com/post/bash-check-if-file-exists/
if [ -f "VPCId.txt" ]; then
    echo $SECONDS "VPC is already present, not creating again"
    VPCId=$(cat VPCId.txt)
else 
  VPCId=$(CreateVPC "falusi.barnabas-Trial1")
  printf "%s" "$VPCId" > VPCId.txt
  echo $SECONDS "VPC successfully created: $VPCId"
fi

Subnet1ApubName="falusi.barnabas-Trial1"
if [ -f "Subnet1ApubId.txt" ]; then
    echo $SECONDS "$Subnet1ApubName subnet is already present,not creating again"
  Subnet1ApubId=$(cat "Subnet1ApubId.txt")
else
  Subnet1ApubId=$(createsubnet "$Subnet1ApubName" "10.0.0.0/24" "eu-central-1a")
  printf "%s" "$Subnet1ApubId" > Subnet1ApubId.txt
  echo "$SECONDS $Subnet1ApubName subnet successfully created" 
fi

Sgname="falusi.barnabas-Trial1"
Sgdescription="falusi.barnabas-Trial1"
Sgnametag="falusi.barnabas-Trial1"

if [ -f "SgId.txt" ]; then
   echo $SECONDS $Sgnametag security group is already present,not creating again
  SgId=$(cat "SgId.txt")
else
  SgId=$(createsg "$VPCId" "$Sgname" "$Sgdescription" "$Sgnametag")
  printf "%s" "$SgId" > SgId.txt
  echo "$SECONDS $SgId security group successfully created"
fi
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

aws ec2 modify-subnet-attribute \
    --subnet-id $Subnet1ApubId \
    --map-public-ip-on-launch

Instaparametersarray=(`aws ec2 run-instances \
    --image-id ami-0e0102e3ff768559b \
    --count 1 \
    --instance-type t2.micro \
    --subnet-id $Subnet1ApubId \
    --key-name "falusi.barnabas@gmail.com" \
    --security-group-ids $SgId \
    --output text`)
InstId=${Instaparametersarray[10]}
 aws ec2 create-tags --resources $InstId \
   --tags Key=Name,Value="$Tags"
echo $SECONDS $InstId instance created
IgwName=$Tags
if [ -f "IgwId.txt" ]; then
  echo $SECONDS \
  " $IgwName igw is already present, not creating again"

  IgwId=$(cat IgwId.txt)
else
  IgwId=$(createigw "$IgwName")
  printf "%s" "$IgwId" > IgwId.txt
  echo $SECONDS $IgwName igw successfully created
fi

if [ -f "IgwAttached.txt" ]; then
  echo $SECONDS \
  " $IgwName igw is already attached, not attaching again"
else
aws ec2 attach-internet-gateway \
  --internet-gateway-id $IgwId  \
  --vpc-id $VPCId
touch IgwAttached.txt
fi

Rtparametersarray=(`aws ec2 create-route-table \
   --vpc-id $VPCId \
   --output text`)
RtId=${Rtparametersarray[10]}
echo $RtId

#aws ec2 create-route --route-table-id rtb-22574640 --destination-cidr-block 0.0.0.0/0 --gateway-id igw-c0a643a9
