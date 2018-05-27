#!/bin/bash
# Apply Terraform configuration
cd terraform
terraform plan
terraform apply -auto-approve

# Commit changes
echo "Git: Configuring git user.name..." && git config user.name "$GIT_USERNAME"
echo "Git: Setting remote repository..." && git remote add base "$GIT_REPO"
echo "Git: Checking out master" && git checkout master
echo "Git: Commiting changes to terraform state..." && git commit -am "`date +%Y%m%d-%H%MAdded`: Terraforming by Travis CI"
echo "Git: Pushing to remote repo..." && git push base master
