# meta-aos-rcar-demo2023

This is demo product. The aim of this product is to demonstrate Aos multi node capability. It produces images for two
Renesas R-Car device based nodes: R-Car-S4 device is the main node and one of R-Car Gen3 device is additional node.
Build for R-Car-S4 device is based on [meta-aos-rcar-gen4](https://github.com/aoscloud/meta-aos-rcar-gen4) while R-Car
Gen3 device is based on [meta-aos-rcar-gen3](https://github.com/aoscloud/meta-aos-rcar-gen3).

## Status

This is release 0.2.0. This release supports the following features:

* R-Car-S4 device:
    - dom0 with running unikernels as Aos services capability;
    - domd with running OCI containers as Aos services capability.
* R-Car Gen3 device:
    - dom0 with running unikernels as Aos services capability;
    - domd with running OCI containers as Aos services capability.
* FOTA is integrated and supported.

## Building

### Requirements

1. Ubuntu 18.0+ or any other Linux distribution which is supported by Poky/OE
2. Development packages for Yocto. Refer to [Yocto manual]
   (https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html#build-host-packages).
3. You need `Moulin` of version 0.11 or newer installed in your PC. Recommended way is to install it for your user only:
   `pip3 install --user git+https://github.com/xen-troops/moulin`. Make sure that your `PATH` environment variable
    includes `${HOME}/.local/bin`.
4. Ninja build system: `sudo apt install ninja-build` on Ubuntu

### Fetching

You can fetch/clone this whole repository, but you actually only need one file from it: `aos-rcar-demo2023.yaml`.
During the build `moulin` will fetch this repository again into `yocto/` directory. So, to reduce possible confuse,
we recommend to download only `aos-rcar-demo2023.yaml`:

```sh
# curl -O https://raw.githubusercontent.com/aoscloud/meta-aos-rcar-demo2023/main/aos-rcar-demo2023.yaml
```

### Building

Moulin is used to generate Ninja build file: `aos-rcar-demo2023.yaml`. This project provides number of additional
parameters. You can check them with `--help-config` command line option:

```sh
moulin aos-rcar-demo2023.yaml --help-config
usage: moulin aos-rcar-demo2023.yaml [--GEN3_DEVICE {enable,disable}]
                                                                        [--GEN3_MACHINE {h3ulcb-4x2g-ab,h3ulcb-4x2g,h3ulcb-4x2g-kf,m3ulcb,salvator-x-m3,salvator-xs-m3-2x4g,salvator-xs-h3,salvator-xs-h3-4x2g,salvator-x-h3-4x2g,salvator-x-h3}]
                                                                        [--VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}]

Config file description: Aos virtual development machine

options:
  --GEN3_DEVICE {enable,disable}
                        Add RCAR Gen3-based device as Aos nodes
  --GEN3_MACHINE {h3ulcb-4x2g-ab,h3ulcb-4x2g,h3ulcb-4x2g-kf,m3ulcb,salvator-x-m3,salvator-xs-m3-2x4g,salvator-xs-h3,salvator-xs-h3-4x2g,salvator-x-h3-4x2g,salvator-x-h3}
                        RCAR Gen3-based machine
  --VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}
                        Specifies plugin for VIS automotive data
```

By default builds for two devices will be performed. It is possible to build standalone product only for R-Car-S4
device by disabling build for R-Car Gen3 device: ` --GEN3_DEVICE=disable`.

Moulin will generate `build.ninja` file. After that run `ninja` to build the images. Issue the command
`ninja gen4_full.img` to generate full image for R-Car-S4 device and `ninja gen3_full.img` to generate full image for
R-Car Gen3 device.

### Deploying

To deploy the full image to R-Car-S4 device, see [meta-aos-rcar-gen4]
(https://github.com/aoscloud/meta-aos-rcar-gen4/blob/main/README.md).

To deploy the full image to R-Car Gen3 device, see [meta-aos-rcar-gen3]
(https://github.com/aoscloud/meta-aos-rcar-gen3/blob/main/README.md).