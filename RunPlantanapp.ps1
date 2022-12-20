<#

.PARAMETER Start
Starts the docker containers.
 
.PARAMETER Stop
Stops the docker containers.
 
.PARAMETER Reset
Removes the docker containers and the folders of the app, then starts again fresh. Use with caution!

.PARAMETER Update
Pulls the latest image and updates the docker containers. It does NOT delete any data.

.PARAMETER PinToTag
Pulls the image with the specified tag and updates the docker containers. It does NOT delete any data.
 
.PARAMETER Restart
Stops and starts the docker containers. It does NOT delete any data.
 
.PARAMETER PermanentlyRemove 
Removes the docker containers and the folders of the app. Use with caution!

.EXAMPLE
PS> .\RunPlantanapp.ps1 -Start 
.EXAMPLE
PS> .\RunPlantanapp.ps1 -Stop 
.EXAMPLE
PS> .\RunPlantanapp.ps1 -Reset 
.EXAMPLE
PS> .\RunPlantanapp.ps1 -PinToTag dev-1.23.2 
.EXAMPLE
PS> .\RunPlantanapp.ps1 -PermanentlyRemove
.SYNOPSIS
This script helps you start / stop / init / reset your app docker containers.
#> 
Param (
    [Parameter(Mandatory=$false)][switch]$Start = $false,
    [Parameter(Mandatory=$false)][switch]$Stop = $false,
    [Parameter(Mandatory=$false)][switch]$Reset = $false,
    [Parameter(Mandatory=$false)][switch]$Update = $false,
    [Parameter(Mandatory=$false)][string]$PinToTag,
    [Parameter(Mandatory=$false)][switch]$Restart = $false,
    [Parameter(Mandatory=$false)][switch]$PermanentlyRemove = $false
)

$ErrorActionPreference = 'Stop'

function EnsureDockerCompose() {
    if ($null -eq (Get-Command "docker-compose" -ErrorAction SilentlyContinue)) { 
        $url = "https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-windows-x86_64.exe";
        Write-Output "Unable to find docker-compose.exe in your PATH. Downloading docker-compose from [$url]"
        Invoke-WebRequest -UseBasicParsing -Outfile $Env:ProgramFiles\docker\docker-compose.exe $url
    }
}

function StartApp() {
    docker-compose up -d

    Write-Output "Your app container is running."
}

function StopApp() {
    docker-compose stop;
}

function PermanentlyRemoveApp() {
    docker-compose down;
}

function UpdateImage() {
    $env:MULTI_ENV_DOCKER_TAG="latest";
    echo "Updating multi env image to [$env:MULTI_ENV_DOCKER_TAG]";
    docker-compose pull;
}

function PinImageToTag() {
    $env:MULTI_ENV_DOCKER_TAG=$PinToTag;
    echo "Pin multi env image to [$env:MULTI_ENV_DOCKER_TAG]";
    docker-compose pull;
}

EnsureDockerCompose

if ($Start) {
    StartApp
}

if($Stop) {
    StopApp
}

if($PermanentlyRemove) {
    PermanentlyRemoveApp
}

if($Reset) {
    PermanentlyRemoveApp
    Start-Sleep 1
    StartApp
}

if($Update) {
    UpdateImage
    Start-Sleep 1
    StartApp
}

if($PinToTag) {
    PinImageToTag
    Start-Sleep 1
    StartApp
}

if($Restart) {
    StopApp
    Start-Sleep 1
    StartApp
}

if ((-not $Update) -and (-not $PinToTag) -and (-not $Restart) -and (-not $Reset) -and (-not $Start) -and (-not $Stop) -and (-not $PermanentlyRemove)) {
    Get-Help $PSCommandPath -Full
}