#! /bin/bash
# longbin <beangr@163.com>
# 2014-06-24
# 2015-02-06
# this script is available for ubuntu to configure embedded environment

## get system distributor ID: Ubuntu ?
UBUNTU_DISTRIBUT=$(lsb_release -i |\
		tr 'A-Z' 'a-z'| \
		awk '/distributor/ {print $3}' )

## get system release: Ubuntu ?
UBUNTU_RELEASE=$(lsb_release -r |\
		tr 'A-Z' 'a-z'| \
		awk '/release/ {print $2}')

#list the software need to be installed to the variable FILELIST
BASIC_TOOLS="vim vim-gnome vim-doc vim-scripts ctags cscope gawk curl rar unrar zip unzip ghex nautilus-open-terminal p7zip-full tree uml-utilities meld gimp dos2unix unix2dos tofrodos python-markdown subversion "

CODE_TOOLS="build-essential git-core libtool cmake automake cvs cvsd flex bison gperf graphviz gnupg mingw32 gettext libc6-dev libc++-dev lib32stdc++6 libncurses5-dev lib32bz2-1.0 lib32bz2-dev gcc g++ g++-multilib "

EMBED_TOOLS="ckermit putty tftp-hpa tftpd-hpa uml-utilities nfs-kernel-server "

BUILD_ANDROID_U12="git gnupg flex bison gperf python-markdown build-essential zip curl ia32-libs libc6-dev libncurses5-dev:i386 xsltproc x11proto-core-dev libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-dev g++-multilib mingw32 tofrodos libxml2-utils zlib1g-dev:i386 "
#libgl1-mesa-dri:i386 libgl1-mesa-glx:i386

BUILD_ANDROID_U14_ESSENTIAL="git gperf python-markdown g++-multilib libxml2-utils "

BUILD_ANDROID_U14_TOOLS="git-core flex bison gperf gnupg build-essential zip curl zlib1g-dev libc6-dev lib32ncurses5-dev lib32z1 x11proto-core-dev libx11-dev libreadline-gplv2-dev lib32z-dev libgl1-mesa-dev g++-multilib mingw32 tofrodos python-markdown libxml2-utils xsltproc libxml-simple-perl"

AI_TOOLS="build-dep python python-numpy python-scipy matplotlib"
WISTRON_TOOLS="ntlmaps"
#apt-cache search opencv
# OPEN_CV="$(apt-cache search opencv | awk '{print $1}')"
# OPEN_CV="libgtk2.0-dev pkg-config"
##g++ `pkg-config opencv --cflags --libs` my_example.cpp -o my_example


## ubuntu 12.04 software installing list
U1204_FILELIST="${BASIC_TOOLS} ${CODE_TOOLS} ${EMBED_TOOLS} \
				${BUILD_ANDROID_U12}"
## ubuntu 14.04 software installing list
U1404_FILELIST="${BASIC_TOOLS} ${CODE_TOOLS} ${EMBED_TOOLS} \
				${BUILD_ANDROID_U14_ESSENTIAL} \
				${BUILD_ANDROID_U14_TOOLS}"

INSTALL_CHECK_FLAG="y"

## update and upgrade system
function update_upgrade_ubuntu(){
	read -p "update source.list <y/n>? " select
	if [[ "${select}" == "y" ]] ;then
		echo "sudo apt-get update"
		#update the source.list
		sudo apt-get update
	fi

	read -p "upgrade system <y/n>? " select
	if [[ "${select}" == "y" ]] ;then
		echo "sudo apt-get upgrade"
		#upgrade the software have installed on the system
		sudo apt-get upgrade
	fi
}

## check whether system is Ubuntu or not
function check_ubuntu_distributor(){
	echo "checking distributor and release ID ..."
	if [[ "${UBUNTU_DISTRIBUT}" == "ubuntu" ]] ;then
		echo -e "\tCurrent OS: ${UBUNTU_DISTRIBUT}"
	else
		echo -e "\tCurrent OS is not ubuntu"
		echo -e "\tCurrent OS: ${UBUNTU_DISTRIBUT}"
		exit 1
	fi
}

## check whether system is Ubuntu 12.04 or 14.04
function check_ubuntu_release(){
	case ${UBUNTU_RELEASE} in
		12.04)
			echo -e "\tCurrent OS: 12.04"
			FILELIST=${U1204_FILELIST}
			;;
		14.04)
			echo -e "\tCurrent OS: 14.04"
			FILELIST=${U1404_FILELIST}
			;;
		?)
			echo "Only support Ubuntu LTS version, eg: 12.04/14.04"
			exit 1
			;;
	esac
	echo "checked OK, preparing to setup softwares ..."
	sleep 2
}

