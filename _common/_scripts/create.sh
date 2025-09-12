#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "No argument supplied, NUMBER_OF_PARALLEL_VM_ACTIONS=5"
    NUMBER_OF_PARALLEL_VM_ACTIONS=5
else
    echo "Argument supplied, NUMBER_OF_PARALLEL_VM_ACTIONS=$1"
    NUMBER_OF_PARALLEL_VM_ACTIONS=$1
fi

date_start="$(date +"%d-%m-%Y")"
time_start="$(date +"%T")"

export TF_LOG="ERROR" # https://developer.hashicorp.com/terraform/internals/debugging
SECONDS=0

terraform apply -parallelism=${NUMBER_OF_PARALLEL_VM_ACTIONS}
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "Terraform apply failed , exit_code=${EXIT_CODE} - exiting now"
  exit $EXIT_CODE
fi

date_stop="$(date +"%d-%m-%Y")"
time_stop="$(date +"%T")"
duration=$SECONDS
echo "Started at: ${date_start} ${time_start}"
echo "Ended at: ${date_stop} ${time_stop}"
echo "Terraform apply took: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
