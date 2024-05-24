## Comparison

### [AlexeySetevoi/ansible-clickhouse](https://github.com/AlexeySetevoi/ansible-clickhouse)

- Divide configuration files to the one that requires server restart and the
  one that don't

- Overrides via configuration files, instead of variables. So instead of
  providing lots of variables to passthrough to `config.xml` this role simply
  allows you to specify which additional configurations will be used instead,
  there are two variables:

  - `clickhouse_configuration_files` - additional configuration files
  - `clickhouse_top_level_domains_lists_files` - static files for `top_level_domains_lists`

  And those files (in combining with some predefined set of files) will be put
  into config.d and ClickHouse will merge them by itself.

  Note: if you want to override some file, you can prefix it with `z` (or
  similar) to force ClickHouse to load it in the last order (but please verify
  this).

- But for users approach with variables is used. For two reasons:

  - There is no simple way to override default user with `users.d`

  - And also users definition is minimal, in compare with server configuration,
    you only need to define `users`, `profiles`, `quotas`.

- *See also [Key features](#key-features)*
