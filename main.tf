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
    resource_group_name   = "rg-terrastate"
    storage_account_name  = "terrastatestorage032022"
    container_name        = "terrademo"
    key                   = "dev.terraform.tfstate"
  }
}

#provider config block
provider "azurerm" {
  features {}
}

# create resource group
resource "azurerm_resource_group" "rg" {
    name = "rg-${var.application}"
    location = var.location
    tags = {
      "env" = "terradev"
    }
}

# create virtual network
resource "azurerm_virtual_network" "vnet" {
    name = "vnet-${var.application}-${azurerm_resource_group.rg.location}-001"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space = var.vnet_address_space

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
  name                = "snet-${var.application}-${azurerm_resource_group.rg.location}-001"
  address_prefixes    = var.snet_address_space
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

# create network interface
resource "azurerm_network_interface" "nic" {
    name                = "nic-${var.application}-001"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
      name                          = "niccfg-${var.application}-ip"
      subnet_id                     = azurerm_subnet.subnet.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id          = azurerm_public_ip.pip.id
    }  
}

resource "azurerm_public_ip" "pip" {
  name = "pip-${var.application}-001"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  allocation_method = "Dynamic"

  tags = {
    env = "Development"
  }  
}

# create virtual machine 
resource "azurerm_windows_virtual_machine" "vm" {
    name = "${var.application}-vm"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    size = var.vm_size
    admin_username = var.admin_username
    admin_password = var.admin_password

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

output "pip" {
  description     = "Public IP address"
  value           = azurerm_public_ip.pip.ip_address
}