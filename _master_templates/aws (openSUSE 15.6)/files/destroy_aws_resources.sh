#!/usr/bin/env bash

# See https://awscli.amazonaws.com/v2/documentation/api/latest/index.html

if [ $# -lt 2 ]; then
    echo "No tag and/or value supplied"
    exit 1
fi

FILTER="Name=tag:${1},Values=${2}"

echo "Collecting AWS resources information..."

VPC_IDS=$(aws ec2 describe-vpcs \
            --filters "${FILTER}" \
            --query Vpcs[].VpcId \
            --region ${TF_VAR_env_aws_region} \
            --output text)

INSTANCE_IDS=$(aws ec2 describe-instances \
                --filters "${FILTER}" Name=instance-state-name,Values=running\
                --query Reservations[].Instances[].InstanceId \
                --region ${TF_VAR_env_aws_region} \
                --output text)

SECURITY_GROUP_IDS=$(aws ec2 describe-security-groups \
                      --filters "${FILTER}" \
                      --query "SecurityGroups[*].{ID:GroupId}" \
                      --region ${TF_VAR_env_aws_region} \
                      --output text)

INTERNET_GATEWAY_IDS=$(aws ec2 describe-internet-gateways \
                        --filters "${FILTER}" \
                        --query "InternetGateways[*].{ID:InternetGatewayId}" \
                        --region ${TF_VAR_env_aws_region} \
                        --output text)

ROUTE_TABLE_IDS=$(aws ec2 describe-route-tables \
                    --filters "${FILTER}" \
                    --query "RouteTables[*].{ID:RouteTableId}" \
                    --region ${TF_VAR_env_aws_region} \
                    --output text)

ROUTE_TABLE_ASSOCIATION_IDS=$(aws ec2 describe-route-tables \
                                --filters "${FILTER}" \
                                --query "RouteTables[*].Associations[*].{ID:RouteTableAssociationId}" \
                                --region ${TF_VAR_env_aws_region} \
                                --output text)

SUBNET_IDS=$(aws ec2 describe-subnets \
                --filters "${FILTER}" \
                --query "Subnets[*].{ID:SubnetId}" \
                --region ${TF_VAR_env_aws_region} \
                --output text)

# DHCP_OPTIONS_IDS=$(aws ec2 describe-dhcp-options \
#                 --filters "${FILTER}" \
#                 --query "DhcpOptions[*].[DhcpOptionsId]" \
#                 --output text)

KEY_PAIR_IDS=$(aws ec2 describe-key-pairs \
                --filters "${FILTER}" \
                --query "KeyPairs[*].{ID:KeyPairId}" \
                --region ${TF_VAR_env_aws_region} \
                --output text)

echo "VPC_IDS=${VPC_IDS}"
echo "INSTANCE_IDS=${INSTANCE_IDS}"
echo "SECURITY_GROUP_IDS=${SECURITY_GROUP_IDS}"
echo "INTERNET_GATEWAY_IDS=${INTERNET_GATEWAY_IDS}"
echo "ROUTE_TABLE_IDS=${ROUTE_TABLE_IDS}"
echo "ROUTE_TABLE_ASSOCIATION_IDS=${ROUTE_TABLE_ASSOCIATION_IDS}"
echo "SUBNET_IDS=${SUBNET_IDS}"
# echo "DHCP_OPTIONS_IDS=${DHCP_OPTIONS_IDS}"
echo "KEY_PAIR_IDS=${KEY_PAIR_IDS}"
echo

while true; do
  read -p "Are you sure you want to perform this operation? (Y/N) " yn
  case $yn in
  [Yy]*)  break ;;
  [Nn]*)  clear
          echo "Destroy aborted......"
          exit 1;;
  *) echo "Please answer yes or no." ;;
  esac
done

if [ ! -z "$INSTANCE_IDS" ]; then
  echo "Terminating the instances (VMs)"
  aws ec2 terminate-instances --instance-ids ${INSTANCE_IDS} --region ${TF_VAR_env_aws_region} 2>&1 >/dev/null
  EXIT_CODE=$?
  if [ $EXIT_CODE -ne 0 ]; then
    echo "Error with 'aws ec2 terminate-instances --instance-ids ${INSTANCE_IDS} --region ${TF_VAR_env_aws_region}', exit_code=${EXIT_CODE} - stopping aws destroy resources"
    exit $EXIT_CODE
  fi
fi

if [ ! -z "$INSTANCE_IDS" ]; then
  echo "Waiting for termination of the instances (VMs), could take some time"
  aws ec2 wait instance-terminated --instance-ids ${INSTANCE_IDS} --region ${TF_VAR_env_aws_region} 2>&1 >/dev/null
  EXIT_CODE=$?
  if [ $EXIT_CODE -ne 0 ]; then
    echo "Error with 'aws ec2 wait instance-terminated --instance-ids ${INSTANCE_ID} --region ${TF_VAR_env_aws_region}', exit_code=${EXIT_CODE} - stopping aws destroy resources"
    exit $EXIT_CODE
  fi
fi

if [ ! -z "$SECURITY_GROUP_IDS" ]; then
  echo "Removing the security group(s)"
  for SECURITY_GROUP_ID in ${SECURITY_GROUP_IDS}; do
    aws ec2 delete-security-group --group-id ${SECURITY_GROUP_ID} --region ${TF_VAR_env_aws_region} 2>&1 >/dev/null
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
      echo "Error with 'aws ec2 delete-security-group --group-id ${SECURITY_GROUP_ID} --region ${TF_VAR_env_aws_region}', exit_code=${EXIT_CODE} - stopping aws destroy resources"
      exit $EXIT_CODE
    fi
  done
