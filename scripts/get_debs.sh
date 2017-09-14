#! /bin/bash

# TODO: add more error checking for arguments
# TODO: update usage

OPTIND=1

# TODO: insert your IP and username for the host machine
IP=0
USERNAME=""

version=0
install=0
all=0
linux=0
optee=0
wifi=0
download=0

while getopts "h?dialowv:" opt; do
        case "$opt" in
        h|\?)
                echo "USAGE: ./get_debs.sh -v <version> [-i]"
                echo -e "\tWhere -i installs the debs as well."
                exit 0
                ;;
        d)
                download=1
                ;;
        v)
                version=$OPTARG
                ;;
        i)
                install=1
                ;;
        a)
                all=1
                ;;
        l)
                linux=1
                ;;
        o)
                optee=1
                ;;
        w)
                wifi=1
                ;;
        esac
done

if [[ ${all} -eq 1 ]] || [[ ${linux} -eq 1 ]]; then
    if [[ ${version} -eq 0 ]]; then
        echo "Must provide linux version number when using -l or -a."
		exit -1
    fi
fi

REMOTE_PATH= #TODO: insert the path where your code lives on the host machine

if [[ $download -eq 1 ]]; then
	download_path=""
	if [[ $optee -eq 1 ]] || [[ $all -eq 1 ]]; then
    	download_path="${REMOTE_PATH}/out/optee_2.5.0*.deb ${download_path}"
	fi

	if [[ $wifi -eq 1 ]] || [[ $all -eq 1 ]]; then
		download_path="${REMOTE_PATH}/out/firmware*.deb ${download_path}"
	fi

	if [[ $linux -eq 1 ]] || [[ $all -eq 1 ]]; then
		download_path="${REMOTE_PATH}/linux-image-*-rpb_*-rpb-${version}*.deb ${download_path}"
	fi

	echo -e "Downloading ${download_path}"
	scp $USERNAME@$IP:"${download_path}" .
fi

if [[ $install -eq 1 ]]; then
    echo "Installing packages..."
    if [[ $optee -eq 1 ]] || [[ $all -eq 1 ]]; then
        echo -e "\tOptee."
        dpkg --force-all -i optee_2.5.0-*.deb
    fi

    if [[ $wifi -eq 1 ]] || [[ $all -eq 1 ]]; then
        echo -e "\tWifi firmware."
        dpkg --force-all -i firmware-ti-connectivity_20161130-3_all.deb
    fi

    if [[ $linux -eq 1 ]] || [[ $all -eq 1 ]]; then
        echo -e "\tLinux."
        dpkg --force-all -i linux-image-*-rpb_*-rpb-${version}*.deb
    fi
	reboot
fi

