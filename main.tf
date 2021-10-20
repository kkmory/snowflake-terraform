terraform {
  required_providers {
    snowflake = {
      source  = "chanzuckerberg/snowflake"
      version = "0.25.22"
    }
  }
}

provider "snowflake" {
  alias = "sys_admin"
  role  = "SYSADMIN"
}

provider "snowflake" {
  alias = "security_admin"
  role  = "SECURITYADMIN"
}

# Required
# name (String)
# 
# Optional
# comment (String)
# data_retention_time_in_days (Number)
# from_database (String) Specify a database to create a clone from.
# from_share (Map of String) Specify a provider and a share in this map to create a database from a share.
# id (String) The ID of this resource.
resource "snowflake_database" "db" {
  provider = snowflake.sys_admin
  name     = "TF_DEMO"
}

# Required
# name (String) Identifier for the virtual warehouse; must be unique for your account.

# Optional
# auto_resume (Boolean) Specifies whether to automatically resume a warehouse when a SQL statement (e.g. query) is submitted to it.
# auto_suspend (Number) Specifies the number of seconds of inactivity after which a warehouse is automatically suspended.
# comment (String)
# id (String) The ID of this resource.
# initially_suspended (Boolean) Specifies whether the warehouse is created initially in the ‘Suspended’ state.
# max_cluster_count (Number) Specifies the maximum number of server clusters for the warehouse.
# max_concurrency_level (Number) Object parameter that specifies the concurrency level for SQL statements (i.e. queries and DML) executed by a warehouse.
# min_cluster_count (Number) Specifies the minimum number of server clusters for the warehouse (only applies to multi-cluster warehouses).
# resource_monitor (String) Specifies the name of a resource monitor that is explicitly assigned to the warehouse.
# scaling_policy (String) Specifies the policy for automatically starting and shutting down clusters in a multi-cluster warehouse running in Auto-scale mode.
# statement_queued_timeout_in_seconds (Number) Object parameter that specifies the time, in seconds, a SQL statement (query, DDL, DML, etc.) can be queued on a warehouse before it is canceled by the system.
# statement_timeout_in_seconds (Number) Specifies the time, in seconds, after which a running SQL statement (query, DDL, DML, etc.) is canceled by the system
# wait_for_provisioning (Boolean) Specifies whether the warehouse, after being resized, waits for all the servers to provision before executing any queued or new queries.
# warehouse_size (String) Specifies the size of the virtual warehouse. Larger warehouse sizes 5X-Large and 6X-Large are currently in preview and only available on Amazon Web Services (AWS).
resource "snowflake_warehouse" "warehouse" {
  provider       = snowflake.sys_admin
  name           = "TF_DEMO"
  warehouse_size = "xsmall"
  auto_suspend   = 60
}

# Required
# name (String)
#
# Optional
# id (String) The ID of this resource.
# comment (String)
resource "snowflake_role" "role" {
  provider = snowflake.security_admin
  name     = "TF_DEMO_SVC_ROLE"
}

# Required
# database_name (String) The name of the database on which to grant privileges.
#
# Optional
# id (String) The ID of this resource.
# privilege (String) The privilege to grant on the database.
# roles (Set of String) Grants privilege to these roles.
# shares (Set of String) Grants privilege to these shares.
# with_grant_option (Boolean) When this is set to true, allows the recipient role to grant the privileges to other roles.
resource "snowflake_database_grant" "grant" {
  provider          = snowflake.security_admin
  database_name     = snowflake_database.db.name
  privilege         = "USAGE"
  roles             = [snowflake_role.role.name]
  with_grant_option = false
}

# Required
# database (String) The database in which to create the schema.
# name (String) Specifies the identifier for the schema; must be unique for the database in which the schema is created.
# 
# Optional
# comment (String) Specifies a comment for the schema.
# data_retention_days (Number) Specifies the number of days for which Time Travel actions (CLONE and UNDROP) can be performed on the schema, as well as specifying the default Time Travel retention time for all tables created in the schema.
# id (String) The ID of this resource.
# is_managed (Boolean) Specifies a managed schema. Managed access schemas centralize privilege management with the schema owner.
# is_transient (Boolean) Specifies a schema as transient. Transient schemas do not have a Fail-safe period so they do not incur additional storage costs once they leave Time Travel; however, this means they are also not protected by Fail-safe in the event of a data loss.
resource "snowflake_schema" "schema" {
  provider   = snowflake.sys_admin
  database   = snowflake_database.db.name
  name       = "TF_DEMO"
  is_managed = false
}

