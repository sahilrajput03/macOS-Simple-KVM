#!/bin/bash

# ~Sahil: It took me 2 HOURS of complete time with this setup as install time.
# also: I read online from one issue on the github repo of this project that we can significantly reduce the install time by using a complete offline image of `macos` coz 
# using current setup I download a `BaseSystem.img` from official apple servers which is 500M and then extracts to 2G.. but later on when the install happens around 6G of more is downloaded and that accounts for the slow install of macos. So, TODO: I need to use complete image of macos catalina (~8gb) file from somewhere online as instructed by one commenter in that same github issue. YO!!

OSK="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
VMDIR=$PWD
OVMF=$VMDIR/firmware
# export QEMU_AUDIO_DRV=alsa	# SRC: https://bbs.archlinux.org/viewtopic.php?id=198058 ;  ~sahil 
# export QEMU_AUDIO_DRV=pa		# `pa` means pulseaudio imo
#QEMU_AUDIO_DRV=pa

args=(
    -enable-kvm
    -m 6G
    -machine q35,accel=kvm
    -smp 4,cores=4
    -cpu Penryn,vendor=GenuineIntel,kvm=on,+sse3,+sse4.2,+aes,+xsave,+avx,+xsaveopt,+xsavec,+xgetbv1,+avx2,+bmi2,+smep,+bmi1,+fma,+movbe,+invtsc
    -device isa-applesmc,osk="$OSK"
    -smbios type=2
    -drive if=pflash,format=raw,readonly=on,file="$OVMF/OVMF_CODE.fd"
    -drive if=pflash,format=raw,file="$OVMF/OVMF_VARS-1024x768.fd"
    -vga qxl
    -device ich9-intel-hda -device hda-output
    -usb -device usb-kbd -device usb-mouse
	-usb -device usb-ehci -device usb-host,hostbus=0,hostaddr=4
    -netdev user,id=net0
    -device e1000-82545em,netdev=net0,id=net0,mac=52:54:00:c9:18:27
    -device ich9-ahci,id=sata
    -drive id=ESP,if=none,format=qcow2,file=ESP.qcow2
    -device ide-hd,bus=sata.2,drive=ESP
    -drive id=InstallMedia,format=raw,if=none,file=BaseSystem.img
    -device ide-hd,bus=sata.3,drive=InstallMedia
    -drive id=SystemDisk,if=none,file=MyDisk.qcow2
    -device ide-hd,bus=sata.4,drive=SystemDisk
    # -vga none \
    # -device pcie-root-port,bus=pcie.0,multifunction=on,port=1,chassis=1,id=port.1 \
    # -device vfio-pci,host=00:02.0,bus=port.1,multifunction=on \
    # -device vfio-pci,host=00:1f.3,bus=port.1 \

	# for 00:02.0: failed to open /dev/vfio/1: No such file or directory
	# for 00:1f.3: failed to open /dev/vfio/9: No such file or directory

	#######################
	# For trying to get microphone working.. (DIDN'T WORK THIS WAY)
	# -device sb16 \
	# -device intel-hda -device hda-duplex \
	# -device gus \
	# -device ES1370 \
	# -device cs4231a \
	# -device adlib \

	# got all above sound cards connecting info from qemu itself when I tried to use below `soundhw all` argument:
	# -soundhw all \
	# -audiodev alsa,id=snd0,out.buffer-length=500000,out.period-length=726 \
	# added below two lines ~Sahil, following from official install instructions.
	########################
	)

# INSPIRED FOR THIS WAY OF PASSING ARGUMENTS FROM AN ARRAY IS FROM: https://github.com/kholia/OSX-KVM/blob/master/OpenCore-Boot.sh
# REASON: We can have comments in between the arguments now!! (LERAN: Using `\ ` in the end of arguments we can't use comments inbetween else the arguments following the # will not be passed to cli.
qemu-system-x86_64 "${args[@]}"


########## IMPLEMENTING webcam support(took 3 hrs IMO)
# ADDED below line to support webcam on line:21
# -device usb-ehci,id=ehci
# https://stackoverflow.com/a/58583288/10012446
# root source: https://github.com/foxlet/macOS-Simple-KVM/issues/362

# FROM `lsusb` OUTPUT:
# lsusb
# Bus 001 Device 004: ID 0bda:57d6 Realtek Semiconductor Corp. HP Truevision HD
#
# THIS WAS LIFE SAVER: https://gist.github.com/pojntfx/b860e123e649504bcd298aa6e92c4043
# I learned the `sudo` appending to command from ^^ this post, yikes!!
# Now that I added my HP Truevisioin HD camera I must run `qemu-system-x86_64` as `sudo` command otherwise my camera won't run.
# Test if you camera is connected to macos? Open `Photo Booth` application from `Launchpad`.
# I COMMENTED ON SO's ansewr as well for this: https://stackoverflow.com/a/58583288/10012446
#######
#
#######
# #### NEW INFO TO DISCOVER PCIE PASSTHROUGH FOR GRAPHICS CARD AND SOUND CARD (WILL PROBABLY ENABLE MICROPHONE ACCESS AS WELL):
# PERSON WHO GOT EXACTLY SAME ISSUE AS MINE: https://github.com/foxlet/macOS-Simple-KVM/issues/497
# Person who actually passthroughed graphics card in an issue in `macos-simple-kvm`: https://github.com/foxlet/macOS-Simple-KVM/issues/563
# very smooth article explaining everything: https://null-src.com/posts/qemu-vfio-pci/post.php
#
# BELOW STACKOVERFLOW AND IBM ARTICLE ASKS FOR SAME THING:
# a. https://stackoverflow.com/a/70697330/10012446
# b. https://www.ibm.com/docs/en/linux-on-systems?topic=through-pci
# 
#
# DOCS: macos-simple-kvm: passthrough: https://github.com/foxlet/macOS-Simple-KVM/blob/master/docs/guide-passthrough.md
# qemu-system-x86_64 -smp help
#
#
# https://www.reddit.com/r/archlinux/comments/acwv4n/can_i_load_the_vfiopci_module_using_a_kernel/
#
# OTHER COMMANDS:
# dmesg | grep -i vfio
# lspci -nnk -d 8086:1916
# lspci -nnk -d 8086:9d70
#
# ls -l /dev/vfio/
# ##################
