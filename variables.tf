variable "prefix" {
  type    = string
  default = "task3"
}

variable "subscription_id" {
  type      = string
  default   = "9c2e0e5d-9337-4855-af79-231071eb6983"
  sensitive = true
}

variable "username" {
  type      = string
  default   = "testadmin"
  sensitive = true
}

variable "password" {
  type      = string
  default   = "Password1234!"
  sensitive = true
}

variable "ssh_public_key" {
  type      = string
  default   = "~/.ssh/id_rsa.pub"
  sensitive = true
}

variable "hostname" {
  type    = string
  default = "NG-host"
}

