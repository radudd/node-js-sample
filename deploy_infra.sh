#!/bin/bash
if [[ x"$DOKKU_HOST" == "x" ]]; then
  # Install Terraform
  curl -sSL https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip -o terraform.zip
  sudo unzip terraform.zip -d /usr/bin/
  rm terraform.zip
  
  # Apply Terraform deployment
  cd terraform
  terraform init || exit 99
  terraform plan || exit 99
  terraform apply -auto-approve || exit 99
  
  # Commit changes
  echo -e "[Git]: Configuring git user.name..." && echo "git config user.name $GIT_USERNAME" | tee /dev/stderr | bash
  echo -e "[Git]: Setting remote repository..." && echo "git remote add base $GIT_REPO" | tee /dev/stderr | bash
  echo -e "[Git]: Checking out master" && echo "git checkout master" | tee /dev/stderr | bash
  echo -e "[Git]: Add to staging..." && echo "git add ." | tee /dev/stderr | bash
  echo -e "[Git]: Commiting changes ..." && echo "git commit -am \"`date +%Y%m%d-%H%M`: Terraforming [ci skip]\"" | tee /dev/stderr | bash
  echo -e "[Git]: Pushing to remote repo..." && echo "git push base master" | tee /dev/stderr | bash
fi
