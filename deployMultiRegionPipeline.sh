#!/bin/sh

PRIMARY_REGION=ap-southeast-2
SECONDARY_REGION=us-east-1

PROD_APPROVAL_EMAIL=your@email.here

printf "\nDeploying Multi Region Pipeline in $PRIMARY_REGION\n"

#Lookup Prerequisites S3 Bucket in Primary Region
PrimaryPrereqS3Bucket=$(aws cloudformation describe-stacks --region ${PRIMARY_REGION} --stack-name MULTI-REGION-PIPELINE-PREREQ | jq -r '.Stacks[0].Outputs[0].OutputValue' )

#Lookup Prerequisites S3 Bucket in Secondary Region
SecondaryPrereqS3Bucket=$(aws cloudformation describe-stacks --region ${SECONDARY_REGION} --stack-name MULTI-REGION-PIPELINE-PREREQ | jq -r '.Stacks[0].Outputs[0].OutputValue' )

#Deploy main multi region pipeline in Primary Region
aws cloudformation deploy \
  --region $PRIMARY_REGION \
  --template-file pipelines/multi-region-pipeline.yml \
  --stack-name MULTI-REGION-PIPELINE \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides PrimaryRegion=$PRIMARY_REGION SecondaryRegion=$SECONDARY_REGION PrimaryRegionS3ArtifactBucket=$PrimaryPrereqS3Bucket SecondaryRegionS3ArtifactBucket=$SecondaryPrereqS3Bucket SourceS3Key=multi-region-templates.zip PRODApprovalEmail=$PROD_APPROVAL_EMAIL \
  --tags Environment=PROD Purpose="Multi Region CodePipeline"