# Required
# database_name (String) The name of the database containing the schema on which to grant privileges.
# 
# Optional
# id (String) The ID of this resource.
# on_future (Boolean) When this is set to true, apply this grant on all future schemas in the given database. The schema_name and shares fields must be unset in order to use on_future.
# privilege (String) The privilege to grant on the current or future schema. Note that if "OWNERSHIP" is specified, ensure that the role that terraform is using is granted access.
# roles (Set of String) Grants privilege to these roles.
# schema_name (String) The name of the schema on which to grant privileges.
# shares (Set of String) Grants privilege to these shares (only valid if on_future is unset).
# with_grant_option (Boolean) When this is set to true, allows the recipient role to grant the privileges to other roles.
resource "snowflake_schema_grant" "grant" {
  provider          = snowflake.security_admin
  database_name     = snowflake_database.db.name
  schema_name       = snowflake_schema.schema.name
  privilege         = "USAGE"
  roles             = [snowflake_role.role.name]
  with_grant_option = false
}

# Required
# warehouse_name (String) The name of the warehouse on which to grant privileges.
#
# Optional
# id (String) The ID of this resource.
# privilege (String) The privilege to grant on the warehouse.
# roles (Set of String) Grants privilege to these roles.
# with_grant_option (Boolean) When this is set to true, allows the recipient role to grant the privileges to other roles.
resource "snowflake_warehouse_grant" "grant" {
  provider          = snowflake.security_admin
  warehouse_name    = snowflake_warehouse.warehouse.name
  privilege         = "USAGE"
  roles             = [snowflake_role.role.name]
  with_grant_option = false
}

resource "tls_private_key" "svc_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Required
# name (String) Name of the user. Note that if you do not supply login_name this will be used as login_name. doc
# https://docs.snowflake.net/manuals/sql-reference/sql/create-user.html#required-parameters
# 
# Optional
# comment (String)
# default_namespace (String) Specifies the namespace (database only or database and schema) that is active by default for the user’s session upon login.
# default_role (String) Specifies the role that is active by default for the user’s session upon login.
# default_warehouse (String) Specifies the virtual warehouse that is active by default for the user’s session upon login.
# disabled (Boolean)
# display_name (String) Name displayed for the user in the Snowflake web interface.
# email (String) Email address for the user.
# first_name (String) First name of the user.
# id (String) The ID of this resource.
# last_name (String) Last name of the user.
# login_name (String) The name users use to log in. If not supplied, snowflake will use name instead.
# must_change_password (Boolean) Specifies whether the user is forced to change their password on next login (including their first/initial login) into the system.
# password (String, Sensitive) WARNING: this will put the password in the terraform state file. Use carefully.
# rsa_public_key (String) Specifies the user’s RSA public key; used for key-pair authentication. Must be on 1 line without header and trailer.
# rsa_public_key_2 (String) Specifies the user’s second RSA public key; used to rotate the public and private keys for key-pair authentication based on an expiration schedule set by your organization. Must be on 1 line without header and trailer.
# 
# Read-Only
# has_rsa_public_key (Boolean) Will be true if user as an RSA key set.
resource "snowflake_user" "user" {
  provider          = snowflake.security_admin
  name              = "tf_demo_user"
  default_warehouse = snowflake_warehouse.warehouse.name
  default_role      = snowflake_role.role.name
  default_namespace = "${snowflake_database.db.name}.${snowflake_schema.schema.name}"
  rsa_public_key    = substr(tls_private_key.svc_key.public_key_pem, 27, 398)
}

# Required
# role_name (String) The name of the role we are granting.
#
# Optional
# id (String) The ID of this resource.
# roles (Set of String) Grants role to this specified role.
# users (Set of String) Grants role to this specified user.
resource "snowflake_role_grants" "grants" {
  provider  = snowflake.security_admin
  role_name = snowflake_role.role.name
  users     = [snowflake_user.user.name]
}
