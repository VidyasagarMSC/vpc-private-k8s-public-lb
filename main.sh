#!/bin/bash
set -e

echo "#### Create a kubernetes cluster"
tfswitch
terraform init
terraform apply -auto-approve

echo "#### Create, build and deploy a starter web app"
./setup.sh