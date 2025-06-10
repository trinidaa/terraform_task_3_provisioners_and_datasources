resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = data.azurerm_resource_group.example.location
  resource_group_name   = data.azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_D4ls_v6"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.hostname
    admin_username = var.username
    admin_password = var.password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }

  provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
    # on_failure  = continue
    connection {
      type     = "ssh"
      user     = var.username
      password = var.password
      timeout  = "111s"
      host     = azurerm_public_ip.profile.fqdn
    }
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.username
      password = var.password
      timeout  = "20s"
      host     = azurerm_public_ip.profile.fqdn
    }
    inline = [
      "echo '\\033[33;44mConnected to --->>\\033[0m' $(hostname)",
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      # 1. Проверяем существование исходного файла
      "if [ -f /tmp/index.html ]; then",

      # 2. Перемещаем с принудительной перезаписью (-f) и выводом статуса
      "sudo mv -fv /tmp/index.html /var/www/html/index.html &&",

      # 3. Устанавливаем правильные права
      "sudo chown www-data:www-data /var/www/html/index.html;",
      "sudo chmod 644 /var/www/html/index.html;",

      # 4. Проверяем конфигурацию Nginx перед перезагрузкой
      "sudo nginx -t && sudo systemctl restart nginx;",
      "echo '\\033[0;33mSource file deployed to Nginx!\\033[0m';",

      # 5. Завершаем условие
      "else",
        "echo '\\033[0;33mSource file not found\\033[0m';",
      "fi"
    ]
  }
}