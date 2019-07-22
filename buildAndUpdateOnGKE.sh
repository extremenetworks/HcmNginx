#!/bin/bash
set -e

# Change to directory of the powershell script itself
BASEDIR=$(dirname "$BASH_SOURCE")
cd $BASEDIR

NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'

# Extract the last build version from the file build.version 
# Extract only the last digits (after the second dot character)
#minorBuildVersion=$(cut -d. -f3 build.version)
minorBuildVersion=$(grep -P -o '\d+$' build.version)

echo "$(date +%T.%3N) ${GREEN}Old minor build version: $minorBuildVersion${NC}"

# Increase version by 1
minorBuildVersion="$(($minorBuildVersion+1))"

# Extract the major build version
majorBuildVersion=$(grep -P -o '^\d+\.\d+\.' build.version)

# Concat existing major with new minor version
version="$majorBuildVersion$minorBuildVersion"

echo -e "$(date +%T.%3N) ${GREEN}Building new container image with version $version${NC}"

# Build and push the Docker container
docker build -q -t kurts/hcm_nginx:$version .
docker push kurts/hcm_nginx:$version

# Store the new build version in the file
echo $version > build.version

# Update the container to the newest image on the deployment on GKE
# deployment name, then container name and finally new image with version tag
echo -e "$(date +%T.%3N) Updating GKE container image to version ${GREEN}$version${NC}"
kubectl set image deployment/hcm-nginx hcm-nginx=kurts/hcm_nginx:$version

# Wait for 30 seconds so GKE can deploy the new container using the new image
echo -e "$(date +%T.%3N) ${GREEN}Sleeping for 30 seconds before attaching to container logs${NC}"
sleep 30

# Attach to the new container's log output
kubectl logs -f $(kubectl get pod -l app=hcm-nginx -o jsonpath="{.items[0].metadata.name}") -c hcm-nginx

