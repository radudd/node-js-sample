#!/bin/bash
# Deploy App to Dokku
export DOKKU_HOST=`terraform output public_dns`
ssh-keyscan ${DOKKU_HOST} >> ~/.ssh/known_hosts
git remote add dokku dokku@${DOKKU_HOST}:${APP_NAME}
git fetch --unshallow
until ssh -q -o StrictHostKeyChecking=no ${DOKKU_HOST} -l dokku ssh-keys:list; do echo "[WARN] Dokku not ready ... please wait" && sleep 30; done; git push dokku master
echo http://${DOKKU_HOST}:${APP_PORT}
