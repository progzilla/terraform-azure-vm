#Create RG for storing State Files
az group create --location uksouth --name rg-terrastate

#Create Storage Account
az storage account create --name terrastatestorage032022 --resource-group rg-terrastate --location uksouth --sku Standard_LRS

#Create Storage Container
az storage container create --name terrademo --account-name terrastatestorage032022

#Enable versioning on Storage Account1
az storage account blob-service-properties update --resource-group rg-terrastate --account-name terrastatestorage032022 --enable-change-feed --enable-versioning true