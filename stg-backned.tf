# terraform {
#   backend "azurerm" {
#     storage_account_name = "terraformstgfile"
#     container_name       = "terraformstgcont"
#     key                  = "prod.terraform.tfstate"

#     # rather than defining this inline, the Access Key can also be sourced
#     # from an Environment Variable - more information is available below.
#     access_key = "4TthhpZoFlsEnrj5VCK3ttsCQwT23yxF+1KApvgQ7w7ZbHA8CAB6GG2WxLQVfkzplHaPw+Ac9dTJ+AStc8bThw=="
#   }
# }
