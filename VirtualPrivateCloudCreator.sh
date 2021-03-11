#!/bin/bash

#Create VPC
#VPCparametersarray=(`aws ec2 create-vpc --cidr-block 10.3.0.0/16 --output text`)
#export VPCId=${VPCparametersarray[7]}
#aws ec2 create-tags --resources $VPCId --tags Key=Name,Value='Barnabás - HA Blogger Bros'
#echo $VPCId;

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
 
createngw () {
 Ngwparametersarray=(`aws ec2 create-nat-gateway \
   --subnet-id $2 \ 
   --output text`)
 echo ${Igwparametersarray[1]}
 echo ${Igwparametersarray[2]}
 echo ${Igwparametersarray[3]}
 aws ec2 create-tags --resources $NgwId \
   --tags Key=Name,Value="$1"
 #echo $NgwId
}



#export SubnetId1Apub=$(createsubnet "Barnabás - HA Blogger Bros AZ-1A-public subnet" \
#  "10.3.0.0/18" "eu-central-1a")
#export SubnetId1Apri=$(createsubnet "Barnabás - HA Blogger Bros AZ-1A-private subnet" \
#  "10.3.64.0/18" "eu-central-1a")
#export SubnetId1Bpub=$(createsubnet "Barnabás - HA Blogger Bros AZ-1B-public subnet" \
#  "10.3.128.0/18" "eu-central-1b")
#export SubnetId1Bpri=$(createsubnet "Barnabás - HA Blogger Bros AZ-1B-private subnet" \
#  "10.3.192.0/18" "eu-central-1b")

#export IgwId=$(createigw "Barnabás - HA Blogger Bros Igw")
#echo $IgwId
#aws ec2 attach-internet-gateway \
#  --internet-gateway-id $IgwId  \
#  --vpc-id $VPCId

#export NgwId1A=$(createngw "Barnabás - HA Blogger Bros Ngw", $SubnetId1Apri)

#allocate_eip "Barnabás - HA Blogger Bros EIP1A"

export EIPId1A=$(allocate_eip "Barnabás - HA Blogger Bros EIP1A")
export EIPId1B=$(allocate_eip "Barnabás - HA Blogger Bros EIP1B")
echo $EIPId1A
echo $EIPId1B


