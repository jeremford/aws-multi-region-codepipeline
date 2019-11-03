#!/bin/sh

PRIMARY_REGION=ap-southeast-2
SECONDARY_REGION=us-east-1

PROD_APPROVAL_EMAIL=jez@garn.cc

AwsAccount=$(aws sts get-caller-identity --output text --query 'Account' --region "${PRIMARY_REGION}")
#
# printf "\nDeploying Prerequisites pipeline in $PRIMARY_REGION\n"
#
# aws cloudformation validate-template \
#   --region $PRIMARY_REGION \
#   --template-body "file://pipelines/pre-req-pipeline.yml"
#
# if [[ $? -gt 0 ]]; then
#     echo "pre-req-pipeline.yml is not valid"
#     exit 1
# fi
#
# #Deploy Prerequisites in Primary Region
# aws cloudformation deploy \
#   --region $PRIMARY_REGION \
#   --template-file pipelines/pre-req-pipeline.yml \
#   --stack-name MULTI-REGION-PIPELINE-PREREQ \
#   --capabilities CAPABILITY_NAMED_IAM \
#   --parameter-overrides SourceS3Key=prereq-templates.zip PRODApprovalEmail=$PROD_APPROVAL_EMAIL \
#   --tags Environment=PROD Purpose="Multi Region CodePipeline Prerequisites"
#
# printf "\nChecking CloudFormation Stack status in $PRIMARY_REGION\n"
#
# aws cloudformation wait stack-update-complete --region $PRIMARY_REGION --stack-name MULTI-REGION-PIPELINE-PREREQ
# if [[ $? -gt 0 ]]; then
#   aws cloudformation wait stack-create-complete --region $PRIMARY_REGION --stack-name MULTI-REGION-PIPELINE-PREREQ
# fi
#
# printf "\nCloudFormation Stack in $PRIMARY_REGION now CREATED\n"
#
#
# printf "\nDeploying Prerequisites pipeline in $SECONDARY_REGION\n"
#
# #Deploy Prerequisites in Primary Region
# aws cloudformation deploy \
#   --region $SECONDARY_REGION \
#   --template-file pipelines/pre-req-pipeline.yml \
#   --stack-name MULTI-REGION-PIPELINE-PREREQ \
#   --capabilities CAPABILITY_NAMED_IAM \
#   --parameter-overrides SourceS3Key=prereq-templates.zip PRODApprovalEmail=$PROD_APPROVAL_EMAIL \
#   --tags Environment=PROD Purpose="Multi Region CodePipeline Prerequisites"
#
# printf "\nChecking CloudFormation Stack status in $SECONDARY_REGION\n"
#
# aws cloudformation wait stack-update-complete --region $SECONDARY_REGION --stack-name MULTI-REGION-PIPELINE-PREREQ
# if [[ $? -gt 0 ]]; then
#   aws cloudformation wait stack-create-complete --region $SECONDARY_REGION --stack-name MULTI-REGION-PIPELINE-PREREQ
# fi
#
# printf "\nCloudFormation Stack in $SECONDARY_REGION now CREATED\n"


printf "\nDeploying Multi Region Pipelinein $PRIMARY_REGION\n"

#Lookup Prerequisites S3 Bucket in Primary Region
PrimaryPrereqS3Bucket=$(aws cloudformation describe-stacks --region ${PRIMARY_REGION} --stack-name MULTI-REGION-PIPELINE-PREREQ | jq -r '.Stacks[0].Outputs[0].OutputValue' )
#Lookup Prerequisites S3 Bucket in Primary Region
SecondaryPrereqS3Bucket=$(aws cloudformation describe-stacks --region ${SECONDARY_REGION} --stack-name MULTI-REGION-PIPELINE-PREREQ | jq -r '.Stacks[0].Outputs[0].OutputValue' )


#Deploy Prerequisites in Primary Region
aws cloudformation deploy \
  --region $PRIMARY_REGION \
  --template-file pipelines/multi-region-pipeline.yml \
  --stack-name MULTI-REGION-PIPELINE \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides PrimaryRegion=$PRIMARY_REGION SecondaryRegion=$SECONDARY_REGION PrimaryRegionS3ArtifactBucket=$PrimaryPrereqS3Bucket SecondaryRegionS3ArtifactBucket=$SecondaryPrereqS3Bucket SourceS3Key=multi-region-templates.zip PRODApprovalEmail=$PROD_APPROVAL_EMAIL \
  --tags Environment=PROD Purpose="Multi Region CodePipeline"
