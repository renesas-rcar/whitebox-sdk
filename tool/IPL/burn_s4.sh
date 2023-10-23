#!/bin/bash

# Serial port: e.g. /dev/ttyUSB0
USB_PORT=/dev/ttyUSB0
WORK_BASE=`pwd`
IPL_PATH=${WORK_BASE}
MOT_PATH=${WORK_BASE}

BURN_PATTERN=-1
WRITE_PATTERN=all

# Burn patterns: G4MH, CR52
BURN_PATTERNS=( "dummy" "dummy" # -0(dummy)
    "Trampoline" "Trampoline"  # -1
    "SafeG-Auto" "Trampoline"  # -2
    "Trampoline" "Zephyr"      # -3
    "SafeG-Auto" "Zephyr"      # -4
)
BURN_PATTERS_NUM=$((${#BURN_PATTERNS[@]} / 2  -1))

Usage() {
    echo "Usage:"
    echo "    $0 board [option] [option2]"
    echo "board:"
    echo "    - spider: for S4 Spider"
    echo "    - s4sk: for S4 Starter Kit"
    echo "option:"
    for key in `seq 1 ${BURN_PATTERS_NUM}`; do
        echo -ne "    -${key}: "
        echo -ne "G4MH=${BURN_PATTERNS[$((2*$key+0))]}\t"
        echo -e "CR52=${BURN_PATTERNS[$((2*$key+1))]}"
    done
    echo "    -h: Show this usage"

    echo "option2:"
    echo "    all: All writes (default)"
    echo "    g4mh: Only g4mh writes"
    echo "    cr52: Only cr52 writes"
}

if [[ $# < 1 ]] ; then
    echo -e "\e[31mERROR: Please select a board\e[m"
    Usage; exit
fi

if [[ "$1" == "-h" ]]; then
    Usage; exit
elif [[ "$1" != "spider" ]] && [[ "$1" != "s4sk" ]]; then
    echo -e "\e[31mERROR: Please "input" correct board name: spider or s4sk\e[m"
    Usage; exit
fi

# Without option, pattern 1 is selected by default.
if [[ $# < 3 ]]; then
    if [[ $# < 2 ]]; then
        $0 $1 -1 all
        exit
    fi
    if [[ "$2" == "all" ]] || [[ "$2" == "g4mh" ]] || [[ "$2" == "cr52" ]]; then
        $0 $1 -1 $2
        exit
    elif  [[ "$2" == "-1" ]] || [[ "$2" == "-2" ]] || [[ "$2" == "-3" ]] || [[ "$2" == "-4" ]]; then
        $0 $1 $2 all
        exit
    else
        echo -e "\e[31mERROR: Unsupported option\e[m"
	Usage; exit
    fi
elif [[ $# > 3 ]]; then # option can be used only one
    Usage; exit
fi

# Proc arguments
OPTIND=2
while getopts "1234h" OPT
do
  case $OPT in
     [0-9]) BURN_PATTERN=$OPT;;
     h) Usage; exit;;
     *) echo -e "\e[31mERROR: Unsupported option\e[m"; Usage; exit;;
  esac
done
G4MH=${BURN_PATTERNS[$((2*${BURN_PATTERN}+0))]}
CR52=${BURN_PATTERNS[$((2*${BURN_PATTERN}+1))]}

if [[ "$3" == "all" ]]; then
    WRITE_PATTERN=all
elif [[ "$3" == "g4mh" ]]; then
    WRITE_PATTERN=g4mh
elif [[ "$3" == "cr52" ]]; then
    WRITE_PATTERN=rtos
else
    echo -e "\e[31mERROR: Unsupported option\e[m"
    Usage; exit
fi

if [ ! -d "deploy" ]; then
  echo -e "\e[31mERROR: Please copy the built deploy directory\e[m"
  exit
fi

cp deploy/*.srec .
case $G4MH in
    "Trampoline") cp deploy/g4mh_trampoline_deploy/g4mh.srec App_CDD_ICCOM_S4_Sample_G4MH.srec;;
    "SafeG-Auto") cp deploy/g4mh_safegauto_deploy/g4mh.srec App_CDD_ICCOM_S4_Sample_G4MH.srec;;
esac
case $CR52 in
    "Trampoline") cp deploy/cr52_trampoline_deploy/cr52.srec App_CDD_ICCOM_S4_Sample_CR52.srec;;
    "Zephyr")     cp deploy/cr52_zephyr_deploy/cr52.srec App_CDD_ICCOM_S4_Sample_CR52.srec;;
esac

# Changed CR52 memory placement to 0x40040000
sed -i 's/S315EB23695000000000000010E2000000000000000031/S315EB23695000000000000004400000000000000000DF/g' cert_header_sa9.srec

# Flash IPL
python3 ipl_burning.py $1 $USB_PORT $MOT_PATH $IPL_PATH $WRITE_PATTERN
