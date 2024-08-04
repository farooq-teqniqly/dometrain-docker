param(
    [Parameter(Mandatory=$true)]
    [string]$location,

    [Parameter(Mandatory=$true)]
    [string]$resourceGroupForSshKey
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
$sshKeyName = "$uniquePrefix-ssh-key"

$sshKey = az sshkey create `
    --name $sshKeyName `
    --resource-group $resourceGroupForSshKey `
    --query publicKey `
    -o tsv

$output = az deployment sub create `
    --location $location `
    --name $deploymentName `
    --template-file $templateFileName `
    --parameters uniquePrefix="$uniquePrefix" sshKey="$sshKey" `
| ConvertFrom-Json

if (!$output) {
    Write-Warning "Deployment failed. Resourse group will be deleted in the background."
    az group delete --name $resourceGroupName --yes --no-wait
    exit 1
}

az deployment sub show --name $deploymentName --query properties.outputs --output json

$deployment = az deployment sub show --name $deploymentName --query properties.outputs --output json
$deploymentJson = $deployment | ConvertFrom-Json

$aksClusterName = $deploymentJson.deploymentOutputs.value.aksDeployment.clusterName

Write-Host "Adding node pool to the AKS cluster..." -ForegroundColor Cyan

az aks nodepool add `
    -g $resourceGroupName `
    -n appnodepool `
    --cluster-name $aksClusterName `
    --os-sku Ubuntu

$acrName = $deploymentJson.deploymentOutputs.value.acrDeployment.name

Write-Host "Azure Container Registry credentials" -ForegroundColor Cyan

az acr credential show --name $acrName --resource-group $resourceGroupName

Write-Host "Deployment completed successfully." -ForegroundColor Green