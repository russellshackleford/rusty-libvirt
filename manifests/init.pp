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
# @param manage_group
#   Whether to create the `socket_group` group. This only ensures the group
#   exists. It does not change the members of the group. It _will_ change the
#   GID to match `socket_gid` if `socket_gid` is set to a value.
#
# @param socket_group
#   The group that allows access via polkit regardless if `manage_group` is
#   true or false
#
# @param socket_gid
#   The `socket_group`'s GID
#
class libvirt(
  Boolean $kvm = true,
  String[1] $kvm_pkg = 'qemu-kvm',
  String[1] $libvirt_pkg = 'libvirt',
  Boolean $virt_install = true,
  Optional[String[1]] $virt_install_pkg = $libvirt::params::virt_install_pkg,
  Boolean $manage_group = false,
  String[1] $socket_group = 'libvirt',
  Optional[Integer] $socket_gid = undef,
) inherits libvirt::params {

  class { 'libvirt::install': }
  -> class { 'libvirt::config': }
}
