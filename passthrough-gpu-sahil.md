## Passthrough GPU

Source:: https://github.com/foxlet/macOS-Simple-KVM/blob/master/docs/guide-passthrough.md

1. Load the vfio-pci module
    > Get device ids: `lspci -nn | grep "VGA\|Audio"`

- a.  https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Binding_vfio-pci_via_device_ID
- b. https://wiki.archlinux.org/title/Kernel_parameters#GRUB
    > TLDR: Add `vfio-pci.ids=8086:1916,8086:9d70` to kernel params. (these are device ids of my graphic card and audio card (i.e., got device ids from the end part of the output from: `lspci -nn | grep "VGA\|Audio"` (aliased to `lscpi.VgaAudio`).


2. Enable IOMMU: 
https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Enabling_IOMMU
tldr: `iommu=pt intel_iommu=on parameters` to be added to kernel params..., now read from above link to ensure that iommu is loaded successfully.


***\*MASTER TLDR of above Step 1 and Step 2: Add `iommu=pt intel_iommu=on vfio-pci.ids=8086:1916,8086:9d70` to kernel params.***

3. Add params to `basic.sh` to macos-simple-kvm launcher script:

```bash
    -vga none \
    -device pcie-root-port,bus=pcie.0,multifunction=on,port=1,chassis=1,id=port.1 \
    -device vfio-pci,host=00:02.0,bus=port.1,multifunction=on,romfile=/path/to/card.rom \
    -device vfio-pci,host=00:1f.3,bus=port.1 \
```

***\*Changing Grub's kernel arguments via grub loader to make it permanent:*** `vi /etc/default/grub` aliased to `vi.grub`.
***\*You can check the parameters your system was booted up with by running:*** `cat /proc/cmdline ` (aliased to `cat.kernelParams`) and see if it includes your changes.
