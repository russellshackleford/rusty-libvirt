# @summary
#   Sets up libvirtd and optionally qemu-kvm and virt-install
#
# @api public
#
# @example
#   include libvirt
#
# @param kvm
#   Whether to install qemu-kvm or not
#
# @param kvm_pkg
#   The name of the qemu-kvm package
#
# @param libvirt_pkg
#   The name of the libvirt package
#
# @param virt_install
#   Whether to install virt-install
#
# @param virt_install_pkg
#   The name of the virt-install package. Default value is OS-dependent.
#
class libvirt(
  Boolean $kvm = true,
  String[1] $kvm_pkg = 'qemu-kvm',
  String[1] $libvirt_pkg = 'libvirt',
  Boolean $virt_install = true,
  Optional[String[1]] $virt_install_pkg = $libvirt::params::virt_install_pkg,
) inherits libvirt::params {

  class { 'libvirt::install': }
}
