# Rancher Quickstart

The original 'rancher quickstart' (https://github.com/rancher/quickstart) was not working (for me) anymore. I updated the code and started with Microsoft Azure, Amazon AWS and Google Cloud.

## Description

This code will install 2 K3s clusters on SUSE Linux Enterprise Linux. A cluster, managed by a Rancher Management Server, is called a downstream cluster

The first cluster will contain Rancher Management Server and SUSE Security, the second cluster will only containe the K3s distribution, as an example of a managed (downstream) cluster in the Rancher Management Server

What I changed:
- Updated the providers to the latest versions
- Use your own SSH keypair, instead of creating a new one every time
- Save the kubeconfig to a location of choice
- Save ssh link and rancher url to the __k8s directory
- All credential information used will be read from shell environment variables
- A destroy script will be generated which will delete all created resources, this script will be generated at runtime. Please be aware to always check if all resources are deleted.

## Getting Started

**You will be responsible for any and all infrastructure costs incurred by these resources.**

### Dependencies

* Install Terraform or Opentofu (it is tested with Terraform)
* Access to a Cloud provider
* Generate a SSH keypair, see https://www.ssh.com/academy/ssh/keygen

### Installing

* Clone this repository
* Create the needed environment variables with the credentials (see the scripts starting with  env-*.sh) and execute it
* For GCP, you do need to login prior to executing via `gcloud`
* Make a copy of one of the directories in `_master_template` to a directory in the `_datacenter` directory. I strongly suggest to do this and not edit the content of the `_master_templates` directory
* Edit the values in `config.yaml` in the newly created directory

### Creating the resources

Run the initializer for Terraform or Opentofu:
```
./_init_terraform.sh
```

Create the resources for the Rancher Management Server and downstream cluster:
```
./_create.sh
```

The directory `__k8s` contains the details for accessing the nodes via `ssh` and contains the `rancher` url.

### Destroying all resources (uninstalling)

Destroy all resources created for the Rancher Management Server and downstream cluster
```
./_destroy.sh
```

## Authors

Contributors names and contact info

WS

## Version History

* 0.1
    * Initial Release

## License

This project is licensed under the 'Apache License Version 2.0' License - see the LICENSE file for details.

## Acknowledgments

Inspiration, code snippets, etc.
* [DomPizzie Readme](https://gist.github.com/DomPizzie/7a5ff55ffa9081f2de27c315f5018afc)
* [Rancher Quickstart](https://github.com/rancher/quickstart)
