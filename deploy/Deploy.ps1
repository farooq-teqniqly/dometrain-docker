param(
    [Parameter(Mandatory=$true)]
    [string]$location,

    [Parameter(Mandatory=$true)]
    [string]$tenantId,

    [Parameter(Mandatory=$true)]
    [string]$subscriptionId
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

$uniquePrefix = Get-UniquePrefix(6)

Write-Host "Your unique prefix for the Azure resource group and resources is " -NoNewline
Write-Host $uniquePrefix -ForegroundColor Cyan

#az login --scope https://management.core.windows.net//.default
# az config set core.login_experience_v2=off
# az login --tenant $tenantId
# az account set --subscription $subscriptionId

$templateFileName = [IO.Path]::Combine($PSScriptRoot, "Main.bicep")

Write-Host "Starting deployment..."

$deploymentName = "dometrain-$uniquePrefix-deployment-$(Get-Random)"
$resourceGroupName = "dometrain-$uniquePrefix-rg"

$output = az deployment group create `
    --resource-group $resourceGroupName `
    --name $deploymentName `
    --template-file $templateFileName `
    --parameters uniquePrefix="dometrain-$uniquePrefix" `
| ConvertFrom-Json

if (!$output) {
    Write-Warning "Deployment failed. Resourse group will be deleted in the background."
    az group delete --name $resourceGroupName --yes --no-wait
    exit 1
}