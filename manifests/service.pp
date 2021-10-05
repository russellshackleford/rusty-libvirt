# @api private
class libvirt::service {
  service { 'libvirt':
    ensure     => running,
    name       => $libvirt::libvirt_service,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['libvirt::config'],
  }

  # This "service" just runs a script. With systemd you can get a status
  # preventing restarting it on every puppet run, but no such luck on el6. To
  # keep things consistent, however, we will not try to start this "service",
  # just enable it to ensure that the host itself handles starting/stopping.
  service { 'libvirt-guests':
    name    => $libvirt::libvirt_guests_service,
    enable  => $libvirt::libvirt_guests,
    require => Class['libvirt::config'],
  }
}
