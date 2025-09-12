#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "No argument supplied, NUMBER_OF_PARALLEL_VM_ACTIONS=5"
    NUMBER_OF_PARALLEL_VM_ACTIONS=5
else
    echo "Argument supplied, NUMBER_OF_PARALLEL_VM_ACTIONS=$1"
    NUMBER_OF_PARALLEL_VM_ACTIONS=$1
fi

export TF_LOG="ERROR" # https://developer.hashicorp.com/terraform/internals/debugging
SECONDS=0

while true; do
  read -p "Do you want to continue with the removal of the VMs? (Y/N) " yn
  case $yn in
  [Yy]*)  # Execute ansible playbooks at destroy
          terraform destroy --auto-approve -parallelism=$NUMBER_OF_PARALLEL_VM_ACTIONS
          EXIT_CODE=$?
          if [ $EXIT_CODE -ne 0 ]; then
            echo "Terraform destroy failed, exit_code=${EXIT_CODE} - exiting now"
            exit $EXIT_CODE
          fi
          rm terraform.tfstate*
          break ;;
  [Nn]*)  clear
          exit ;;
  *) echo "Please answer yes or no." ;;
  esac
done

duration=$SECONDS
echo "Terraform destroy took: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
