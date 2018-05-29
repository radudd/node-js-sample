#!/bin/bash
# Install Terraform
curl -sSL https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip -o terraform.zip
sudo unzip terraform.zip -d /usr/bin/
rm terraform.zip

# Apply Terraform deployment
TF_DIR=`cd $(dirname $0); pwd`
cd $TF_DIR
terraform init || exit 99
terraform plan || exit 99
terraform apply -auto-approve || exit 99

## Commit changes
#echo -e "[Git]: Configuring git user.name..." && echo "git config user.name $GIT_USERNAME" | tee /dev/stderr | bash
#echo -e "[Git]: Setting remote repository..." && echo "git remote add base $GIT_REPO" | tee /dev/stderr | bash
#echo -e "[Git]: Checking out master" && echo "git checkout master" | tee /dev/stderr | bash
#echo -e "[Git]: Add to staging..." && echo "git add ." | tee /dev/stderr | bash
#echo -e "[Git]: Commiting changes ..." && echo "git commit -am \"`date +%Y%m%d-%H%M`: Terraforming by Travis CI\"" | tee /dev/stderr | bash
#echo -e "[Git]: Pushing to remote repo..." && echo "git push base master" | tee /dev/stderr | bash

# Deploy App to Dokku
export DOKKU_HOST=`terraform output public_dns`
ssh-keyscan ${DOKKU_HOST} >> ~/.ssh/known_hosts
git remote add dokku dokku@${DOKKU_HOST}:${APP_NAME}
git fetch --unshallow
until ssh -q -o StrictHostKeyChecking=no ${DOKKU_HOST} -l dokku ssh-keys:list; do echo "[WARN] Dokku not ready ... please wait" && sleep 30; done; git push dokku master
echo http://${DOKKU_HOST}:${APP_PORT}
