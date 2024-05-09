#!/bin/bash

# Serial port: e.g. /dev/ttyUSB0
USB_PORT=/dev/ttyUSB0

WORK_BASE=`pwd`
IPL_PATH=${WORK_BASE}
MOT_PATH=${WORK_BASE}

CR52_NAME="App_CDD_ICCOM_S4_Sample_CR52.srec"
G4MH_NAME="App_CDD_ICCOM_S4_Sample_G4MH.srec"
G4MH_TP_DIR="g4mh_trampoline_deploy"
G4MH_SA_DIR="g4mh_safegauto_deploy"
CR52_TP_DIR="cr52_trampoline_deploy"
CR52_ZP_DIR="cr52_zephyr_deploy"

CHECK_FILE="${G4MH_TP_DIR}/g4mh_can_disable.srec"

BURN_PATTERN=1
WRITE_FLAG_G4MH=0
WRITE_FLAG_CR52=0
WRITE_FLAG_ALL=0
SELECT_CAN=0
WRITE_PATTERN=""

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
    echo "    $0 board [option] [option2] [s4sk option]"
    echo "board:"
    echo "    - spider: for S4 Spider"
    echo "    - s4sk: for S4 Starter Kit"
    echo "option:"
    for key in `seq 1 ${BURN_PATTERS_NUM}`; do
        echo -ne "    -${key}: "
        echo -ne "G4MH=${BURN_PATTERNS[$((2*$key+0))]}\t"
        echo -ne "CR52=${BURN_PATTERNS[$((2*$key+1))]}"
        if [[ $key -eq 1 ]]; then echo -ne " (default)"; fi
        echo -e ""
    done
    echo "    -h: Show this usage"
    echo "option2:"
    echo "    all:  Write loader and G4MH/CR52 OS specified by option (default)"
    echo "    g4mh: Write only G4MH OS specified by option"
    echo "    cr52: Write only CR52 OS specified by option"
    echo "s4sk option:"
    echo "    -g: Enable CAN on G4MH core"
    echo "    -r: Enable CAN on CR52 core (default)"
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
BOARD_TYPE=$1

if [[ $BOARD_TYPE = "s4sk" ]]; then
    if [ ! -e "$CHECK_FILE" ]; then
        echo -e "\e[31mERROR: Is the board selected correct?\e[m"
        exit
    fi
fi

count=$#
for i in `seq 2 $count`
do
    param="${@:i:1}"
    if [[ "$param" == "all" ]] || [[ "$param" == "g4mh" ]] || [[ "$param" == "cr52" ]]; then
        if  [[ "$param" == "g4mh" ]]; then
            WRITE_FLAG_G4MH=1
        elif  [[ "$param" == "cr52" ]]; then
            WRITE_FLAG_CR52=1
        else
            WRITE_FLAG_ALL=1
        fi
    elif  [[ "$param" == "-1" ]] || [[ "$param" == "-2" ]] || [[ "$param" == "-3" ]] || [[ "$param" == "-4" ]]; then
        BURN_PATTERN=$(echo "$param" | sed 's/[^0-9]*//')
    elif  [[ "$param" == "-r" ]] || [[ "$param" == "-g" ]]; then
        if [[ "$param" == "-g" ]]; then
            SELECT_CAN=1;
        else
            SELECT_CAN=0;
        fi
    else
        echo -e "\e[31mERROR: Unsupported option\e[m"
	    Usage; exit
    fi
done

G4MH=${BURN_PATTERNS[$((2*${BURN_PATTERN}+0))]}
CR52=${BURN_PATTERNS[$((2*${BURN_PATTERN}+1))]}

if [[ "$BOARD_TYPE" = "spider" ]]; then
    case $G4MH in
        "Trampoline") cp ${G4MH_TP_DIR}/g4mh.srec $G4MH_NAME;;
        "SafeG-Auto") cp ${G4MH_SA_DIR}/g4mh.srec $G4MH_NAME;;
    esac
    case $CR52 in
        "Trampoline") cp ${CR52_TP_DIR}/cr52.srec $CR52_NAME;;
        "Zephyr")     cp ${CR52_ZP_DIR}/cr52.srec $CR52_NAME;;
    esac
else
    case $G4MH in
        "Trampoline") 
            if [ "$BURN_PATTERN" -eq 3 ] || [ "$SELECT_CAN" -eq 1 ]; then
                cp ${G4MH_TP_DIR}/g4mh.srec $G4MH_NAME
            else
                cp ${G4MH_TP_DIR}/g4mh_can_disable.srec $G4MH_NAME
            fi
            ;;
        "SafeG-Auto") cp ${G4MH_SA_DIR}/g4mh.srec $G4MH_NAME;;
    esac
    case $CR52 in
        "Trampoline")
            if [ "$BURN_PATTERN" -eq 2 ] || [ "$SELECT_CAN" -eq 0 ]; then
                cp ${CR52_TP_DIR}/cr52.srec $CR52_NAME
            else
                cp ${CR52_TP_DIR}/cr52_can_disable.srec $CR52_NAME
            fi
            ;;
        "Zephyr")     cp ${CR52_ZP_DIR}/cr52.srec $CR52_NAME;;
    esac
fi


WRITE_FLAG=$((WRITE_FLAG_G4MH+WRITE_FLAG_CR52+WRITE_FLAG_ALL))
if [ "$WRITE_FLAG" -eq 0 ] || [ "$WRITE_FLAG_ALL" -eq 1 ]; then
    WRITE_PATTERN="all"
else
    if [ "$WRITE_FLAG_G4MH" -eq 1 ]; then
        WRITE_PATTERN="$WRITE_PATTERN g4mh"
    fi
    if [ "$WRITE_FLAG_CR52" -eq 1 ]; then
        WRITE_PATTERN="$WRITE_PATTERN rtos"
    fi
fi

# Flash IPL
python3 ipl_burning.py $1 $USB_PORT $MOT_PATH $IPL_PATH $WRITE_PATTERN

