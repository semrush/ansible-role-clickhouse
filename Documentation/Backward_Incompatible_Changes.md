## Backward Incompatible Changes

This is actually not a backward incompatible, but changes that you must know about!

* [Add prefix for files under config.d directory](#add-prefix-for-files-under-configd-directory)

### Add prefix for files under `config.d` directory

In 551fd236e1cc495df260548ca8bcac35ad08c67b files that are shipped within this
role (some default overrides), started to have prefix `00-`, this is required
to load them first, so that anything else will override them. But there is no
task to remove old files, so it is your responsibility to do this.

Here is an example onelinear for this:

```sh
ls -1d /etc/clickhouse-server/config.d/* | grep /00- | sed 's/00-//g' | xargs -r rm
```

*Note: that strictly speaking nothing will be broken even if you will not
remove them, but there will be duplicated configuration files, and overrides
may not work as described in the documentation*

See also: [Server configuration directives overrides order](#server-configuration-directives-overrides-order)
