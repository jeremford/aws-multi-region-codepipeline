#!/usr/bin/env bash

for TEMPLATE in $(find . -type f \( -iname "*.yml" ! -iname "buildspec.yml" \)); do
    echo -n "Validating CloudFormation template ${TEMPLATE}..."
    aws cloudformation validate-template --region ap-southeast-2 --template-body "file://${TEMPLATE}" 1>/dev/null
    if [[ $? -gt 0 ]]; then
        exit 1
    fi
    echo " OK"
done