#install one software every cycle
function install_soft_for_each(){
	echo "Will install below software for your system:"
	# FILELIST=$(echo ${FILELIST} | sed 's/[\t ]/\n/g'| sort -u)
	for file in ${FILELIST}
	do
		trap 'echo -e "\ninterrupted by user, exit";exit' INT
		echo "========================="
		echo "installing $file ..."
		echo "-------------------------"
		if [[ "${INSTALL_CHECK_FLAG}" == "y" ]] ;then
			sudo apt-get install $file -y
		else
			sudo apt-get install $file
		fi
		# sleep 1
		echo "$file installed ."
	done
}
#bison and flex is the analyzer of programmer and spell
#textinfo is a tool to read manual like man
#automake is used to help create Makefile
#libtool helps to deal with the dependency of libraries
#cvs, cvsd and subversion are used to control version

function create_link_mesa_libGL_so(){
	LIB_GL_SO=/usr/lib/i386-linux-gnu/libGL.so
	if ! [[ -f "${LIB_GL_SO}.1" ]] ;then
		return
	fi
	sudo ln -s -f ${LIB_GL_SO}.1 ${LIB_GL_SO}
}

## install ibus input method frame
function install_ibus_pinyin_for_ubuntu(){
	read -p "press <ENTER> to install and setup ibus-pinyin"
	sudo apt-get install ibus ibus-clutter ibus-gtk ibus-gtk3 ibus-qt4 -y
	## install ibus pinyin
	sudo apt-get install ibus-pinyin -y

	## restart ibus-pinyin
	##try below command to repair ibus-pinyin:
	#ibus-daemon -drx
	ibus-daemon -drx

	## configure ibus pinyin
	if [[ "${UBUNTU_RELEASE}" == "12.04" ]] ;then
		/usr/lib/ibus-pinyin/ibus-setup-pinyin
	elif [[ "${UBUNTU_RELEASE}" == "14.04" ]] ;then
		/usr/lib/ibus/ibus-setup-pinyin
	fi
}

function install_fcitx_pinyin_for_ubuntu(){
	## remove ibus-pinyin will lead some problems, repair our OS by below command:
	## sudo apt-get install ibus-pinyin unity-control-center \
	## unity-control-center-signon webaccounts-extension-common xul-ext-webaccounts
	
	## remove ibus and install fcitx pinyin
	read -p "Press <ENTER> to remove ibus "
	sudo apt-get purge ibus
	sudo apt-get autoremove
	## repair OS when removed ibus pinyin 
	sudo apt-get install unity-control-center unity-control-center-signon webaccounts-extension-common xul-ext-webaccounts

	## install fcitx pinyin
	echo "installing fcitx ..."
	sudo apt-get install fcitx fcitx-pinyin
	read -p "Press <ENTER> to select your input method [fcitx] "
	im-config
	read -p "Press <ENTER> to add your input method [pinyin] "
	fcitx-config-gtk3

	echo "====================================================="
	echo -e "\tSetup fcitx imput method OK, please re-login your system to use it. "
	echo "====================================================="
}

function install_ibus_or_fcitx_pinyin(){
	PS3="Please select your input method: "
	select ime in "ibus-pinyin" "fcitx-pinyin"
	do
		case ${REPLY} in
		1)
			install_ibus_pinyin_for_ubuntu
			;;
		2)
			install_fcitx_pinyin_for_ubuntu
			;;
		?)
			echo "select NONE, do nothing"
			;;
		esac

		break
	done
}

function install_ubuntu_multimedia_extras(){
	read -p "Install multimedia libs <y/n>? " select
	if [[ "$select" == "y" ]] ;then
		echo "This will take you a long time to download."
		sudo apt-get install ubuntu-restricted-extras
	else
		return
	fi
}

read -p "Setup build environment for ubuntu 12.04/14.04, press <ENTER> to continue "

check_ubuntu_distributor
check_ubuntu_release
update_upgrade_ubuntu
install_soft_for_each
create_link_mesa_libGL_so
install_ibus_or_fcitx_pinyin
install_ubuntu_multimedia_extras

echo "setup succeeded, congratulations !"

