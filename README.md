<!-- BEGIN_TF_DOCS -->
# OpenTofu Module: PostgreSQL Management

This OpenTofu module provides comprehensive PostgreSQL database and user management, specifically designed for setting up Guacamole database infrastructure with proper role-based permissions and security.

## Features

- Creates dedicated PostgreSQL roles for Guacamole application and Flyway database migrations
- Sets up a dedicated Guacamole database with proper ownership and configuration
- Implements least-privilege access patterns with role-based permissions
- Configures default privileges for future database objects
- Supports secure SSL connections with configurable authentication

## Resources Created

### PostgreSQL Roles
- **`guacamole`** - Application role for Guacamole with read/write data access
- **`flyway_guacamole`** - Migration role for Flyway with schema management permissions

### Database
- **`guacamole_db`** - Dedicated database for Guacamole application
  - Owner: `guacamole` role
  - Template: `template0` (clean template)
  - Encoding: `UTF8`
  - Collation: `C`
  - Character type: `C`
  - Unlimited connections

### Permissions
- Database connection privileges for both roles
- Schema creation and usage permissions for Flyway role
- Default privileges for future tables and sequences
- Read/write permissions for Guacamole role on Flyway-created objects

## Usage

```hcl
module "postgres_management" {
  source = "./opentofu-module-postgres-management"

  host               = "your-postgres-host.example.com"
  db_username        = "postgres"
  db_password        = var.postgres_admin_password
  guacamole_password = var.guacamole_user_password
  flyway_password    = var.flyway_user_password
}
```

## Variables

| Name | Type | Description | Required |
|------|------|-------------|----------|
| `host` | `string` | PostgreSQL server hostname or IP address | Yes |
| `db_username` | `string` | PostgreSQL admin username for provider authentication | Yes |
| `db_password` | `string` | PostgreSQL admin password (sensitive) | Yes |
| `guacamole_password` | `string` | Password for the Guacamole application user (sensitive) | Yes |
| `flyway_password` | `string` | Password for the Flyway migration user (sensitive) | Yes |

## Provider Configuration

The module uses the `cyrilgdn/postgresql` provider with the following configuration:
- Port: `5432`
- Database: `postgres` (for initial connection)
- SSL Mode: `require`
- Connection timeout: `15` seconds
- Superuser: `false` (uses regular user permissions)

## Security Considerations

1. **Password Management**: All passwords are marked as sensitive variables
2. **SSL Required**: Connections require SSL encryption
3. **Least Privilege**: Roles are granted minimal necessary permissions
4. **Role Separation**: Migration and application roles are separated for better security
5. **Future Permissions**: Default privileges ensure proper access to objects created by migrations

## Permission Model

The module implements a secure permission model:

1. **Flyway Role**: Can create and manage schema objects in the `public` schema
2. **Guacamole Role**: Can perform CRUD operations on tables created by Flyway
3. **Default Privileges**: Automatically grant appropriate permissions to future objects

## Requirements

- OpenTofu/Terraform
- PostgreSQL provider `cyrilgdn/postgresql` ~> 1.25.0
- PostgreSQL server with admin access
- SSL-enabled PostgreSQL connection

## Example

```hcl
# Example usage in a root module
terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.25.0"
    }
  }
}

module "guacamole_postgres" {
  source = "./modules/postgres-management"

  host               = "postgres.internal.example.com"
  db_username        = "postgres"
  db_password        = var.postgres_admin_password
  guacamole_password = random_password.guacamole.result
  flyway_password    = random_password.flyway.result
}

resource "random_password" "guacamole" {
  length  = 32
  special = true
}

resource "random_password" "flyway" {
  length  = 32
  special = true
}
```

## Notes

- The module connects to the default `postgres` database for administrative operations
- All created resources depend on proper role and database creation order
- The `guacamole_db` database is configured for optimal Guacamole performance
- Default privileges ensure that objects created by Flyway migrations are automatically accessible to the Guacamole application role

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | ~> 1.25.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | n/a | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | n/a | `string` | n/a | yes |
| <a name="input_flyway_password"></a> [flyway\_password](#input\_flyway\_password) | n/a | `string` | n/a | yes |
| <a name="input_guacamole_password"></a> [guacamole\_password](#input\_guacamole\_password) | n/a | `string` | n/a | yes |
| <a name="input_host"></a> [host](#input\_host) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->