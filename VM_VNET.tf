provider "azurerm" {
       #provider "hashicorp/azurerm" {
    subscription_id     = "98ac6fc7-ec7c-46a9-9887-80aebcf51748"
    client_id           = "a5aa8b87-088a-422f-8c2a-f33eaf0c5825"
    client_secret       = "iD58Q~xn5OHbvf3FMzX4pTOZRsaoUSCWyGZ_ycSC"
    tenant_id           = "2f0b93a1-027d-4ff3-8c5e-b0eade655f77"
    features {}
  
}

#-----------------------------
terraform {
  backend "azurerm" {
    storage_account_name = "terraformstgfile"
    container_name       = "terraformstgcont"
    key                  = "prod.terraform.tfstate"

    # rather than defining this inline, the Access Key can also be sourced
    # from an Environment Variable - more information is available below.
    access_key = "4TthhpZoFlsEnrj5VCK3ttsCQwT23yxF+1KApvgQ7w7ZbHA8CAB6GG2WxLQVfkzplHaPw+Ac9dTJ+AStc8bThw=="
  }
}


#-------------------------------




# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "Test_myResourceGroup_RG"
    location = "eastus"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs -V1
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}


# Create public IPs --V2
resource "azurerm_public_ip" "myterraformpublicip02" {
    name                         = "myPublicIP02"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        # access                     = "Allow"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Create network interface --NIC01
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC01"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration01"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }


    tags = {
        environment = "Terraform Demo"
    }
}
# --------------------------NIC02

# Create network interface
resource "azurerm_network_interface" "myterraformnic02" {
    name                      = "myNIC02"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration02"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip02.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}




# Connect the security group to the network interface -V1
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    #  network_interface_id      = azurerm_network_interface.myterraformnic02.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}


# Connect the security group to the network interface -V2
resource "azurerm_network_interface_security_group_association" "example02" {
    # network_interface_id      = azurerm_network_interface.myterraformnic.id
     network_interface_id      = azurerm_network_interface.myterraformnic02.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}



# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics --1
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "stgbootdig"
    # name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}
# -----------------------------------------------




# ---------------------
# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.example_ssh.private_key_pem 
    sensitive = true
}
#********************************************************************************************
# Create virtual machine -V1
resource "azurerm_linux_virtual_machine" "myterraformvm01" {
    name                  = "myVM01"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    # size                  = "Standard_DS1_v2"
    size                  = "Standard_B1s"
    os_disk {
        name              = "myOsDiskv1"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm01"
    admin_username = "msradmin"
          admin_password                  = "yogiCosmos12#"
    disable_password_authentication = false
   # disable_password_authentication = true
#    admin_ssh_key {
#         username   = "msradmin"
#         public_key = file("~/.ssh/id_rsa.pub")
           
#     }
    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo V01"
    }
}

# Create virtual machine -V2
resource "azurerm_linux_virtual_machine" "myterraformvm02" {
    name                  = "myVM02"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic02.id]
    # size                  = "Standard_DS1_v2"
    size                  = "Standard_B1s"
    os_disk {
        name              = "myOsDiskv2"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm02"
    admin_username = "msradmin"
        admin_password                  = "yogiCosmos12#"
    disable_password_authentication = false
   # disable_password_authentication = true

    # # admin_ssh_key {
    # #     username       = "msradmin"
    #     #public_key     = file("~/.ssh/id_rsa.pub")
        
        
    # }
}

#  *******************************************************************************

# ######################################################
# ######################################################
# #Create user account with login password  -V1
# resource "azurerm_linux_virtual_machine" "myterraformvm02" {
#     name                  = "myVM02"
#     location              = "eastus"
#     resource_group_name   = azurerm_resource_group.myterraformgroup.name
#     network_interface_ids = [azurerm_network_interface.myterraformnic02.id]
#     # size                  = "Standard_DS1_v2"
#     size                  = "Standard_B1s"
#     admin_username                  = "msradmin"
#     admin_password                  = "yogiCosmos12#"
#     disable_password_authentication = false
	
#     os_disk {
#         name              = "myOsDiskv2"
#         caching           = "ReadWrite"
#         storage_account_type = "Standard_LRS"
#     }

#     source_image_reference {
#         publisher = "Canonical"
#         offer     = "UbuntuServer"
#         sku       = "18.04-LTS"
#         version   = "latest"
#     }

# #Create user account with login password  -V2
# resource "azurerm_linux_virtual_machine" "myterraformvm01" {
#     name                  = "myVM01"
#     location              = "eastus"
#     resource_group_name   = azurerm_resource_group.myterraformgroup.name
#     network_interface_ids = [azurerm_network_interface.myterraformnic01.id]
#     # size                  = "Standard_DS1_v2"
#     size                  = "Standard_B1s"
#     admin_username                  = "msradmin"
#     admin_password                  = "yogiCosmos12#"
#     disable_password_authentication = false
	
#     os_disk {
#         name              = "myOsDiskv1"
#         caching           = "ReadWrite"
#         storage_account_type = "Standard_LRS"
#     }

#     source_image_reference {
#         publisher = "Canonical"
#         offer     = "UbuntuServer"
#         sku       = "18.04-LTS"
#         version   = "latest"
#     }


# ######################################################
# ######################################################



# # ----------------------------------------
# # os_profile{
# #     computer_name  = "myvm"
# #    admin_username = "msradmin"
# # }

# # os_profile_linux_config{
#     disable_password_authentication = true
#     ssh_keys {
#         path    =   "/home/msradmin/.ssh/authorized_keys"
#         key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCMnzomjbQaU5ECPa2pvFSTVuUH09TH6ogW5Xp//GQPSRN5b30iUtQqQ9qKRmTFlOaCSQcFWGNlfpaIR1B7jbvcsnz6wvUVcsVRJyLodDnFzNu3jRpftxUw7gMmCHvQgX/BNdPU2dh5HIvJhRcqAgkGNAeBpG4tkPhKvjp40t3I4V2nY+ea1WypX2lWUEe74iJy0I93/3XoIw8fl5X5Sxyvx6yvVf+RS+FyRpCMOQmdpZTJYQ5ziGfedP+BSKmsU+hvdKXnlqIkkq/lZihy05zhccFrbv1YOJ0r4Jbw9qlc6oUPrmqenXoG+lEJ0UX9nuKqTbx6CEkdyORhbBZDVF/z"
#     }
# # }

    # boot_diagnostics {
    #     storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    # }

#     tags = {
#         environment = "Terraform Demo V2"
#     }
 #}