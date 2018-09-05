#!/bin/bash

# change the /etc/apt/sources.list

# History:
# 01/10/2015, create
# 09/2017, update source list and re-write some codes

# name of currently installed distribution
dist_name=`lsb_release -c | sed s/'Codename:\t'//g`

# FLAG for apt-get update #################################
FLAG_APT=-y

# directory of sources.list ###############################
source_dir=/etc/apt
tmp_dir=/tmp
tmp_srl=$tmp_dir/sources.list.tmp

# source lists
declare -A srcs
declare -A descripts
declare -a names_src

num_srcs=0

## function used to add new source
function add_src
{
    local name=$1
    local url=$2
    local desc=$3 # descriptions. empty string if only 2 parameters
    names_src[$num_srcs]=$name
    srcs[$name]=$url
    descripts[$name]=$desc
    ((num_srcs++))
}

add_src ubuntu_cn 'http://cn.archive.ubuntu.com/ubuntu/'\
                  'ubuntu official source, in China'
add_src ubuntu_tw 'http://tw.archive.ubuntu.com/ubuntu'\
                  'ubuntu official source, in Taiwan'
add_src ubuntu_eu 'http://archive.ubuntu.com/ubuntu/'\
                  'ubuntu official source, in Europe'
add_src qh 'http://mirrors.tuna.tsinghua.edu.cn/ubuntu/'\
           'Tsinghua'
add_src qh_v4 'http://mirrors.4.tuna.tsinghua.edu.cn/ubuntu/'\
              'Tsinghua, ipv4'
add_src qh_v6 'http://mirrors.6.tuna.tsinghua.edu.cn/ubuntu/'\
              'Tsinghua, ipv6'
add_src cas 'http://mirrors.opencas.cn/ubuntu/'\
            'Chinese Academy of Sciences'
add_src ustc 'https://mirrors.ustc.edu.cn/ubuntu/'\
             'University of Science and Technology of China, LUG'
add_src bit 'http://mirror.bit.edu.cn/'\
            'Beijing Institute of Technology'
add_src cuhk 'http://ftp.cuhk.edu.hk/pub/Linux/ubuntu'\
             'The Chinese University of Hong Kong'
add_src zju 'http://mirrors.zju.edu.cn/ubuntu/'\
            'Zhe Jiang University'
add_src hust 'http://mirrors.hust.edu.cn/ubuntu/'\
             'Huazhong University of Science and Technology'
add_src hust_uniq 'http://mirrors.hustunique.com/ubuntu/'\
                  'Qiming College of HUST'
add_src jlu 'http://mirrors.jlu.edu.cn/ubuntu/'\
            'Ji Lin University'

# some functions used to produce source list
function print_srl
{
    local url=$1
    local dist=$2
    for hd in 'deb' 'deb-src'
    do
        echo "$hd $url $dist main restricted universe multiverse"
        for d in security updates backports proposed
        do
            echo "$hd $url ${dist}-$d main restricted universe multiverse"
        done
    done
}

function print_srlof
{
    local srl_name=$1

    local url=${srcs[$srl_name]}

    if [ x"$url" == x ]
    then
        echo "No Source list: $srl_name"
        echo "use option --list or --help to print all valid sources lists"
        exit -1
    fi

    print_srl $url $dist_name
}

# list all valid list_name ################################

isappend=0
isupdate=1

while (( $# > 0)) && [ ${1:0:1} = '-' ]; do
	if [ $1 = '--list' ] || [ $1 = '-l' ] ; then
		echo
		echo "## valid sources list name ##"
		echo

        for i in ${names_src[@]}; do echo -n $i ' '; done

		echo
		
		echo
		echo "#############################"
		echo
		
		exit 0
	elif [ $1 = '--help' ] || [ $1 = '-h' ] ; then
	
		echo 'Usage: chsrl [OPTION]... [SOURCES-LIST]...'
		echo
		echo 'OPTIONs must be before SOURCES-LIST if SOURCES-LIST exit'
		echo
		echo 'SOURCES-LIST can have mostly two arguments, and the script will combine them with _ to get real SOURCES-LIST, e.g. chsrl qh v6 means chsrl qh_v6'
		echo
		echo 'Options:'
		echo '-h, --help'
		echo '-l, --list        just list all valid sources lists'
		echo '-a, --append      not overwrite /etc/apt/sources.list'
		echo '-n, --no-update   just rewrite sources.list and no update'
		echo '-u, --update      just update without re-write the file'
		echo
		echo "Valid SOURCES-LISTs:"
		
		for i in ${names_src[@]}; do
            echo '    '$i':' ${descripts[$i]}
        done
		
		exit 0
	elif [ $1 = '--append' ] || [ $1 = '-a' ] ; then
	
		isappend=1
		shift
	elif [ $1 = '--no-update' ] || [ $1 = '-n' ]; then
		isupdate=0
		shift
	elif [ $1 = '--update' ] || [ $1 = '-u' ]; then
		sudo apt-get $FLAG_APT update
		exit
	else
		echo "Invalid option: $1"
		echo 'Valid options: --list  -l'
		echo '               --help  -h'
		echo '               --append  -a'
		echo '               --no-update  -n'
		echo '               --update  -u'
		exit -1
	fi
		
done

# choose source ###########################################

if [ $# = 0 ] ; then
	srl_name=qh
elif [ $# = 1 ]; then
	srl_name=$1
elif [ $# = 2 ]; then
	srl_name=$1_$2
fi

# update /etc/apt/sources.list ############################

print_srlof $srl_name > $tmp_srl

if [ $isappend = 1 ]; then
	cat $source_dir/sources.list >> $tmp_srl
fi

sudo mv -f $tmp_srl $source_dir/sources.list

if [ $isupdate = 1 ]; then
	sudo apt-get $FLAG_APT update
elif [ $isupdate = 0 ]; then
	echo "No update sources"
	echo "Now sources include:"
	echo -e "\033[7m"
	cat $source_dir/sources.list
	echo -e "\033[0m"
fi
