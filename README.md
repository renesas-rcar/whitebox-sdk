# Setup
Execute the following command:

	sudo apt install git	
	git clone https://github.com/renesas-rcar/whitebox-sdk.git -b v2.x

# Tool setup
Since GUI operation is required during installation, it must be run on an Ubuntu PC.
Please obtain the compiler in advance; "CS+ for CC V8.09.00" is available from the following site.

https://www.renesas.com/us/en/software-tool/cs#download

Save the downloaded file (CSPlus_CC_Package_V80900-doc-e.zip) in the "tool" folder and execute the following command

	cd whitebox-sdk/tool
	cp <download directry>/CSPlus_CC_Package_V80900-doc-e.zip .
	./setup_whitebox.sh

# build
Execute the following command:

	cd whitebox-sdk
	./build_whitebox_v2.0.0.sh

#You can check the generated image with the following command:

	ls -l deploy

# LICENSE

If there is a directory that contains file which notices about license infomatiom(such as LICENSE/COPYING/Readme and so on),
all files in that directory are licensed under its license.

And, if file has license infomation(such as spdx information, comment in header, and so on),
its license has priority to other license infomation(such as license of this repository, license file in the directory, and so on).

Except for the above,all files in this repository are licensed under the [MIT License](./COPYING.MIT).


Ex.) License priority:

FIle's license infomation > License notification in the directory > License of this repository

