# Environment variable containing the GCP Access File
# Example: /home/<user>/.config/gcloud/application_default_credentials.json
# You need to use the gloud executable
export TF_VAR_ENV_GCP_ACCESS_FILE="<file location>"

# Environment variable containing the GCP Login Name
export TF_VAR_ENV_GCP_LOGIN_NAME="<loginname>"

# Environment variable containing the GCP Project
export TF_VAR_ENV_GCP_PROJECT="<projectname>"

# Environment variable containing the GCP Region
# Example: europe-west4
export TF_VAR_ENV_GCP_REGION="<region>"

# Environment variable containing the GCP Zone
# Example: a
export TF_VAR_ENV_GCP_ZONE="<zone>"

# Environment variable containing the password for Rancher
export TF_VAR_ENV_RANCHER_SEVER_ADMIN_PASSWORD="<admin password for SUSE Rancher>"

# Environment variable containing the password for SUSE Security
export TF_VAR_ENV_SUSE_SECURITY_ADMIN_PASSWORD="<admin password for SUSE Security>"

# Environment variable containing the file location of the public key for ssh access
export TF_VAR_ENV_SSH_PUBLIC_KEY_FILE="<location of the public key>"

# Environment variable containing the file location of the private key for ssh access
export TF_VAR_ENV_SSH_PRIVATE_KEY_FILE="<location of the private key file>"
