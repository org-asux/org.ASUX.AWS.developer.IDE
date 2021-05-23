#!/bin/bash -f

### Run this script on C9 cmdline, to auto-decipher the URL to your React.js web-app (that's running on the C9-terminal).
### This script will also provide you the AWS-CLI command to add the appropriate security-group entry, to enable the access

if [ $# -le 1 ]; then
    echo ''
    echo "Usage: $0 <My-Laptop's-IP-Address>    <Port#-of-ReactApp>"
    echo "  https://www.google.com/search?q=whats+my+ip "
    echo ''
    exit 1
fi

###-------------------------------

# MYIP="67.82.53.94/32"    ### !!!!! ATTENTION !!!!! Change this value
MYIP="$1"
MYIP="${MYIP}/32"

WEBAPPPORT="$2"

echo "My IP Address (as entered) is: ${MYIP}"
echo "The React.js App is running LOCALLY on port # ${WEBAPPPORT}"
echo ''

###-------------------------------

### Cloud9's EC2 instance - details
### hostname like  ip-10-198-7-20
### ifconfig - eth0 10.198.x.x      docker 172.17.0.1    

### EC2-CONSOLE-CONSOLE - details
### Private IPv4 addresses (this matches the eth0-interface ip)

### aws ec2 describe-instances
### https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html
### private-dns-name === "Private IPv4 DNS" field on EC2-console   === $(hostname).ec2.internal
### private-ip-address
### network-interface.addresses.private-ip-address
### network-interface.private-dns-name
### network-interface.association.public-ip
### network-interface.private-dns-name  === $(hostname).ec2.internal
### tag:VitalizeId == vpluto2
### tag:Project = vpluto2_plutopoc2

### aws ec2 describe-security-groups
### https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html
### group-id
### group-name
###

###-------------------------------
TMPDIR=/tmp/$(basename $0)
mkdir -p "${TMPDIR}"

EC2DETAILS=${TMPDIR}/c9-ec2-details.json
SGDETAILS=${TMPDIR}/c9-sg-details.json

# echo "${EC2DETAILS}"
# echo "${SGDETAILS}"
echo $(hostname)

aws ec2 describe-instances --filters \
    Name=private-dns-name,Values=$(hostname) >  "${EC2DETAILS}"

###-------------------------------

# cat "${EC2DETAILS}" | jq '.Reservations[0].Instances[0].InstanceId, .Reservations[0].Instances[0].PublicDnsName, .Reservations[0].Instances[0].PublicIpAddress'

CMDOUTPUT=$(cat "${EC2DETAILS}" | jq '.Reservations[].Instances[].InstanceId')
eval "INSTANCEID=${CMDOUTPUT}"      ### Previous line generates a value WITH DOUBLE-QUOTES.  This line removes that

CMDOUTPUT=$(cat "${EC2DETAILS}" | jq '.Reservations[].Instances[].PublicDnsName')
eval "PUBLICFQDN=${CMDOUTPUT}"      ### Previous line generates a value WITH DOUBLE-QUOTES.  This line removes that

CMDOUTPUT=$(cat "${EC2DETAILS}" | jq '.Reservations[].Instances[].PublicIpAddress')
eval "PUBLICIP=${CMDOUTPUT}"        ### Previous line generates a value WITH DOUBLE-QUOTES.  This line removes that

CMDOUTPUT=$(cat "${EC2DETAILS}" | jq '.Reservations[].Instances[].SecurityGroups[].GroupId')
eval "SGID=${CMDOUTPUT}"            ### Previous line generates a value WITH DOUBLE-QUOTES.  This line removes that

echo 'InstanceId =' ${INSTANCEID}
echo 'PublicDnsName =' ${PUBLICFQDN}
echo 'PublicIpAddress =' ${PUBLICIP}
echo 'SecurityGroup-GroupId =' ${SGID}

###-------------------------------

aws ec2 describe-security-groups --group-ids  ${SGID} > ${SGDETAILS}
CMDOUTPUT=$(cat "${SGDETAILS}" | jq ".SecurityGroups[].IpPermissions[] | select(.FromPort == ${WEBAPPPORT}) | .FromPort" | wc -l)

if [ ${CMDOUTPUT} == 1 ]; then
    echo "Security group already has Rules for WEBAPPPORT # ${WEBAPPPORT}"
else
    echo ''
    echo "Add new SG Incoming rule for WEBAPPPORT # ${WEBAPPPORT}"

    ### authorize-security-group-ingress
    ### https://docs.aws.amazon.com/cli/latest/reference/ec2/authorize-security-group-ingress.html
    echo aws ec2 authorize-security-group-ingress \
        --group-id ${SGID} --protocol tcp --port ${WEBAPPPORT} --cidr ${MYIP}

    # FromPort=${WEBAPPPORT},IpProtocol=tcp,IpRanges=[{CidrIp="MyIP",Description="Allow access to React.js Web-app running on Cloud9-Instance ${InstanceId}"}],ToPort=integer

fi

echo ''
echo "Open a new Tab in Cloud9 for  http://${PUBLICFQDN}:${WEBAPPPORT}"

### EoScript
