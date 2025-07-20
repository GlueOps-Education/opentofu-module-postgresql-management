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

resource "postgresql_role" "guacamole" {
  name     = "guacamole"
  login    = true
  password = var.guacamole_password
  roles    = ["pg_write_all_data"]
}

resource "postgresql_role" "flyway_guacamole" {
  name     = "flyway_guacamole"
  login    = true
  password = var.flyway_password
  roles    = ["pg_write_all_data"]
}

resource "postgresql_database" "guacamole_db" {
  name              = "guacamole_db"
  owner             = postgresql_role.guacamole.name
  template          = "template0"
  lc_collate        = "C"
  encoding          = "UTF8"
  lc_ctype          = "C"
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_grant" "flyway_connect" {
  database    = postgresql_database.guacamole_db.name
  role        = postgresql_role.flyway_guacamole.name
  object_type = "database"
  privileges  = ["CONNECT"]
  depends_on = [
    postgresql_database.guacamole_db,
    postgresql_role.flyway_guacamole
  ]
}

resource "postgresql_grant" "flyway_schema_permissions" {
  database    = postgresql_database.guacamole_db.name
  role        = postgresql_role.flyway_guacamole.name
  schema      = "public"
  object_type = "schema"
  privileges  = ["CREATE", "USAGE"]
  depends_on = [
    postgresql_database.guacamole_db,
    postgresql_role.flyway_guacamole
  ]
}

resource "postgresql_grant" "guacamole_connect" {
  database    = postgresql_database.guacamole_db.name
  role        = postgresql_role.guacamole.name
  object_type = "database"
  privileges  = ["CONNECT"]
  depends_on = [
    postgresql_database.guacamole_db,
    postgresql_role.guacamole
  ]
}

resource "postgresql_default_privileges" "guacamole_tables" {
  database = postgresql_database.guacamole_db.name

  # The user that CREATES the tables (the creator/owner of future objects)
  owner = postgresql_role.flyway_guacamole.name

  # The user that RECEIVES the permissions (the grantee)
  role = postgresql_role.guacamole.name

  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_default_privileges" "guacamole_sequences" {
  database = postgresql_database.guacamole_db.name

  # The user that CREATES the sequences
  owner = postgresql_role.flyway_guacamole.name

  # The user that RECEIVES the permissions
  role = postgresql_role.guacamole.name

  schema      = "public"
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT"]
}
