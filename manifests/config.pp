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
        $pol_file = '/etc/polkit-1/localauthority/50-local.d/50-libvirtd.pkla'
      }
      '8': {
        $filesuf = '-el8'
        $pol_file = '/etc/polkit-1/rules.d/50-libvirt.rules'
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
    notify  => Service['libvirt'],
  }

  # This will be read as needed by the init script. Don't notify the service.
  file { '/etc/sysconfig/libvirt-guests':
    ensure  => present,
    content => epp("libvirt/libvirt-guests${filesuf}.epp"),
    require => Class['libvirt::install'],
  }

  # This file is read as needed, not at startup. Don't notify the service.
  if $libvirt::manage_polkit {
    file { $pol_file:
      ensure  => present,
      content => epp("libvirt/polkit${filesuf}.epp"),
      require => Class['libvirt::install'],
    }
  }
}
