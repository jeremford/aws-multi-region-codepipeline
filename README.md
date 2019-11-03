# Multi Region Code Pipeline

Aim:
* Primary and at least one Secondary region
* Demonstrate cross-region S3 bucket replication
* Nested Stacks
* Aurora Global Database
* All deployments through CodePipeline


## Prerequisites

1. CodePipline in each region to deploy Prerequisites
  * CodePipeline Artifact Buckets in each region
  * Future enhancement to allow cross-account deployments


## Main CodePipeline

1. Source: S3
2. Build: Extract
3. Build: Verify and upload child stacks to S3
4. Non-Prod Deploy: deploy to single region
5. Prod Deploy:
  * Deploy any Prerequisites in Secondary Regions
  * Deploy Master stack in Primary Region
  * Deploy Master stack in Secondary Regions

    
