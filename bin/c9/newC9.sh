#!/bin/bash -f

DEVELOPER_ID="sarma"
IDENAME="awscli2_sam_cdk_node14"        ### This name is visible to other AWS IAM users in the same AWS account.
OWNER_ARN="arn:aws:iam::591580567012:user/sarmaconsole"     ### ARN of any AWS IAM principal (No Groups allowed)
BILLING_REF=tosarma@gmail.com

###-------------------------------------------
CLIENT="none"

AMI_ID=ami-0f478416a181c0707
# AMI_ID="amazonlinux-2-x86_64"

###-------------------------------------------
TAGS=(  Key=application,Value=c9-${DEVELOPER_ID}-${IDENAME} 
        Key=client,Value=${CLIENT}
        Key=layer,Value=developer
        Key=owner,Value=${DEVELOPER_ID}
        Key=billing,Value=${BILLING_REF}@${CLIENT}
        Key=env,Value=dev
    )

###-------------------------------------------
### (BLOG) https://aws.amazon.com/blogs/mt/using-aws-cloud9-aws-codecommit-and-troposphere-to-author-aws-cloudformation-templates/
### (REFERENCE) https://docs.aws.amazon.com/cli/latest/reference/cloud9/create-environment-ec2.html

echo \
aws   cloud9   create-environment-ec2       \
    --name "${DEVELOPER_ID}-${IDENAME}"     \
    --description "(demo) A new instance of Cloud9IDE (via CDK) for ${DEVELOPER_ID}"     \
    --instance-type 't2.micro'              \
    --image-id "${AMI_ID}"      \
    --automatic-stop-time-minutes 30        \
    --owner-arn  ${OWNER_ARN}               \
    --client-request-token  "C9-CLI-create-${DEVELOPER_ID}-${IDENAME}"   \
    --tags "${TAGS[@]}"        \
    $@
aws   cloud9   create-environment-ec2       \
    --name "${DEVELOPER_ID}-${IDENAME}"     \
    --description "(demo) A new instance of Cloud9IDE (via CDK) for ${DEVELOPER_ID}"     \
    --instance-type 't2.micro'              \
    --image-id "${AMI_ID}"      \
    --automatic-stop-time-minutes 30        \
    --owner-arn  ${OWNER_ARN}               \
    --client-request-token  "C9-CLI-create-${DEVELOPER_ID}-${IDENAME}"   \
    --tags "${TAGS[@]}"        \
    $@

    # --subnet-id subnet-12345678             
    # --connection-type "CONNECT_SSH" (default)  or   "CONNECT_SSM"

# if [ $# -le 2 ]; then
#     echo "Usage: $0 <DEVELOPERID> <IDENAME> <OWNER_ARN> --profile xyz --region us-east-2"
#     echo "Example:  $0 843130 Java-v11 arn:aws:iam::591580567012:group/c9-owner --profile sarma-api --region us-east-2"
#     exit 1
# fi
# 
# DEVELOPER_ID="$1"
# IDENAME="$2"        ### This name is visible to other AWS IAM users in the same AWS account.
# OWNER_ARN="$3"            ### ARN of any AWS IAM principal
# shift
# shift
# shift

### EOScript
