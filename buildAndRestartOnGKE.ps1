# Change to directory of the powershell script itself
Set-Location $PSScriptRoot

# Delete the current deployment from GKE
kubectl.exe delete -f .\kube_deploy.yaml

# Build the app
#sencha app build

# Build and push the Docker container
docker.exe build -q -t kurts/hcm_portal .
docker.exe login -ukurts -pXS7Z8pEy
docker.exe push kurts/hcm_portal:latest

# Re-create the deployment on GKE
kubectl.exe apply -f .\kube_deploy.yaml