#!/usr/bin/env bash

# https://developer.hashicorp.com/terraform/internals/debugging
export TF_LOG="ERROR"

SECONDS=0
NUMBER_OF_PARALLEL_VM_ACTIONS=5

terraform init
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "Terraform init failed , exit_code=${EXIT_CODE} - exiting now"
  exit $EXIT_CODE
fi

duration=$SECONDS
echo "Terraform init took: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
