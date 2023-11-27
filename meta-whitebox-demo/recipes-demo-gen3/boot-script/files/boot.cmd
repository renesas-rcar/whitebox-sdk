# Load image from storage

ext2load ${aos_device}:${aos_boot_slot} 0x48080000 xen
ext2load ${aos_device}:${aos_boot_slot} 0x48000000 xen.dtb
ext2load ${aos_device}:${aos_boot_slot} 0x8e000000 xenpolicy
ext2load ${aos_device}:${aos_boot_slot} 0x8a000000 zephyr.bin

# Configure boot device in DTS

fdt addr 0x48000000
fdt resize
fdt mknode / boot_dev
fdt set /boot_dev device ${aos_boot_device}

# Boot the board

bootm 0x48080000 - 0x48000000
