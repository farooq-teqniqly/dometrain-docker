param(
    [Parameter(Mandatory=$true)]
    [string]$location
)


function Get-UniquePrefix([int]$length) {
    $alphabet = "abcdefghijklmnopqrstuvwxyz"
    $uniquePrefix = ""

    for ($i = 0; $i -lt $length; $i++) {
        $random = Get-Random -Minimum 0 -Maximum ($alphabet.Length - 1)
        $randomLetter = $alphabet[$random]
        $uniquePrefix += $randomLetter
    }

    return $uniquePrefix
}

Write-Host "Starting deployment..." -ForegroundColor Cyan

$uniquePrefix = Get-UniquePrefix(6)
$uniquePrefix = "dometrain-" + $uniquePrefix

$templateFileName = [IO.Path]::Combine($PSScriptRoot, "Main.bicep")
$deploymentName = "$uniquePrefix-deployment"
$resourceGroupName = "$uniquePrefix-rg"

$output = az deployment sub create `
    --location $location `
    --name $deploymentName `
    --template-file $templateFileName `
    --parameters uniquePrefix="$uniquePrefix" `
| ConvertFrom-Json

if (!$output) {
    Write-Warning "Deployment failed. Resourse group will be deleted in the background."
    az group delete --name $resourceGroupName --yes --no-wait
    exit 1
}

az deployment sub show --name $deploymentName --query properties.outputs --output json

$deployment = az deployment sub show --name $deploymentName --query properties.outputs --output json
$deploymentJson = $deployment | ConvertFrom-Json

$acrName = $deploymentJson.deploymentOutputs.value.acrDeployment.name

Write-Host "Azure Container Registry credentials" -ForegroundColor Cyan

az acr credential show --name $acrName --resource-group $resourceGroupName

Write-Host "Deployment completed successfully." -ForegroundColor Green