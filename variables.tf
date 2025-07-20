variable "host" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "guacamole_password" {
  type      = string
  sensitive = true
}

variable "flyway_password" {
  type      = string
  sensitive = true
}
