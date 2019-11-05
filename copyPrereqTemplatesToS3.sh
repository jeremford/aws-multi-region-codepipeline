#!/bin/sh

PRIMARY_REGION=ap-southeast-2
SECONDARY_REGION=us-east-1

PROD_APPROVAL_EMAIL=your@email.here

mkdir -p build
zip -j build/prereq-templates.zip templates/prereq/*

printf "\nLooking up Prerequisites Pipeline Bucket in $PRIMARY_REGION\n"

#Lookup Prerequisites S3 Bucket in Primary Region
PrimaryPrereqS3Bucket=$(aws cloudformation describe-stacks --region ${PRIMARY_REGION} --stack-name MULTI-REGION-PIPELINE-PREREQ | jq -r '.Stacks[0].Outputs[0].OutputValue' )

printf "\nFound Bucket: $PrimaryPrereqS3Bucket\n"
printf "\Uploading to Bucket: $PrimaryPrereqS3Bucket\n"
aws s3 cp build/prereq-templates.zip s3://$PrimaryPrereqS3Bucket/prereq-templates.zip

printf "\nLooking up Prerequisites Pipeline Bucket in $SECONDARY_REGION\n"

#Lookup Prerequisites S3 Bucket in Secondary Region
SecondaryPrereqS3Bucket=$(aws cloudformation describe-stacks --region ${SECONDARY_REGION} --stack-name MULTI-REGION-PIPELINE-PREREQ | jq -r '.Stacks[0].Outputs[0].OutputValue' )

printf "\nFound Bucket: $SecondaryPrereqS3Bucket\n"
printf "\Uploading to Bucket: $SecondaryPrereqS3Bucket\n"
aws s3 cp build/prereq-templates.zip s3://$SecondaryPrereqS3Bucket/prereq-templates.zip
