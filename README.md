#### FROM Sahil

> TODO: READ (Passthrough GPU and sound card so sound and mic may start working): [passthrough-gpu-sahil.md](passthrough-gpu-sahil.md)
> TODO: I think with a (2 US DOLLAR) Usb Sound card thing I can attach sound + microphone to the macos, yo as he uses it [here](https://github.com/kholia/OSX-KVM/blob/master/OpenCore-Boot.sh#L40-L41)

![image](https://user-images.githubusercontent.com/31458531/179983357-d246619e-7f60-4e5f-9204-4eb1bffdb56d.png)

> I have modified `basic.sh` file only (which is used to lauch clover i.e., Boot Loader for macos). `basic.sh` is used to install macos and as well as for booting the installed macos on our disk.
> Source: [github.com/foxlet/macOS-Simple-KVM.git](https://github.com/foxlet/macOS-Simple-KVM.git)
> ~Sahil

# macOS-Simple-KVM
Documentation to set up a simple macOS VM in QEMU, accelerated by KVM.

By [@FoxletFox](https://twitter.com/foxletfox), and the help of many others. Find this useful? You can donate [on Coinbase](https://commerce.coinbase.com/checkout/96dc5777-0abf-437d-a9b5-a78ae2c4c227) or [Paypal!](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=QFXXKKAB2B9MA&item_name=macOS-Simple-KVM).

New to macOS and KVM? Check [the FAQs.](docs/FAQs.md)

## Getting Started
You'll need a Linux system with `qemu` (3.1 or later), `python3`, `pip` and the KVM modules enabled. A Mac is **not** required. Some examples for different distributions:

```
sudo apt-get install qemu-system qemu-utils python3 python3-pip  # for Ubuntu, Debian, Mint, and PopOS.
sudo pacman -S qemu python python-pip python-wheel  # for Arch.
sudo xbps-install -Su qemu python3 python3-pip   # for Void Linux.
sudo zypper in qemu-tools qemu-kvm qemu-x86 qemu-audio-pa python3-pip  # for openSUSE Tumbleweed
sudo dnf install qemu qemu-img python3 python3-pip # for Fedora
sudo emerge -a qemu python:3.4 pip # for Gentoo
```

## Step 1
Run `jumpstart.sh` to download installation media for macOS (internet required). The default installation uses Catalina, but you can choose which version to get by adding either `--high-sierra`, `--mojave`, or `--catalina`. For example:
```
./jumpstart.sh --mojave
```
> Note: You can skip this if you already have `BaseSystem.img` downloaded. If you have `BaseSystem.dmg`, you will need to convert it with the `dmg2img` tool.

## Step 2
Create an empty hard disk using `qemu-img`, changing the name and size to preference:
```
qemu-img create -f qcow2 MyDisk.qcow2 64G
```

and add it to the end of `basic.sh`:
```
    -drive id=SystemDisk,if=none,file=MyDisk.qcow2 \
    -device ide-hd,bus=sata.4,drive=SystemDisk \
```
> Note: If you're running on a headless system (such as on Cloud providers), you will need `-nographic` and `-vnc :0 -k en-us` for VNC support.

Then run `basic.sh` to start the machine and install macOS. Remember to partition in Disk Utility first!

## Step 2a (Virtual Machine Manager)
1. If instead of QEMU, you'd like to import the setup into Virt-Manager for further configuration, just run `sudo ./make.sh --add`.
2. After running the above command, add `MyDisk.qcow2` as storage in the properties of the newly added entry for VM.

## Step 2b (Headless Systems)
If you're using a cloud-based/headless system, you can use `headless.sh` to set up a quick VNC instance. Settings are defined through variables as seen in the following example. VNC will start on port `5900` by default.
```
HEADLESS=1 MEM=1G CPUS=2 SYSTEM_DISK=MyDisk.qcow2 ./headless.sh
```

## Step 3

You're done!

To fine-tune the system and improve performance, look in the `docs` folder for more information on [adding memory](docs/guide-performance.md), setting up [bridged networking](docs/guide-networking.md), adding [passthrough hardware (for GPUs)](docs/guide-passthrough.md), tweaking [screen resolution](docs/guide-screen-resolution.md), and enabling sound features.
