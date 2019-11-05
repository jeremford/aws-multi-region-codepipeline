#!/bin/sh

PRIMARY_REGION=ap-southeast-2
SECONDARY_REGION=us-east-1

PROD_APPROVAL_EMAIL=your@email.here

mkdir -p build
zip -j build/multi-region-templates.zip templates/multiregion/*

printf "\nLooking up Multi Region Pipeline Bucket in $PRIMARY_REGION\n"

#Lookup Prerequisites S3 Bucket in Primary Region
PrimaryRegionPipelineS3Bucket=$(aws cloudformation describe-stacks --region ${PRIMARY_REGION} --stack-name MULTI-REGION-PIPELINE | jq -r '.Stacks[0].Outputs[0].OutputValue' )

printf "\nFound Bucket: $PrimaryRegionPipelineS3Bucket\n"
printf "\Uploading to Bucket: $PrimaryRegionPipelineS3Bucket\n"
aws s3 cp build/multi-region-templates.zip s3://$PrimaryRegionPipelineS3Bucket/multi-region-templates.zip
