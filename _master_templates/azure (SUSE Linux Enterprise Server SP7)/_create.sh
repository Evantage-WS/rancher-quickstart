#!/usr/bin/env bash

echo
echo "###############################################################################################################################"
echo "########## Sometimes the ssh to the Rancher node will fail (bug Azure?), just destroy the resources and do it again! ##########"
echo "###############################################################################################################################"
echo
echo "###############################################################################################################################"
echo "########## DO NOT CHANGE THE KUBECONFIG TO ANY CLUSTER IN ANY CONSOLE, IT WILL FAIL TO INSTALL SUSE SECURITY!        ##########"
echo "###############################################################################################################################"
echo
echo "###############################################################################################################################"
echo "########## GETTING ERRORS WITH AZ-CLI, https://github.com/Azure/azure-cli/issues/28829#issuecomment-2578841909       ##########"
echo "##########                                          AT YOUR OWN RISK                                                 ##########"
echo "########## - brew install ruff                                                                                       ##########"
echo "########## - cd /opt/homebrew/Cellar/azure-cli/2.69.0/libexec/lib/python3.12/site-packages                           ##########"
echo "########## - ruff check --fix --select W605                                                                          ##########"
echo "###############################################################################################################################"
echo

source "../../../_common/_scripts/create.sh"
