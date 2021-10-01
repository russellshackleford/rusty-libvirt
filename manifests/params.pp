# @api private
class libvirt::params {

  if $facts['os']['family'] == 'RedHat' {
    $virt_install_pkg = $facts['os']['release']['major'] ? {
      '6'     => 'python-virtinst',
      '8'     => 'virt-install',
      default => undef,
    }
  } else {
    $virt_install_pkg = undef
  }
}
