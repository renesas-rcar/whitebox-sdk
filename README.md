# What is Whitebox SDK?

Please refer to the official webpage:

- https://www.renesas.com/software-tool/r-car-s4-whitebox-sdk-integrated-development-platform-connected-services-and-gateway-application

# Setup
Execute the following command:

	sudo apt install git	
	git clone https://github.com/renesas-rcar/whitebox-sdk.git -b v3.x

# Tool setup
Since GUI operation is required during installation, it must be run on an Ubuntu PC.
Please obtain the compiler in advance; "RH850 Compiler CC-RH V2.05.00 for e2 studio" is available from the following site.

https://www.renesas.com/us/en/software-tool/c-compiler-package-rh850-family#download

Save the downloaded file (CC-RH_V20500_setup-doc.zip) in the "tool" folder and execute the following command

	cd whitebox-sdk/tool
	cp <download directry>/CC-RH_V20500_setup-doc.zip .
	./setup_whitebox.sh

# build
Execute the following command:

	cd whitebox-sdk
	./build_whitebox_v3.1.sh

#You can check the generated image with the following command:

	ls -l deploy

# LICENSE

If there is a directory that contains file which notices about license information(such as LICENSE/COPYING/Readme and so on),
all files in that directory are licensed under its license.

And, if file has license information(such as spdx information, comment in header, and so on),
its license has priority to other license information(such as license of this repository, license file in the directory, and so on).

Except for the above, all files in this repository are licensed under the [MIT License](./COPYING.MIT).


Ex.) License priority:

File's license information > License notification in the directory > License of this repository

# Support

## FAQ

- En: https://en-support.renesas.com/knowledgeBase/category/31891/subcategory/31856
- Ja: https://ja-support.renesas.com/knowledgeBase/category/31892/subcategory/31857

## Community Q&A forum

- En: https://community.renesas.com/automotive/gateway/

