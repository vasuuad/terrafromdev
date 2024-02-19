
# # Create public IPs --V2
# resource "azurerm_public_ip" "myterraformpublicip03" {
#     name                         = "myPublicIP03"
#     location                     = "eastus"
#     resource_group_name          = azurerm_resource_group.myterraformgroup.name
#     allocation_method            = "Dynamic"

#     tags = {
#         environment = "Terraform Demo"
#     }
# }


# # Create network interface
# resource "azurerm_network_interface" "myterraformnic03" {
#     name                      = "myNIC03"
#     location                  = "eastus"
#     resource_group_name       = azurerm_resource_group.myterraformgroup.name

#     ip_configuration {
#         name                          = "myNicConfiguration03"
#         subnet_id                     = azurerm_subnet.myterraformsubnet.id
#         private_ip_address_allocation = "Dynamic"
#         public_ip_address_id          = azurerm_public_ip.myterraformpublicip03.id
#     }

#     tags = {
#         environment = "Terraform Demo"
#     }
# }



# # Connect the security group to the network interface -V2
# resource "azurerm_network_interface_security_group_association" "example03" {
   
#      network_interface_id      = azurerm_network_interface.myterraformnic03.id
#     network_security_group_id = azurerm_network_security_group.myterraformnsg.id
# }


# # Create virtual machine -V3
# resource "azurerm_linux_virtual_machine" "myterraformvm03" {
#     name                  = "myVM03"
#     location              = "eastus"
#     resource_group_name   = azurerm_resource_group.myterraformgroup.name
#     network_interface_ids = [azurerm_network_interface.myterraformnic03.id]
#     # size                  = "Standard_DS1_v2"
#     size                  = "Standard_B1s"
#     os_disk {
#         name              = "myOsDiskv3"
#         caching           = "ReadWrite"
#         storage_account_type = "Standard_LRS"
#     }

#     source_image_reference {
#         publisher = "Canonical"
#         offer     = "UbuntuServer"
#         sku       = "18.04-LTS"
#         version   = "latest"
#     }

#     computer_name  = "myvm03"
#     admin_username = "msradmin"
#     disable_password_authentication = true

#     admin_ssh_key {
#         username       = "msradmin"
#         public_key     = file("~/.ssh/id_rsa.pub")
        
#     }

#     boot_diagnostics {
#         storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
#     }

#     tags = {
#         environment = "Terraform Demo V3"
#     }
# }




# Create storage account for boot diagnostics --2
resource "azurerm_storage_account" "mystorageaccount01" {
    name                        = "stgbootdig01"
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