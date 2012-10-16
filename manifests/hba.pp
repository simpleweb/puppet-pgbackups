/*
== Definition: postgresql::hba

Add/remove lines from pg_hba.conf file. NB: puppet reloads postgresql each time
a change is made to pg_hba.conf using this definition.

Parameters:
- *ensure*: present/absent, default to present.
- *type*: local/host/hostssl/hostnossl, mandatory.
- *database*: database name or "all", mandatory.
- *user*: username or "all", mandatory.
- *address*: CIDR or IP-address, mandatory if type is host/hostssl/hostnossl.
- *method*: auth-method, mandatory.
- *option*: optional additional auth-method parameter.
- *path*: path of the configuration file

See also:
http://www.postgresql.org/docs/current/static/auth-pg-hba-conf.html

Example usage:

  postgresql::hba { "access to database toto":
    ensure   => present,
    type     => 'local',
    database => 'toto',
    user     => 'all',
    method   => 'ident',
    option   => "map=toto",
  }

  postgresql::hba { "access to database tata":
    ensure   => present,
    type     => 'hostssl',
    database => 'tata',
    user     => 'www-data',
    address  => '192.168.0.0/16',
    method   => 'md5',
  }

*/
define postgresql::hba (
  $type,
  $database,
  $user,
  $method,
  $ensure  = 'present',
  $address = false,
  $option  = false,
  $path    = false
) {

  include postgresql::params

  $target = $path ? {
    false   => $postgresql::params::pg_hba_conf_path,
    default => $path,
  }

  case $type {

    'local': {
      $changes = [ # warning: order matters !
        "set /01/type ${type}",
        "set /01/database ${database}",
        "set /01/user ${user}",
        "set /01/method ${method}",
      ]

      $xpath = "/*[type='${type}'][database='${database}'][user='${user}'][method='${method}']"
    }

    'host', 'hostssl', 'hostnossl': {
      if ! $address {
        fail("\$address parameter is mandatory for non-local hosts.")
      }

      $changes = [ # warning: order matters !
        "set /01/type ${type}",
        "set /01/database ${database}",
        "set /01/user ${user}",
        "set /01/address ${address}",
        "set /01/method ${method}",
      ]

      $xpath = "/*[type='${type}'][database='${database}'][user='${user}'][address='${address}'][method='${method}']"
    }

    default: {
      fail("Unknown type '${type}'.")
    }
  }

  if versioncmp($augeasversion, '0.7.3') < 0 {
    $lpath = "/usr/share/augeas/lenses/contrib"
    $require_lens = true
  } else {
    $lpath = undef
    $require_lens = false
  }

  case $ensure {

    'present': {
      augeas { "set pg_hba ${name}":
        incl    => "${postgresql::params::conf_dir}/pg_hba.conf",
        lens    => 'Pg_Hba.lns',
        changes => $changes,
        onlyif  => "match ${xpath} size == 0",
        notify  => Exec['reload_postgresql'],
        require => $require_lens ? {
          false => Package['postgresql'],
          true  => [Package['postgresql'], File["${lpath}/pg_hba.aug"]],
        },
        load_path => $lpath,
      }

      if $option {
        augeas { "add option to pg_hba ${name}":
          incl    => "${postresql::params::conf_dir}/pg_hba.conf",
          lens    => 'Pg_Hba.lns',
          changes => "set ${xpath}/method/option ${option}",
          onlyif  => "match ${xpath}/method/option size == 0",
          notify  => Exec['reload_postgresql'],
          require => $require_lens ? {
            false => Augeas["set pg_hba ${name}"],
            true  => [Augeas["set pg_hba ${name}"], File["${lpath}/pg_hba.aug"]],
          },
          load_path => $lpath,
        }
      }
    }

    'absent': {
      augeas { "remove pg_hba ${name}":
        incl    => "${postresql::params::conf_dir}/pg_hba.conf",
        lens    => 'Pg_Hba.lns',
        changes => "rm ${xpath}",
        onlyif  => "match ${xpath} size == 1",
        notify  => Exec['reload_postgresql'],
        require => $require_lens ? {
          false => Package['postgresql'],
          true  => [Package['postgresql'], File["${lpath}/pg_hba.aug"]],
        },
        load_path => $lpath,
      }
    }

    default: {
      fail("Unknown ensure '${ensure}'.")
    }
  }

}
