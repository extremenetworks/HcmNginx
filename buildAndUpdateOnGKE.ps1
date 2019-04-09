# Change to directory of the powershell script itself
Set-Location $PSScriptRoot

# Extract the last build version from the file build.version 
# Extract only the last digits (after the second dot character)
$minorBuildVersion = Select-String -Path .\build.version -Pattern '\d+$' | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

# Conver it to an integer and increase version by 1
$minorBuildVersion = $minorBuildVersion -as [int]
$minorBuildVersion++

# Extract the major build version
$majorBuildVersion = Select-String -Path .\build.version -Pattern '^\d+\.\d+\.' | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

# Concat existing major with new minor version
$version = $majorBuildVersion + $minorBuildVersion
Write-Host "Building new container image with version $version" -ForegroundColor Green

# Build and push the Docker container
docker.exe build -q -t kurts/hcm_portal:$version .
docker.exe login -ukurts -pXS7Z8pEy
docker.exe push kurts/hcm_portal:$version

# Store the new build version in the file
$version | Out-File -FilePath build.version

# Update the container to the newest image on the deployment on GKE
# deployment name, then container name and finally new image with version tag
$output = kubectl.exe set image deployment/hcm-portal hcm-portal=kurts/hcm_portal:$version
if ($LastExitCode -ne 0) {
    Write-Host "Error: kubectl setting new image on deployment for $version : $output" -ForegroundColor Red
    return
}

# Wait for 15 seconds so GKE can deploy the new container using the new image
Start-Sleep 15

# Attach to the new container's log output
kubectl.exe logs -f $(kubectl.exe get pod -l app=hcm-portal -o jsonpath="{.items[0].metadata.name}") -c hcm-portal

