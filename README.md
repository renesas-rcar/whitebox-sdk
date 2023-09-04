# Purpose for demo branch

[Whitebox SDK]: https://github.com/renesas-rcar/whitebox-sdk
This branch is for sharing demonstration environment used [Whitebox SDK]

Currently, this branch is based on v4.0 on [Whitebox SDK].

# Tool setup

Please refer to following.

- https://github.com/renesas-rcar/whitebox-sdk/tree/v4.0#tool-setup

# build
Execute the following command:
```
git clone https://github.com/renesas-rcar/whitebox-sdk.git -b demo_v2 whitebox-sdk-demo
cd whitebox-sdk-demo
./build_all.sh spider|s4sk
```

You can check the generated image with the following command:
```
ls -l deploy
```

# Board connection example

```
                 +---------------------------+----------------------------+
                 | USB serial                |                            |
                 |                           v                            v
            +-----------+ Eth     TSN0 +-----------+ TSN1      eth0 +-------------+
Internet----| Host PC   |--------------| S4 Board  |----------------| H3SK(+CCPF) |
            +-----------+              +-----------+                +-------------+
                                                                      |micro  |USB
                                                                      |HDMI   |3.0
                                                                      |       |
                                                                    Display  USB Camera
```
# How to run demo

Under preparing.

# LICENSE

If there is a directory that contains file which notices about license infomatiom(such as LICENSE/COPYING/Readme and so on),
all files in that directory are licensed under its license.

And, if file has license infomation(such as spdx information, comment in header, and so on),
its license has priority to other license infomation(such as license of this repository, license file in the directory, and so on).

Except for the above,all files in this repository are licensed under the [MIT License](./COPYING.MIT).


Ex.) License priority:

FIle's license infomation > License notification in the directory > License of this repository

# Support

## FAQ

- En: https://en-support.renesas.com/knowledgeBase/category/31891/subcategory/31856
- Ja: https://ja-support.renesas.com/knowledgeBase/category/31892/subcategory/31857

## Community Q&A forum

- En: https://community.renesas.com/automotive/gateway/

