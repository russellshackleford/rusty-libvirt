LIBVIRT_DEFAULT_URI="qemu:///system"
if [ -f /proc/xen/capabilities ]; then
        if [ "$(cat /proc/xen/capabilities)" = "control_d" ]; then
                LIBVIRT_DEFAULT_URI="xen:///"
        fi
fi

export LIBVIRT_DEFAULT_URI
