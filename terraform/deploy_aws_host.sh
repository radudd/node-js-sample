#!/bin/bash
# Apply Terraform deployment
TF_DIR=`cd $(dirname $0); pwd`
cd $TF_DIR
terraform init || exit 99
terraform refresh || exit 99
terraform plan || exit 99
terraform apply -auto-approve || exit 99

## Commit changes
#echo "Git: Configuring git user.name..." && echo "git config user.name $GIT_USERNAME" | tee /dev/stderr | bash
#echo "Git: Setting remote repository..." && git remote add base "$GIT_REPO" | tee /dev/stderr | bash
#echo "Git: Checking out master" && git checkout master | tee /dev/stderr | bash
echo "Git: Commiting changes to terraform state..." && git commit -am "`date +%Y%m%d-%H%M`: Terraforming by Travis CI" | tee /dev/stderr | bash
echo "Git: Pushing to remote repo..." && git push origin master | tee /dev/stderr | bash
#echo "Git: Pushing to remote repo..." && git push base master | tee /dev/stderr | bash
