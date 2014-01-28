# puppet-pgbackups

Puppet module for setting up regular postgres database backups

### Install

Not yet available of Puppet Forge.

To install as a git submodule, run:

    $ git submodule add git@github.com:simpleweb/puppet-pgbackups.git modules/pgbackups


### Usage

All options are shown, with defaults:

```puppet
class { "pgbackups::backup":
  backup_dir => "/var/backups/pgsql",
  backup_format => "plain",
  user => "postgres"
}
```


### Dependencies

* [postgresql](http://forge.puppetlabs.com/puppetlabs/postgresql)
* [stdlib](http://forge.puppetlabs.com/puppetlabs/stdlib)
