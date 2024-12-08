### Advanced Usage

* [Available tags](#available-tags)
* [Configure users](#configure-users)
* [Server configuration directives overrides](#server-configuration-directives-overrides)
   * [Server configuration directives overrides order](#server-configuration-directives-overrides-order)
   * [Sensitive data in server configuration directives overrides](#sensitive-data-in-server-configuration-directives-overrides)
   * [Custom HTTP handlers](#custom-http-handlers)
* [Role configurations](#role-configurations)

#### Available tags

The role provides following tags for executing only a subset of tasks:

Tag | Action |
--- |---     |
`clickhouse_install` | Configure repositories and install specified packages, or install packages from configured URL, without starting the server |

#### Configure users

Just specify `clickhouse_users` variable (and `clickhouse_profiles` if you need
different profiles) like this:

```yaml
clickhouse_users:
  default:
    no_password: 1
    networks:
      - ip:
          - 127.0.0.0/8
    profile: default
    quota: default
    show_named_collections: 1
    access_management: 1
  readonly:
    no_password: 1
    networks:
      ip: "::/0"
    profile: readonly
    quota: default
clickhouse_profiles:
  default:
    database_atomic_wait_for_drop_and_detach_synchronously: 1
  readonly:
    readonly: 2
```

Here is an [example patch](ece488092e68b7fff0302955a997e33cc2b489b7)

#### Server configuration directives overrides

This can be done with overrides, they will be handled by clickhouse itself, the
only thing you need to do, is to tell the role which overrides.

So you need to set `clickhouse_configuration_files` variable:

```yaml
clickhouse_configuration_files:
  - group_templates/clickhouse/clickhouse-server/config.d/merge_tree.yml
  - file: group_templates/clickhouse/clickhouse-server/config.d/remote_servers.yml
    no_restart: true
  - file: group_templates/clickhouse/clickhouse-server/config.d/zookeeper.yml
    no_restart: true
```

Note, there are the following attributes supported:
- `no_restart` - changes of this configuration file will not restart the clickhouse-server (i.e. due to it is known that it is applied on fly)
- `no_log` - do not show diff (ansible option), see [Sensitive data in server configuration directives overrides](#sensitive-data-in-server-configuration-directives-overrides) section for more details

<details>

<summary>templates/group_templates/clickhouse/clickhouse-server/config.d/merge_tree.yml.j2</summary>

```yaml
# templates/group_templates/clickhouse/clickhouse-server/config.d/merge_tree.yml.j2
---
max_partition_size_to_drop: 0
merge_tree:
    max_suspicious_broken_parts: 5
```

</details>

<details>

<summary>templates/group_templates/clickhouse/clickhouse-server/config.d/zookeeper.yml.j2</summary>

```yaml
# templates/group_templates/clickhouse/clickhouse-server/config.d/zookeeper.yml.j2
---
zookeeper:
    - node:
          host: ch-keeper
          port: 9181
```

</details>

<details>

<summary>templates/group_templates/clickhouse/clickhouse-server/config.d/remote_servers.yml.j2</summary>

```yaml
# templates/group_templates/clickhouse/clickhouse-server/config.d/remote_servers.yml.j2
---
remote_servers:
    dev_cluster:
        - node:
              - host: 127.1
                port: 9000
                password: {{ clickhouse_users_default }}
              - host: 127.2
                port: 9000
                password: {{ clickhouse_users_default }}
    dev_cluster_secure:
        - secret: STORE_THIS_IN_ANSIBLE_VAULT_VARIABLE
          node:
              - host: 127.1
                port: 9000
              - host: 127.2
                port: 9000
    dev_cluster_replicated:
        secret: STORE_THIS_IN_ANSIBLE_VAULT_VARIABLE
        shard:
            - replica:
                  - internal_replication: true
                    host: 127.1
                    port: 9000
                  - internal_replication: true
                    host: 127.2
                    port: 9000
```

And here how you can verify clusters:

```sql
clickhouse :) select version() from clusterAllReplicas(dev_cluster) format PrettyCompactMonoBlock

SELECT version()
FROM clusterAllReplicas(dev_cluster)
FORMAT PrettyCompactMonoBlock

Query id: 8dea3b8c-7c03-4d68-9770-b659026acd3c

┌─version()─┐
│ 23.9.2.56 │
│ 23.9.2.56 │
└───────────┘
```

</details>

Here is an [example patch](db3c0e3a2c3713086af1cf3e038afc7758c13cbd)

And note, that this way, you can override any server directive, even if it
already defined in the base config (i.e. `listen_host` or `path`).

##### Server configuration directives overrides order

ClickHouse uses lexicographical order for overrides , so that the smaller name
(lexicographically, by the full path i.e.
`/etc/clickhouse-server/config.d/override.yml`, not the basename i.e.
`override.yml`) has the lowest priority.

That is why this role has `00-` prefix for all overrides, to give the lowest priority.

To give your overrides the highest priority you can use `z` prefix.

<details>

<summary>Quick test</summary>

```sh
$ { echo 00-ansible-role-config; echo 99-override-config; echo 9-override-config; echo 999-override-config; } | sort
00-ansible-role-config
999-override-config
99-override-config
9-override-config
```

</details>

##### User configuration files

You can specify additional user configuration files using the `clickhouse_user_files` variable.

```yaml
clickhouse_user_files:
  - file: group_templates/clickhouse/clickhouse-server/users.d/additional_user.yml
    no_log: true
    no_restart: true
```
There are the following attributes supported:
- `no_restart` - changes of this configuration file will not restart the clickhouse-server (i.e. due to it is known that it is applied on fly)
- `no_log` - do not show diff (ansible option), see [Sensitive data in server configuration directives overrides](#sensitive-data-in-server-configuration-directives-overrides) section for more details

<details>

<summary>templates/group_templates/clickhouse/clickhouse-server/users.d/additional_user.yml.j2</summary>

```yaml
# templates/group_templates/clickhouse/clickhouse-server/users.d/additional_user.yml.j2
users:
  additional_user:
    password: user_password
    profile: default
    quota: default
    networks:
      ip: "::/0"
```

</details>

##### Sensitive data in server configuration directives overrides

In case server or users configuration templates contains sensitive data, e. g. plain passwords,
the role provides an ability to disable rendered file contents logging for Ansible, running in
`--diff` mode.

Example of disabling logging for specific configuration override file:

```yaml
clickhouse_configuration_files:
  - group_templates/clickhouse/clickhouse-server/config.d/merge_tree.yml
  - file: group_templates/clickhouse/clickhouse-server/config.d/remote_servers.yml
    no_restart: true
  # Contents of rendered zookeeper.yml won't be displayed in Ansible logs
  - file: group_templates/clickhouse/clickhouse-server/config.d/zookeeper.yml
    no_log: true
    no_restart: true
```

Specifying `no_log` is supported for configuration overrides, specified in
`clickhouse_configuration_files` and `clickhouse_user_files`

##### Custom HTTP handlers

By default, the role provides a set of HTTP handlers along with default
handlers provided by ClickHouse.

The recommended way to create a new handler is to add it to existing handlers
by setting `clickhouse_http_handlers_files` variable:

```yaml
---
clickhouse_http_handlers_files:
  - group_templates/clickhouse/clickhouse-server/config.d/http_handlers/example.yml
```

<details>

<summary>templates/group_templates/clickhouse/clickhouse-server/config.d/http_handlers/example.yml.j2</summary>

```yaml
# templates/group_templates/clickhouse/clickhouse-server/config.d/http_handlers/example.yml.j2
- url: /settings
  methods: GET, POST
  handler:
    type: predefined_query_handler
    query: SELECT * FROM system.settings
- url: /prometheus_formatted_metrics
  methods: GET, POST
  handler:
    type: predefined_query_handler
    query: >
      SELECT
        'table_rowcount'        AS name,
        count()                 AS value,
        'gauge'                 AS type,
        map('group', group_key) AS labels
      FROM default.table
      GROUP BY group_key
      ORDER BY name ASC, value DESC
      FORMAT Prometheus
```

</details>

New handlers can also be configured by overriding `http_handlers`
server configuration parameter as described above.

#### Role configurations

Variable | Description |
---      |---          |
`clickhouse_setup` | ClickHouse setup mode: `full` (default) - setup both client and server, `client` - setup only client |
`clickhouse_apt_repo` | Apt repository to install packages from, defaults to official ClickHouse repository |
`clickhouse_apt_repo_key` | Apt repository public key, must be specified along with `clickhouse_apt_keyserver` |
`clickhouse_apt_keyserver` | Keyserver with repository public key |
`clickhouse_apt_repo_key_url` | URL to download repository public key from. If specified, the role will ignore `clickhouse_apt_repo_key` variable |

For more configuration options, look at [defaults/main.yml](defaults/main.yml)
