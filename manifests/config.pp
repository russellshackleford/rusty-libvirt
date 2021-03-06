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
        $service = Service[$libvirt::libvirt_service]
      }
      '8': {
        $filesuf = '-el8'
        $pol_file = '/etc/polkit-1/rules.d/50-libvirt.rules'
        # The three systemd "services" are just sockets. They don't need to be
        # restarted. Most of libvirtd.conf is ignored when using systemd anyway.
        $service = undef
      }
      default: { fail('This OS is not yet supported') }
    }
  } else {
    fail('This OS is not yet supported')
  }

  file { '/etc/profile.d/libvirt-uri.sh':
    ensure => present,
    mode   => '0644',
    source => 'puppet:///modules/libvirt/libvirt-uri.sh',
  }

  file { '/etc/libvirt/libvirtd.conf':
    ensure  => present,
    content => epp("libvirt/libvirtd${filesuf}.conf.epp"),
    require => Class['libvirt::install'],
    notify  => $service,
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
