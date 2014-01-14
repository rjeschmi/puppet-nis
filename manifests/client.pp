class nis::client inherits nis {
    service { "ypbind":
              ensure => running,
              enable => true,
              hasrestart => true,
              subscribe => [File["/etc/yp.conf"]],
              require => [File["/etc/yp.conf"],File["/etc/nsswitch.conf"]]
    }
}
