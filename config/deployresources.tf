provider "azurerm" {
 version = "=2.21.0"
features {}
}

variable "loc" {
    type = string
}

variable "name" {
  type = string
  default = "kubernetes"
}

variable "admin_username" {
  type = string
  default = "kubeadmin"
}

variable "admin_password" {
  type = string
  default = "kubeadmin@123"
}

resource "azurerm_resource_group" "rg" {
    name = var.name
    location= var.loc
}

resource "azurerm_virtual_network" "vnet" {
      name= "${var.name}-vnet"
      address_space = ["10.240.0.0/24"]
      location=var.loc
      resource_group_name = azurerm_resource_group.rg.name
  }

resource "azurerm_subnet" "subnet" {
  name                 = "${var.name}-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.240.0.0/24"]

}

resource "azurerm_public_ip" "pip" {
  name                = "${var.name}-pip"
  location            = var.loc
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "standard"
}

resource "azurerm_lb" "lb" {
  name                = "${var.name}-lb"
  location            = var.loc
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "standard"

  frontend_ip_configuration {
    name                 = "${var.name}-pip"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb-pool" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "${var.name}-lb-pool"
}

resource "azurerm_availability_set" "controller" {
  name                = "master-as"
  location            = var.loc
  resource_group_name = azurerm_resource_group.rg.name
  platform_fault_domain_count = 2
}

resource "azurerm_availability_set" "worker" {
  name                = "worker-as"
  location            = var.loc
  resource_group_name = azurerm_resource_group.rg.name
  platform_fault_domain_count = 2
}

resource "azurerm_public_ip" "controller" {
  count               = 2
  name                = "master-${count.index+1}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  location            = var.loc
  sku                 = "standard"
}

resource "azurerm_public_ip" "worker" {
  count               = 2
  name                = "worker-${count.index+1}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  location            = var.loc
  sku                 = "standard"
}

resource "azurerm_network_interface" "controller-nic" {
  count               = 2
  name                = "master-${count.index+1}-nic"
  location            = var.loc
  resource_group_name = azurerm_resource_group.rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "master-${count.index+1}-nic"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.240.0.1${count.index+1}"
    public_ip_address_id          = azurerm_public_ip.controller[count.index].id
    
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "controller-nic-backend" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.controller-nic[count.index].id
  ip_configuration_name   = "master-${count.index+1}-nic"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-pool.id
} 

resource "azurerm_network_interface" "worker-nic" {
  count               = 2
  name                = "worker-${count.index+1}-nic"
  location            = var.loc
  resource_group_name = azurerm_resource_group.rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "worker-${count.index+1}-nic"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.240.0.2${count.index+1}"
    public_ip_address_id          = azurerm_public_ip.worker[count.index].id
    
  }
}


resource "azurerm_network_interface_backend_address_pool_association" "worker-nic-backend" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.worker-nic[count.index].id
  ip_configuration_name   = "worker-${count.index+1}-nic"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-pool.id
}

resource "azurerm_linux_virtual_machine" "controller-vm" {
  count = 2
  name = "master-${count.index+1}"
  location = var.loc
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.controller-nic[count.index].id,
  ]
  availability_set_id = azurerm_availability_set.controller.id
  size = "Standard_DS1_v2"

   os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  
  source_image_reference {
    publisher = "redhat"
    offer     = "RHEL"
    sku       = "7.8" 
    version   = "latest"
  }
 
  computer_name  = "master-${count.index+1}"
  admin_username = var.admin_username
  admin_password = var.admin_password
  disable_password_authentication = false

}

resource "azurerm_linux_virtual_machine" "worker-vm" {
  count = 2
  name = "worker-${count.index+1}"
  location = var.loc
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.worker-nic[count.index].id,
  ]
  availability_set_id = azurerm_availability_set.worker.id
  size = "Standard_DS1_v2"

   os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  
  source_image_reference {
    publisher = "redhat"
    offer     = "RHEL"
    sku       = "7.8" 
    version   = "latest"
  }
 
  computer_name  = "worker-${count.index+1}"
  admin_username = var.admin_username
  admin_password = var.admin_password
  disable_password_authentication = false

}
