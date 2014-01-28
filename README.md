# puppet-pgbackups

Puppet module for setting up regular postgres database backups

### Install

Not yet available of Puppet Forge.

To install as a git submodule, run:

    $ git submodule add git@github.com:simpleweb/puppet-pgbackups.git modules/pgbackups


### Usage

All options are shown, with defaults:

```puppet
class { "pgbackups::database":
  backup_dir => "/var/backups/pgsql",
  backup_format => "plain",
  user => "postgres",
  postgres_host => "localhost",
  postgres_user => "postgres",
  postgres_password => undef,
  postgres_database => (required)
}
```


### Dependencies

* [postgresql](http://forge.puppetlabs.com/puppetlabs/postgresql)
* [stdlib](http://forge.puppetlabs.com/puppetlabs/stdlib)
