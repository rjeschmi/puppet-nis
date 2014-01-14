# == Class: nis
#
# A simple class to manage NIS servers and clients
#
# === Parameters
#
# [*ypdomain*]
#   The NIS domain name
#
# [*ypserver*]
#   The NIS server
#
# [*ypmaster*]
#   The NIS master
#
# [*client*]
#   Enable the client configuration
#
# [*server*]
#   Enable the server configuration
#
# [*master*]
#   Enable the a master server if true or a slave one if false
#
# [*groups*]
#   Enable group login via NIS. Default is none.
#
# [*securenets*]
#   Securenets file to be used.
#
# [*hostallow*]
#   Hosts to allow for portmap/rpcbind.
#
# === Examples
#
#  class { nis:
#    client   => true,
#    ypdomain => "example",
#    ypserver => "nis.example.com",
#  }
#
# === Authors
#
# Alessandro De Salvo <Alessandro.DeSalvo@roma1.infn.it>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#

define nis::enable_nis_groups {
    augeas{ "${title} nis group enable" :
        context => "/files/etc/passwd",
        changes => [
            "set @nis ${title}",
        ],
    }
}

class nis (
   $ypdomain,
   $ypserv     = undef,
   $ypmaster   = undef,
   $client     = true,
   $server     = false,
   $master     = true,
   $groups     = undef,
   $securenets = undef,
   $hostallow  = undef,
) {

   package { "ypbind": ensure => latest }

   file { "/etc/yp.conf":
      ensure  => file,
      owner   => "root",
      group   => "root",
      mode    => 0644,
      content => template("nis/yp.conf.erb"),
      require => Package["ypbind"]
   }

   file { "/etc/nsswitch.conf":
      ensure  => file,
      owner   => "root",
      group   => "root",
      mode    => 0644,
      source  => "puppet:///modules/nis/nsswitch.conf",
   }

   augeas{ "nis domain network" :
       context => "/files/etc/sysconfig/network",
       changes => [
           "set NISDOMAIN ${ypdomain}",
           "set DOMAIN ${ypdomain}",
       ],
   }

   if (!$groups) {
       augeas{ "add nis passwd default" :
           context => "/files/etc/passwd",
           changes => [
               'set @nisdefault/password x',
               'set @nisdefault/uid ""',
               'set @nisdefault/gid ""',
               'clear @nisdefault/name',
               'clear @nisdefault/home',
               'set @nisdefault/shell /sbin/nologin',
           ],
       }
       augeas{ "remove nis groups" :
           context => "/files/etc/passwd",
           changes => [
               'rm @nis',
           ],
       }
   } else {
       augeas{ "remove nis passwd default" :
           context => "/files/etc/passwd",
           changes => [
               'rm @nisdefault',
           ],
       }
       nis::enable_nis_groups { $groups: }
   }

   augeas{ "nis group default" :
       context => "/files/etc/group",
       changes => [
           'set @nisdefault/password ""',
           'set @nisdefault/gid ""',
       ],
   }

   if ($client) {
       class { 'nis::client': }
   }
   if ($server) {
       class { 'nis::server':
           ypdomain   => $ypdomain,
           ypmaster   => $ypmaster,
           master     => $master,
           securenets => $securenets,
           hostallow  => $hostallow,
       }
   }

}
