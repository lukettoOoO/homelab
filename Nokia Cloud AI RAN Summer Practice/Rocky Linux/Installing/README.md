[Official Docs](https://docs.rockylinux.org/guides/installation/?h=installing)

# Installing Rocky Linux 10

## Booting Using iLO Virtual Media

1. Download Rocky Linux 10 ISO from [Rocky Linux website](https://rockylinux.org/download/)
2. Verify the integrity of the downloaded ISO file
    * Download the file that contains the official checksums for the available ISOs.
    * While still in the folder that contains the downloaded Rocky Linux ISO, download the checksum file for the ISO
    * Use the `sha256sum` utility to verify the integrity of the ISO file against corruption or tampering
    ```bash
    sha256sum -c CHECKSUM --ignore-missing
    ```
3. Login to HPE iLO Web Interface, navigate to **Remote Console & Media** and click the **HTML5 Console** button.
4. In the HTML5 console, click the **Virtual Media** icon (up) and select **CD/DVD > Local *.iso file**, search the file with the Rocky Linux image on the local machine and click **Open**. Now the server views this file as an actual disk introduced in the DVD drive.
5. To force the server to boot off this ISO, go to **Administration > Boot Order** in the web interface menu, seciton **Select One-Time Boot Option**, click **CD/DVD Drive** (if in UEFI mode). Then in the HTML5 console, use the **Power** icon and select *Reset* or *Cold Boot* to restart the server. The system will now boot into the Rocky Linux 10 installer. (go to Rocky Linux Installation section)

## Booting Using USB Drive

1. Do steps *1.* and *2.* from previous section
2. Write ISO to a USB drive using [Rufus](https://rufus.ie/en/) (on Windows) or [BalenaEtcher](https://www.balena.io/etcher/) (on Windows, MacOS and Linux)
3. Login to HPE iLO Web Interface, navigate to **Remote Console & Media** and click the **HTML5 Console** button.
4. In the HTML5 console, click the **Power** icon and select *Reset* or *Cold Boot* to restart the server. 
5. As the server reboots, press the **F9** key repeatedly to enter the Boot Menu (*UEFI System Utilities*) or **F11** key and select the USB drive (*USB Storage Device*) from the list of bootable devices to start the installation. (go to Rocky Linux Installation section)

## Rocky Linux Installation

1. After booting, the Rocky Linux installer will start. Use the arrow keys to select *Test this media & Install Rocky Linux 10.0* to test for issues or just start the installation by selecting *Install Rocky Linux 10.0*.
2. Follow the official [ Rocky Linux 10 Installation Guide](https://docs.rockylinux.org/guides/installation/?h=installing) for the rest of the installation process, starting from **Installation Summary** section.
### Notes:
- Although the server is connected to the network through the *iLO port*, a separate port must be used for the OS network interface, connected to the same switch.
- An IP address has to be set for the OS network interface to enable remote access via *SSH*.
