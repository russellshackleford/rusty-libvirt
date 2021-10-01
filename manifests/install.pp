# @api private
class libvirt::install {

  package { 'libvirt':
    ensure => present,
    name   => $libvirt::libvirt_pkg,
  }

  if $libvirt::kvm {
    package { 'kvm':
      ensure => present,
      name   => $libvirt::kvm_pkg,
    }
  }

  if $libvirt::virt_install {
    if $libvirt::virt_install_pkg {
      package { 'virt-install':
        ensure => present,
        name   => $libvirt::virt_install_pkg,
      }
    } else {
      $warnmsg = @(EOT/L)
        Default virt-install package name unknown for this OS. \
        Please supply one.
        |-EOT
      notify { $warnmsg : }
      warning($warnmsg)
    }
  }
}
