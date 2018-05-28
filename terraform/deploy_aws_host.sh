#!/bin/bash
# Apply Terraform deployment
TF_DIR=`cd $(dirname $0); pwd`
cd $TF_DIR
terraform init || exit 99
terraform plan || exit 99
terraform apply -auto-approve || exit 99

## Commit changes
echo "Git: Configuring git user.name..." && echo -e "git config user.name $GIT_USERNAME" | tee /dev/stderr | bash
echo "Git: Setting remote repository..." && echo -e "git remote add base $GIT_REPO" | tee /dev/stderr | bash
echo "Git: Checking out master" && echo -e "git checkout master" | tee /dev/stderr | bash
echo "Git: Add to staging..." && echo "git add ." | tee /dev/stderr | bash
echo "Git: Commiting changes ..." && echo "git commit -am \"`date +%Y%m%d-%H%M`: Terraforming by Travis CI\"" | tee /dev/stderr | bash
echo "Git: Pushing to remote repo..." && echo "git push base master" | tee /dev/stderr | bash