fi

if [ ! -z "$ROUTE_TABLE_ASSOCIATION_IDS" ]; then
  echo "Disassociating the route table(s)"
  for ROUTE_TABLE_ASSOCIATION_ID in ${ROUTE_TABLE_ASSOCIATION_IDS}; do
    aws ec2 disassociate-route-table --association-id ${ROUTE_TABLE_ASSOCIATION_ID} --region ${TF_VAR_env_aws_region} 2>&1 >/dev/null
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
      echo "Error with 'aws ec2 disassociate-route-table --association-id ${ROUTE_TABLE_ASSOCIATION_ID} --region ${TF_VAR_env_aws_region}', exit_code=${EXIT_CODE} - stopping aws destroy resources"
      exit $EXIT_CODE
    fi
  done
fi

if [ ! -z "$ROUTE_TABLE_IDS" ]; then
  echo "Deleting the route table(s)"
  for ROUTE_TABLE_ID in ${ROUTE_TABLE_IDS}; do
    aws ec2 delete-route-table --route-table-id ${ROUTE_TABLE_ID} --region ${TF_VAR_env_aws_region} 2>&1 >/dev/null
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
      echo "Error with 'aws ec2 delete-route-table --route-table-id ${ROUTE_TABLE_ID} --region ${TF_VAR_env_aws_region}', exit_code=${EXIT_CODE} - stopping aws destroy resources"
      exit $EXIT_CODE
    fi
  done
fi

if [ ! -z "$SUBNET_IDS" ]; then
  echo "Deleting the subnet(s)"
  for SUBNET_ID in ${SUBNET_IDS}; do
    aws ec2 delete-subnet --subnet-id ${SUBNET_ID} --region ${TF_VAR_env_aws_region} 2>&1 >/dev/null
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
      echo "Error with 'aws ec2 delete-subnet --subnet-id ${SUBNET_ID} --region ${TF_VAR_env_aws_region}', exit_code=${EXIT_CODE} - stopping aws destroy resources"
      exit $EXIT_CODE
    fi
  done
fi

if [ ! -z "$INTERNET_GATEWAY_IDS" ]; then
  echo "Detaching the internet gateway(s)"
  for INTERNET_GATEWAY_ID in ${INTERNET_GATEWAY_IDS}; do
    aws ec2 detach-internet-gateway --internet-gateway-id ${INTERNET_GATEWAY_ID} --vpc-id ${VPC_IDS} --region ${TF_VAR_env_aws_region} 2>&1 >/dev/null
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
      echo "Error with 'aws ec2 detach-internet-gateway --internet-gateway-id ${INTERNET_GATEWAY_ID} --vpc-id ${VPC_IDS} --region ${TF_VAR_env_aws_region}', exit_code=${EXIT_CODE} - stopping aws destroy resources"
      exit $EXIT_CODE
    fi
  done
fi

if [ ! -z "$INTERNET_GATEWAY_IDS" ]; then
  echo "Deleting the internet gateway(s)"
  for INTERNET_GATEWAY_ID in ${INTERNET_GATEWAY_IDS}; do
    aws ec2 delete-internet-gateway --internet-gateway-id ${INTERNET_GATEWAY_ID} --region ${TF_VAR_env_aws_region} 2>&1 >/dev/null
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
      echo "Error with 'aws ec2 delete-internet-gateway --internet-gateway-id ${INTERNET_GATEWAY_ID} --region ${TF_VAR_env_aws_region}', exit_code=${EXIT_CODE} - stopping aws destroy resources"
      exit $EXIT_CODE
    fi
  done
fi

if [ ! -z "$VPC_IDS" ]; then
  echo "Deleting the vpc"
  for VPC_ID in ${VPC_IDS}; do
    aws ec2 delete-vpc --vpc-id ${VPC_ID} --region ${TF_VAR_env_aws_region} 2>&1 >/dev/null
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
      echo "Error with 'aws ec2 delete-vpc --vpc-id ${VPC_ID} --region ${TF_VAR_env_aws_region}', exit_code=${EXIT_CODE} - stopping aws destroy resources"
      exit $EXIT_CODE
    fi
  done
fi

# if [ ! -z "$DHCP_OPTIONS_IDS" ]; then
#   echo "Deleting the dhcp options"
#   aws ec2 delete-dhcp-options --dhcp-options-id ${DHCP_OPTIONS_IDS} 2>&1 >/dev/null
#   EXIT_CODE=$?
#   if [ $EXIT_CODE -ne 0 ]; then
#     echo "Error with 'aws ec2 delete-dhcp-options --dhcp-options-id ${DHCP_OPTIONS_IDS}', exit_code=${EXIT_CODE} - stopping aws destroy resources"
#     exit $EXIT_CODE
#   fi
# fi

if [ ! -z "$KEY_PAIR_IDS" ]; then
  echo "Deleting the key-pair"
  for KEY_PAIR_ID in ${KEY_PAIR_IDS}; do
    aws ec2 delete-key-pair --key-pair-id ${KEY_PAIR_ID} --region ${TF_VAR_env_aws_region} 2>&1 >/dev/null
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
      echo "Error with 'aws ec2 delete-key-pair --key-pair-id ${KEY_PAIR_ID} --region ${TF_VAR_env_aws_region}', exit_code=${EXIT_CODE} - stopping aws destroy resources"
      exit $EXIT_CODE
    fi
  done
fi
