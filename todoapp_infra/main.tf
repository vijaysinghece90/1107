module "resource_group" {
  source                  = "../modules/azurerm_resource_group"
  resource_group_name     = "rg-todoapp"
  resource_group_location = "centralindia"
}

module "virtual_network" {
  depends_on = [module.resource_group]
  source     = "../modules/azurerm_virtual_network"

  virtual_network_name     = "vnet-todoapp"
  virtual_network_location = "centralindia"
  resource_group_name      = "rg-todoapp"
  address_space            = ["10.0.0.0/16"]
}

# Dard1 - Backend subnet and frontend subnet do baar repeat ho raha hai...
module "frontend_subnet" {
  depends_on = [module.virtual_network]
  source     = "../modules/azurerm_subnet"

  resource_group_name  = "rg-todoapp"
  virtual_network_name = "vnet-todoapp"
  subnet_name          = "frontend-subnet"
  address_prefixes     = ["10.0.1.0/24"]
}

module "backend_subnet" {
  depends_on = [module.virtual_network]
  source     = "../modules/azurerm_subnet"

  resource_group_name  = "rg-todoapp"
  virtual_network_name = "vnet-todoapp"
  subnet_name          = "backend-subnet"
  address_prefixes     = ["10.0.2.0/24"]
}

module "public_ip_frontend" {
  source              = "../modules/azurerm_public_ip"
  public_ip_name      = "pip-todoapp-frontend"
  resource_group_name = "rg-todoapp"
  location            = "centralindia"
  allocation_method   = "Static"
}

#HomeWork - Ye upr wala public IP ko frontend VM ke sath attach karna hai

# Dard 2 - Do baar module bulana pad raha hai..  do vm ke lie...
module "frontend_vm" {
  depends_on = [module.frontend_subnet]
  source     = "../modules/azurerm_virtual_machine"

  resource_group_name  = "rg-todoapp"
  location             = "centralindia"
  vm_name              = "vm-frontend"
  vm_size              = "Standard_B1s"
  admin_username       = "devopsadmin"
  admin_password       = "P@ssw0rd1234!"
  image_publisher      = "Canonical"
  image_offer          = "0001-com-ubuntu-server-focal"
  image_sku            = "20_04-lts"
  image_version        = "latest"
  nic_name             = "nic-vm-frontend"
  virtual_network_name = "vnet-todoapp"
  subnet_name          = "frontend-subnet"
  pip_name             = "pip-todoapp-frontend"
}

module "public_ip_backend" {
  source              = "../modules/azurerm_public_ip"
  public_ip_name      = "pip-todoapp-backend"
  resource_group_name = "rg-todoapp"
  location            = "centralindia"
  allocation_method   = "Static"
}

module "backend_vm" {
  depends_on = [module.backend_subnet]
  source     = "../modules/azurerm_virtual_machine"

  resource_group_name  = "rg-todoapp"
  location             = "centralindia"
  vm_name              = "vm-backend"
  vm_size              = "Standard_B1s"
  admin_username       = "devopsadmin"
  admin_password       = "P@ssw0rd1234!"
  image_publisher      = "Canonical"
  image_offer          = "0001-com-ubuntu-server-focal"
  image_sku            = "20_04-lts"
  image_version        = "latest"
  nic_name             = "nic-vm-backend"
  virtual_network_name = "vnet-todoapp"
  subnet_name          = "backend-subnet"
  pip_name             = "pip-todoapp-backend"
}

module "sql_server" {
  source              = "../modules/azurerm_sql_server"
  sql_server_name     = "todosqlserver008"
  resource_group_name = "rg-todoapp"
  location            = "centralindia"
  # secret ko rakhne ka sudhar - Azure Key Vault
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd1234!"
}

module "sql_database" {
  depends_on = [module.sql_server]
  source     = "../modules/azurerm_sql_database"

  sql_database_name = "tododb"
  # server ka id fir hardcode... ye toh bada hi taklif bhara hai..
  sql_server_id = "/subscriptions/1075ec7a-b17a-4f37-bf3f-9d68c4506dc1/resourceGroups/rg-todoapp/providers/Microsoft.Sql/servers/todosqlserver008"
}
