#!/bin/sh

PRIMARY_REGION=ap-southeast-2
SECONDARY_REGION=us-east-1

PROD_APPROVAL_EMAIL=your@email.here


printf "\nDeploying Prerequisites pipeline in $PRIMARY_REGION\n"

aws cloudformation validate-template \
  --region $PRIMARY_REGION \
  --template-body "file://pipelines/pre-req-pipeline.yml"

if [[ $? -gt 0 ]]; then
    echo "pre-req-pipeline.yml is not valid"
    exit 1
fi

#Deploy Prerequisites Pipeline in Primary Region
aws cloudformation deploy \
  --region $PRIMARY_REGION \
  --template-file pipelines/pre-req-pipeline.yml \
  --stack-name MULTI-REGION-PIPELINE-PREREQ \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides SourceS3Key=prereq-templates.zip PRODApprovalEmail=$PROD_APPROVAL_EMAIL \
  --tags Environment=PROD Purpose="Multi Region CodePipeline Prerequisites"

printf "\nChecking CloudFormation Stack status in $PRIMARY_REGION\n"

aws cloudformation wait stack-create-complete --region $PRIMARY_REGION --stack-name MULTI-REGION-PIPELINE-PREREQ

printf "\nCloudFormation Stack in $PRIMARY_REGION now CREATED\n"

printf "\nDeploying Prerequisites pipeline in $SECONDARY_REGION\n"

#Deploy Prerequisites Pipeline in Secondary Region
aws cloudformation deploy \
  --region $SECONDARY_REGION \
  --template-file pipelines/pre-req-pipeline.yml \
  --stack-name MULTI-REGION-PIPELINE-PREREQ \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides SourceS3Key=prereq-templates.zip PRODApprovalEmail=$PROD_APPROVAL_EMAIL \
  --tags Environment=PROD Purpose="Multi Region CodePipeline Prerequisites"

printf "\nChecking CloudFormation Stack status in $SECONDARY_REGION\n"

aws cloudformation wait stack-create-complete --region $SECONDARY_REGION --stack-name MULTI-REGION-PIPELINE-PREREQ

printf "\nCloudFormation Stack in $SECONDARY_REGION now CREATED\n"
