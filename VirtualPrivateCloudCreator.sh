#!/bin/bash
# Function Definitions

CreateVPC () {
 VPCparametersarray=(`aws ec2 create-vpc \
    --cidr-block 10.3.0.0/16 --output text`)
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



#The main program starts here

#https://unix.stackexchange.com/questions/314365/get-elapsed-time-in-bash

echo $SECONDS The Virtual Private Cloud Creator script has started 

#https://linuxize.com/post/bash-check-if-file-exists/
if [ -f "VPCId.txt" ]; then
    echo $SECONDS "VPC is already present, not creating again"
    VPCId=$(cat VPCId.txt)
else 
  VPCId=$(CreateVPC "Barnabás - HA Blogger Bros")
  printf "%s" "$VPCId" > VPCId.txt
  echo $SECONDS "VPC successfully created: Barnabás - HA Blogger Bros"
fi

Subnet1ApubName="Barnabás - HA Blogger Bros AZ-1A-public subnet"
if [ -f "Subnet1ApubId.txt" ]; then
    echo $SECONDS " $Subnet1ApubName is already present,not creating again"
  Subnet1ApubId=$(cat "Subnet1ApubId.txt")
else
  SubnetId1Apub=$(createsubnet "$Subnet1ApubName" "10.3.0.0/18" "eu-central-1a")
  printf "%s" "$SubnetId1Apub" > Subnet1ApubId.txt
  echo "$SECONDS $Subnet1ApubName successfully created" 
fi

Subnet1ApriName="Barnabás - HA Blogger Bros AZ-1A-private subnet"
if [ -f "Subnet1ApriId.txt" ]; then
    echo $SECONDS " $Subnet1ApriName is already present, not creating again"
  Subnet1ApriId=$(cat "Subnet1ApriId.txt")
else
  SubnetId1Apri=$(createsubnet "$Subnet1ApriName" "10.3.64.0/18" "eu-central-1a")
  printf "%s" "$SubnetId1Apri" > Subnet1ApriId.txt
  echo "$SECONDS $Subnet1ApriName successfully created"
fi

Subnet1BpubName="Barnabás - HA Blogger Bros AZ-1B-public subnet"
if [ -f "Subnet1BpubId.txt" ]; then
    echo $SECONDS " $Subnet1BpubName is already present, not creating again"
  Subnet1BpubId=$(cat "Subnet1BpubId.txt")
else
  Subnet1BpubId=$(createsubnet \
  "$Subnet1BpubName" "10.3.128.0/18" "eu-central-1b")
  printf "%s" "$Subnet1BpubId" > Subnet1BpubId.txt
  echo "$SECONDS $Subnet1BpubName successfully created"
fi

Subnet1BpriName="Barnabás - HA Blogger Bros AZ-1B-private subnet"
if [ -f "Subnet1BpriId.txt" ]; then
    echo $SECONDS " $Subnet1BpriName is already present, not creating again"
  Subnet1BpriId=$(cat "Subnet1BpriId.txt")

else
  SubnetId1Bpri=$(createsubnet \
  "$Subnet1BpriName" "10.3.192.0/18" "eu-central-1b")
  printf "%s" "$SubnetId1Bpri" > Subnet1BpriId.txt
  echo "$SECONDS $Subnet1BpriName subnet successfully created" 
fi

IgwName="Barnabás - HA Blogger Bros Igw"
if [ -f "IgwId.txt" ]; then
  echo $SECONDS \
  " $IgwName is already present, not creating again"
  IgwId=$(cat IgwId.txt)
else
  IgwId=$(createigw "$IgwName")
  printf "%s" "$IgwId" > IgwId.txt
  echo $SECONDS $IgwName successfully created
fi

if [ -f "IgwAttached.txt" ]; then
  echo $SECONDS \
  " $IgwName is already attached, not attaching again"
else
aws ec2 attach-internet-gateway \
  --internet-gateway-id $IgwId  \
  --vpc-id $VPCId
touch IgwAttached.txt
fi

EIP1AName="Barnabás - HA Blogger Bros EIP1A"
if [ -f "EIP1AId.txt" ]; then
  echo $SECONDS \
  " $EIP1AName is already allocated, not allocating again"
  EIP1AId=$(cat EIP1AId.txt)
else
  EIP1AId=$(allocate_eip "$EIP1AName")
  printf "%s" "$EIP1AId" > EIP1AId.txt
  echo $SECONDS $EIP1AName successfully allocated
fi

EIP1BName="Barnabás - HA Blogger Bros EIP1B"
if [ -f "EIP1BId.txt" ]; then
  echo $SECONDS \
  " $EIP1BName is already allocated, not allocating again"
  EIP1BId=$(cat EIP1BId.txt)
else
  EIP1BId=$(allocate_eip "$EIP1BName")
  printf "%s" "$EIP1BId" > EIP1BId.txt
  echo $SECONDS $EIP1BName successfully allocated
fi

Ngw1AName="Barnabás - HA Blogger Bros Ngw"
if [ -f "Ngw1AId.txt" ]; then
  echo $SECONDS \
  " $Ngw1AName is already created, not creating again"
  Ngw1AId=$(cat Ngw1AId.txt)
else
  Ngw1AId=$(createngw "$Ngw1AName" "$Subnet1ApriId" "$EIP1AId")
  printf "%s" "$Ngw1AId" > Ngw1AId.txt
  echo $SECONDS $Ngw1AName successfully created
fi

aws ec2 run-instances --image-id ami-0189961df12a252af \
  --count 1 --instance-type t2.micro --subnet-id $Subnet1ApubId  



