# Getting Started
This file describes how to pull the code, build it, and flash it to a hikey board.

## Prerequisites
To build and run TrustedCapsules, you must have certain packages installed and have a Hikey board available to you.
We use Ubuntu-based distributions to build the system, although this should not be a requirement.

### Required Components
TODO describe hikey board and monitor setup.

### Required Packages
Download the following packages:

```bash
sudo apt-get install android-tools-adb android-tools-fastboot autoconf \
    automake bc bison build-essential cscope curl device-tree-compiler flex \
    ftp-upload gdisk iasl libattr1-dev libc6:i386 libcap-dev libfdt-dev \
    libftdi-dev libglib2.0-dev libhidapi-dev libncurses5-dev \
    libpixman-1-dev libssl-dev libstdc++6:i386 libtool libz1:i386 make \
    mtools netcat python-crypto python-serial python-wand unzip uuid-dev \
    xdg-utils xterm xz-utils zlib1g-dev ccache
```

### Minicom setup

Change your minicom settings such that your ~/minirc.dfl looks like this:
```
pu port		/dev/ttyUSB0
pu rtscts	No
```

## Get the code
We have created a customized hikey manifest based on the OP-TEE manifest.

```bash
mkdir -p $HOME/trustedcapsules/code
cd $HOME/trustedcapsules/code
repo init -u https://github.com/TrustedCapsules/manifest.git -m hikey_debian_stable.xml
repo sync
```

TODO: document the changes necessary for capsule server (i.e. hardcoded IPs).

## Build toolchains
After getting the source code, you must get the `toolchains`. These are specific for different targets.

```bash
cd build
make toolchains
```

## Build source code
After building the toolchains, you need to build the source code. This will take a long time.

```bash
make
```

## Flash the Hikey board
To flash the Hikey board, follow the instructions in the make file after running:

```bash
make recovery
```

## Setting up the device
Now that the Hikey board has been flashed. You need to enable wifi and download some packages.
Copy over the scripts found [here](scripts/). You will need to enter your own wifi configuration
in [sample.conf](scripts/sample.conf). Once you have copied all three files (setup\_wifi.sh, get\_debs.sh,
and sample.conf), modify sample.conf to have your wifi network information (ssid, identity, password).

Next, you need to change the permissions on the shell files:
```bash
chmod 755 *.sh
```

Then, you need to modify the .bashrc file to connect to wifi by adding `./setup_wifi.sh` to the file.

Finally, run these commands to copy over the files from your computer and install them:
```bash
./get_debs.sh -diow # Downloads and installs the optee deb and wifi deb, this involves a reboot
./get_debs.sh -dil  # Downloads and installs the new linux version
```

## Testing installation
To test the installation there are two components to test, the OP-TEE side (xtest) and the TrustedCapsules
side (capsule\_test).

First, initialize the trusted execution environment.
```bash
modprobe optee # Should not be necessary, but is...
tee-supplicant &
```

### OP-TEE regression tests
To run OP-TEE created regression tests, run this command after initializing the environment.

```bash
xtest
```

Your output should look (something) like this:
```bash
+-----------------------------------------------------
23476 subtests of which 0 failed
67 test cases of which 0 failed
0 test case was skipped
TEE test application done!
```


### Testing Trusted Capsules
There are four tests you must run to ensure the trusted capsules system is working correctly:

- capsule_test: tests the trusted application calls
- capsule_test_network: tests the network primitives for communicating with the secure server
- capsule_test_policy: tests the different policy functions
- application testing: this is a workflow to test the different applications to ensure they are working

#### Trusted Application test
```bash
capsule_test REGISTER_KEYS # If this fails because of an ACCESS_CONFLICT error, just retry
capsule_test FULL
```

#### Networking test
This should be run after you have run `capsule_test REGISTER_KEYS`. On your host machine (where you build the code), go to `optee_app/capsule_server`. You will need to run `capsule_server` with specific commands based on what capsule\_test\_network you are running.

To test the general communication:
```bash
# On host machine
capsule_server 3490 ECHO_SIMPLE
# On hikey board
capsule_test_network ECHO
```
To test the encrypted communication:
```bash
# On host machine
capsule_server 3490 ECHO_ENC_SER
# On hikey board
capsule_test_network ECHO_ENCRYPT_SERIALIZE
```

#### Policy test
To test the policy functions, you will still need to use the capsule_server.
```bash
# On host machine
capsule_server 3490 CAPSULE
# On hikey board
capsule_test_policy
```
#### Application tests
TODO describe how to test applications.
