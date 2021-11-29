variable "application" {
    type            = string
    description     = "Name of Application"
}

variable "location" {
    type            = string
    description     = "location of network infrastructures"
    default         = "uksouth"
}

variable "admin_username" {
    type        = string
    description = "local user admin"
}

variable "admin_password" {
    type            = string
    description     = "local password"
    sensitive       = true  
}

variable "vnet_address_space" {
    type            = list(any)
    description     = "Virtual Network Address Space"
    default         = [ "10.0.0.0/16" ]  
}

variable "snet_address_space" {
    type            = list(any)
    description     = "Subnet Address Space"
    default         = [ "10.0.1.0/24" ]
}

variable "storage_account_type" {
    type            = map
    description     = "Disk type as per location"
    default         = {
        uksouth     = "Premium_LRS"
        ukwest      = "Standard_LRS "
    }
}

variable "vm_size" {
    type        = string
    description = "The size of VM"
}
variable "os" {
    description     = "OS image to deploy"
    type            = object({
        publisher   = string
        offer       = string
        sku         = string
        version     = string
    })   
}