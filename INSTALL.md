# Sample installation

So far the layer has been tested with a qemu image with the sample configuration explained below. The ultimate goal is to build a minimal image for Raspberry Pi. At the moment, the configuration is the following.

### Clone repositiories:

```
~$ mkdir skyocto
~$ cd sk-yocto
~/sk-yocto$ git clone -b rocko git://git.yoctoproject.org/poky.git poky-rocko
~/sk-yocto$ git clone -b rocko git://git.openembedded.org/meta-openembedded
~/sk-yocto$ git clone -b rocko git://git.yoctoproject.org/meta-raspberrypi
~/sk-yocto$ git clone https://github.com/overtane/meta-signalk
```


### Patch npm scripts

I had to make some fixes to npm handling. There is a patch file in the repo (```poky-rocko.patch```) that should be applied to poky repo. Disclaimer: The first try was to make recipes to pull from SignalK github. Some of the changes were made for this. I'm not sure if all of the fixes are needed for current npm registry scheme.

[More about the problem](https://wiki.yoctoproject.org/wiki/TipsAndTricks/NPM).


### Initialise build environment

```
~/sk-yocto$ source poky-rocko/oe-init-build-env
~/sk-yocto/build$ vi conf/local.conf
```
(instead of `vi` you can use the editor of your choice)

Append the following to `local.conf`:
```
include conf/machine/${MACHINE}-extra.conf

IMAGE_ROOTFS_EXTRA_SPACE = "500000"

DISTRO_FEATURES_remove = " x11 wayland"
DISTRO_FEATURES_append = " systemd"
VIRTUAL-RUNTIME_init_manager = "systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED = "sysvinit"
VIRTUAL-RUNTIME_initscripts = ""

IMAGE_INSTALL_append = " nodejs nodejs-npm nodejs-systemtap"
IMAGE_INSTALL_append = " avahi-daemon avahi-dnsconfd avahi-utils"
IMAGE_INSTALL_append = " signalk-server"
IMAGE_FEATURES_remove = " splash"
CORE_IMAGE_EXTRA_INSTALL = "systemd-analyze systemd-bootchart"

PREFERRED_VERSION_nodejs = "8.4.0"
```

Next exit `conf/bblaeyrs.conf`. It should look like this (replace `~` with the absolute path to your home directory):
```
# POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
POKY_BBLAYERS_CONF_VERSION = "1"

BBPATH = "${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \
  ~/sk-yocto/poky-rocko/meta \
  ~/sk-yocto/poky-rocko/meta-poky \
  ~/sk-yocto/poky-rocko/meta-yocto-bsp \
  ~/sk-yocto/meta-openembedded/meta-oe \
  ~/sk-yocto/meta-openembedded/meta-python \
  ~/sk-yocto/meta-openembedded/meta-networking \
  ~/sk-yocto/meta-raspberrypi \
  ~/sk-yocto/meta-signalk \
  "
```

Use `bitbake-layers` to check the result:
```
~/sk-yocto/build$ bitbake-layers show-layers
NOTE: Starting bitbake server...
layer                 path                                      priority
==========================================================================
meta                  ~/sk-yocto/poky-rocko/meta                    5
meta-poky             ~/sk-yocto/poky-rocko/meta-poky               5
meta-yocto-bsp        ~/sk-yocto/poky-rocko/meta-yocto-bsp          5
meta-oe               ~/sk-yocto/meta-openembedded/meta-oe          6
meta-python           ~/sk-yocto/meta-openembedded/meta-python      7
meta-networking       ~/sk-yocto/meta-openembedded/meta-networking  5
meta-raspberrypi      ~/sk-yocto/meta-raspberrypi                   9
meta-signalk          ~/sk-yocto/meta-signalk                       9
```

### Building

Now you are ready to build the image. You may first want to check that your machine has the essential packages for building installed. There are tons of yocto guides available. Start by checking [this](https://www.yoctoproject.org/docs/current/yocto-project-qs/yocto-project-qs.html). Note that bitbake uses python 2.7. Set that as default python, or use conda environment for python 2.7.

```
~/sk-yocto/build$ bitbake rpi-basic-image
```

As you noticed this is a basic minimal image for Raspberry Pi, but this command will only build an emulator image. It will take some time to build the image - it depends totally on your network bandwidth and local resources (cpu and disk speed).

### Check the result 

When everything is ready, start the image in emulator:

```
~/sk-yocto/build$ runqemu kvm
```

Now you should be able to access the SignalK Server from a browser in the host machine (the build machine) at address 192.168.7.2:3000.

 
