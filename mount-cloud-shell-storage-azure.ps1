# taken from 	https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-windows
######### mount it baby...
$resourceGroupName = "cloud-shell-storage-westeurope"
$storageAccountName = "csb73826b2e8117x4405x8b9"
$fileShareName = "cs-reinhard-scerus-com-1003200086315af2"

# These commands require you to be logged into your Azure account, run Login-AzAccount if you haven't
# already logged in.
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
$storageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName
$fileShare = Get-AzStorageShare -Context $storageAccount.Context | Where-Object { 
    $_.Name -eq $fileShareName -and $_.IsSnapshot -eq $false
}

if ($fileShare -eq $null) {
    throw [System.Exception]::new("Azure file share not found")
}

# The value given to the root parameter of the New-PSDrive cmdlet is the host address for the storage account, 
# <storage-account>.file.core.windows.net for Azure Public Regions. $fileShare.StorageUri.PrimaryUri.Host is 
# used because non-Public Azure regions, such as sovereign clouds or Azure Stack deployments, will have different 
# hosts for Azure file shares (and other storage resources).
$password = ConvertTo-SecureString -String $storageAccountKeys[0].Value -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "AZURE\$($storageAccount.StorageAccountName)", $password
New-PSDrive -Name Z -PSProvider FileSystem -Root "\\$($fileShare.StorageUri.PrimaryUri.Host)\$($fileShare.Name)" -Credential $credential -Persist