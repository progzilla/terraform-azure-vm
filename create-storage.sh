#Create RG for storing State Files
az group create --location uksouth --name rg-terraformstate

#Create Storage Account
az storage account create --name terrastatestorage2022 --resource-group rg-terraformstate --location uksouth --sku Standard_LRS

#Create Storage Container
az storage container create --name terraformdemo --account-name terrastatestorage2022

#Enable versioning on Storage Account1
az storage account blob-service-properties update --resource-group rg-terraformstate --account-name terrastatestorage2022 --enable-change-feed --enable-versioning true