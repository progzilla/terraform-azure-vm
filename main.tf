# Terraform config block
terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "2.86.0"
    }
  } 
  # create azure remote state 
  backend "azurerm" {
    resource_group_name   = "rg-terraformstate"
    storage_account_name  = "terrastateazstorage2021"
    container_name        = "terraformdemo"
    key                   = "dev.terraform.tfstate"
  }
}

#provider config block
provider "azurerm" {
  features {}
}

# create resource group
resource "azurerm_resource_group" "rg" {
    name = "rg-terrademo"
    location = var.location
    tags = {
      "env" = "terradev"
    }
}

# create virtual network
resource "azurerm_virtual_network" "vnet" {
    name = "vnet-terranet-dev-001"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = [ "10.0.0.0/16" ]

    # subnet {
    #   name = "terrasubnet1"
    #   address_prefix = "10.0.1.0/24"
      
    # }
    # subnet {
    #     name= "terrasubnet2"
    #     address_prefix = "10.0.2.0/24"
    # } 
    tags = {
      "env" = "dev"
    }
}

# create subnet
resource "azurerm_subnet" "subnet" {
  name                = "terrasubnet"
  address_prefixes    = [ "10.0.1.0/24" ]
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

# create network interface
resource "azurerm_network_interface" "nic" {
    name                = "nic-01-terravm-dev-001"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
      name                          = "niccfg-vmterraform"
      subnet_id                     = azurerm_subnet.subnet.id
      private_ip_address_allocation = "Dynamic"
    }  
}

# create virtual machine 
resource "azurerm_windows_virtual_machine" "vm" {
    name = "terraform-vm"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    size = "Standard_B1s"
    admin_username = "terraadmin"
    admin_password = var.password

    network_interface_ids = [ 
        azurerm_network_interface.nic.id 
    ]

    # Operating System disk
    os_disk {
      caching               = "ReadWrite"
      storage_account_type  = lookup(var.storage_account_type, var.location, "Standard_LRS")
    }

    # Operatng system image
    source_image_reference {
      publisher = var.os.publisher
      offer     = var.os.offer
      sku       = var.os.sku
      version   = var.os.version
    }
}
# output resource group name
output "rg_name" {
  description = "resource group"
  value       = azurerm_resource_group.rg.name 
}

# output virtual network name
output "vnet_name" {
  description  = "virtual network"
  value           = azurerm_virtual_network.vnet.name   
}