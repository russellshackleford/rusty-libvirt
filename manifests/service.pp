# @api private
class libvirt::service {

  if $facts['os']['family'] == 'RedHat' {
    case $facts['os']['release']['major'] {
      '6': {
        $services = $libvirt::libvirt_service
        $provider = 'redhat'
        # On el6
        $guests_ensure = undef
      }
      '8': {
        $services = ['virtlogd.socket', 'virtlockd.socket', 'libvirtd.socket']
        # Puppet 4 doesn't know about el8 and assumes sysvinit
        $provider = 'systemd'
        if $libvirt::libvirt_guests {
          $guests_ensure = true
        } else {
          $guests_ensure = undef
        }
      }
      default: { fail('This OS is not yet supported') }
    }
  } else {
    fail('This OS is not yet supported')
  }

  service { $services:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => $provider,
    require    => Class['libvirt::config'],
  }

  # On el6, this is just a script that, if enabled before shutdown, will do the
  # Right Thing™. On el8, however, the "service" must already be in an active
  # state or else it won't properly suspend/shutdown the guests.
  service { 'libvirt-guests':
    ensure   => $guests_ensure,
    name     => $libvirt::libvirt_guests_service,
    enable   => $libvirt::libvirt_guests,
    provider => $provider,
    require  => Class['libvirt::config'],
  }
}
