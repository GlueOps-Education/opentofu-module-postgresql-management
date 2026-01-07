provider "postgresql" {
  host            = var.host
  port            = 5432
  database        = "postgres"
  username        = var.db_username
  password        = var.db_password
  superuser       = false
  sslmode         = "require"
  connect_timeout = 15
}
