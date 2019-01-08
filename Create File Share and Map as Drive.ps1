## Connect to your Azure account in PowerShell
Connect-AzAccount

## Set the variables below to the names, sizes, locations, etc that you want to use
$ResourceGroupName = "EnterResourceGroupName"
$StorageAccountName = "EnterStorageAccountName"
$FileShareName = "EnterFileShareName"
$FileShareSizeMB = 1024
$Location = "UK West"
$SkuName = "Standard_LRS"
$StorageType = "StorageV2"
$DriveLetter = "L"

## All of the remaining commands in this script should now just run, with no input needed from yourself

## Create a new Resource Group
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

## Create a new Storage Account
New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Location -SkuName $SkuName -Kind $StorageType

## Obtain Account Key for new Storage Account
$AccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName).Value[0]

## Set context to new Storage Account
$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $AccountKey

## Create new File Share within the Storage Account
New-AzStorageShare -Name $FileShareName -Context $Context

## Resize the newly created File Share
Set-AzStorageShareQuota -ShareName $FileShareName -Context $Context -Quota $FileShareSizeMB

## Get Credential name for new Storage Account
$CredentialName = "Azure\"+$StorageAccountName

## Create a Credential consisting of the Credential name and account key
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $CredentialName, (ConvertTo-SecureString -String $AccountKey -AsPlainText -Force)

## Set root for new File Share
$Root = "\\"+$StorageAccountName+".file.core.windows.net\"+$FileShareName

## Create a new Drive that will be mapped to the Azure File Share
New-PSDrive -Name $DriveLetter -PSProvider FileSystem -Root $Root -Credential $Credential -Persist