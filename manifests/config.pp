# @api private
class libvirt::config {

  if $libvirt::manage_group {
    group { $libvirt::socket_group:
      ensure => present,
      gid    => $libvirt::socket_gid,
    }
  }

  if $facts['os']['family'] == 'RedHat' {
    case $facts['os']['release']['major'] {
      '6': {
        $filesuf = '-el6'
      }
      '8': {
        $filesuf = '-el8'
      }
      default: { fail('This OS is not yet supported') }
    }
  } else {
    fail('This OS is not yet supported')
  }

  file { '/etc/libvirt/libvirtd.conf':
    ensure  => present,
    content => epp("libvirt/libvirtd${filesuf}.conf.epp"),
    require => Class['libvirt::install'],
  }
}
