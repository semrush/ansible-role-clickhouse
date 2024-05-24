## Yet Another Ansible Role For ClickHouse

### Prerequisites

ClickHouse v23.5 (*note: yes, it could be relaxed, but I just don't think that it worth it*)

#### Version requirement changelog

It is better to use the latest ClickHouse stable release.

Details can be read [here](Documentation/ClickHouse_Changelog.md).

### Getting started

For a basic standalone setup it is enough to do the following:

Add requirements:

```yaml
# requirements.yml
---
roles:
- name: clickhouse
  scm: git
  src: git@github.com:semrush/ansible-role-clickhouse.git
  version: x
```

If you want for role auto update, then you can add this role to `.gitignore` (or install it outside of the repository):

```
# .gitignore
/roles/clickhouse
```

And install the role:

```sh
ansible-galaxy install -r requirements.yml -p roles clickhouse
```

Add a simple playbook:

```yaml
# clickhouse.yml
---
- name: Install ClickHouse
  hosts: all
  gather_facts: yes
  roles:
    - clickhouse
```

And run ansible:

```sh
ansible-playbook --become --diff clickhouse.yml
# ansible-playbook --become --diff -i CLICKHOUSE_HOST, clickhouse.yml
```

Here is an [example patch](12bbe612e66ce2dc489a1a2acb2713ac0ccefadb),
or the [folder itself](example)

### [Advanced usage](Documentation/Advanced_Configuration.md)

See [this page](Documentation/Advanced_Configuration.md).

### Key features

- Developed with extensibility in mind (at least I hope)

- Using YAML for configurations, and even though the syntax somewhere is
  tricky, it shows itself good.

  For instance `jinja2` natively render `dict` in `YAML`, so we don't need to
  add additional loops over keys/values in the templates.

- Provide sane defaults:

  - Enabled `*_log` tables by default - usual problem for existing roles is
    that they have a copy of `config.xml` from a specific point in time, and
    don't have new system tables.

  - TTL for `*_log` tables

  - Enabled prometheus exported by default

  - Has extra metrics via `http_handlers`

### [Comparison](Documentation/Comparison.md)

See [this page](Documentation/Comparison.md).

### [Backward incompatible changes](Documentation/Backward_Incompatible_Changes.md)

See [this page](Documentation/Backward_Incompatible_Changes.md).

### [Tests](Documentation/Tests.md)

See [this page](Documentation/Tests.md).

### [Examples](example#test)

See [this page](example#test).

### Question? Problem?

You can create an issue [here](https://github.com/semrush/ansible-role-clickhouse/issues).

### Adopters

*Please, add yourself to the adopters list (just send us merge request)!*
