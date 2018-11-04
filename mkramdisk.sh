#!/bin/bash
echo "Enter the kernel version."
read KERNEL

/sbin/mkinitrd -c -k $KERNEL -f ext4 -r /dev/sda1 -m xhci-pci:ohci-pci:ehci-pci:xhci-hcd:uhci-hcd:ehci-hcd:hid:usbhid:i2c-hid:hid_generic:hid-cherry:hid-logitech:hid-logitech-dj:hid-logitech-hidpp:hid-lenovo:hid-microsoft:hid_multitouch:jbd2:mbcache:ext4:i915 -u -o /boot/initrd.gz -P /boot/intel-ucode.cpio
/sbin/lilo

