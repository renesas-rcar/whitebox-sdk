#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# import section
import os
import sys
import shutil
import subprocess
import serial.tools.list_ports # pyserial
import colorama

# Global variables
WORK_DIR = os.path.dirname(os.path.abspath(__file__))
IPL_PATH=f"{WORK_DIR}"
MOT_PATH=f"{WORK_DIR}"

CR52_NAME="App_CDD_ICCOM_S4_Sample_CR52.srec"
G4MH_NAME="App_CDD_ICCOM_S4_Sample_G4MH.srec"
G4MH_DIR = {
        "Trampoline": "g4mh_trampoline_deploy",
        "SafeG-Auto": "g4mh_safegauto_deploy",
}
CR52_DIR = {
        "Trampoline": "cr52_trampoline_deploy",
        "Zephyr":     "cr52_zephyr_deploy",
}
CHECK_FILE=f"{G4MH_DIR['Trampoline']}/g4mh_can_disable.srec"

burn_patterns=[
    # [ G4MH, CR52 ]
    ["dummy", "dummy"],           # -0(dummy)
    ["Trampoline", "Trampoline"], # -1
    ["SafeG-Auto", "Trampoline"], # -2
    ["Trampoline", "Zephyr"],     # -3
    ["SafeG-Auto", "Zephyr"],     # -4
]

# Functions

def print_err(str):
    colorama.init()
    print(f'{colorama.Fore.RED}{str}{colorama.Style.RESET_ALL}')

def Usage():
    print(f"Usage:")
    print(f"    {sys.argv[0]} board comport [option] [option2] [s4sk option]")
    print(f"board:")
    print(f"    - spider: for S4 Spider")
    print(f"    - s4sk: for S4 Starter Kit")
    print(f"comport:")
    for comport in serial.tools.list_ports.comports():
        print(f"    {comport}")
    print(f"option:")
    for i in range(1, len(burn_patterns)):
        print(f"    -{i}", end="")
        print(f" G4MH={burn_patterns[i][0]}\t", end="")
        print(f" CR52={burn_patterns[i][1]}", end="")
        if i == 1: print(f" (default)", end="")
        print(f"")
    print(f"    -h: Show this usage:")
    print(f"option2:")
    print(f"    all:  Write loader and G4MH/CR52 OS specified by option (default)")
    print(f"    g4mh: Write only G4MH OS specified by option")
    print(f"    cr52: Write only CR52 OS specified by option")
    print(f"s4sk option:")
    print(f"    -g: Enable CAN on G4MH core")
    print(f"    -r: Enable CAN on CR52 core (default)")

def prepare_flash_loader(board="dummy",g4mhos="dummy", cr52os="dummy", use_can="dummy"):
    if board == "spider":
        shutil.copy(f"{G4MH_DIR[g4mhos]}/g4mh.srec", G4MH_NAME)
        shutil.copy(f"{CR52_DIR[cr52os]}/cr52.srec", CR52_NAME)

    elif board == "s4sk":
        if g4mhos == "Trampoline" and cr52os == "Trampoline":
            if use_can == "cr52" or g4mhos != "Trampoline":
                shutil.copy(f"{G4MH_DIR[g4mhos]}/g4mh_can_disable.srec", G4MH_NAME)
                shutil.copy(f"{CR52_DIR[cr52os]}/cr52.srec", CR52_NAME)
            elif use_can == "g4mh" or cr52os != "Trampoline":
                shutil.copy(f"{G4MH_DIR[g4mhos]}/g4mh.srec", G4MH_NAME)
                shutil.copy(f"{CR52_DIR[cr52os]}/cr52_can_disable.srec", CR52_NAME)
        else:
            shutil.copy(f"{G4MH_DIR[g4mhos]}/g4mh.srec", G4MH_NAME)
            shutil.copy(f"{CR52_DIR[cr52os]}/cr52.srec", CR52_NAME)


def main():
    BOARD = ""
    COM_PORT = "/dev/ttyUSBXX or COMXX"
    BURN_MODE = "all"
    G4MHOS = burn_patterns[1][0]
    CR52OS = burn_patterns[1][1]
    USE_CAN = "cr52"
    DRY_RUN = False # if True, test only this file(contains file copy process)

    args = sys.argv
    if "-h" in args:
        Usage(); quit()

    if len(args) <= 1:
        print_err(f"ERROR: Please select a board")
        Usage(); quit()
    elif args[1] != "spider" and args[1] != "s4sk":
        print_err(f"ERROR: Please \"input\" correct board name: spider or s4sk")
        Usage(); quit()
    BOARD=args[1]

    if len(args) <= 2:
        print_err(f"ERROR: Please input a comport")
        Usage(); quit()
    elif args[2] not in [comport.device for comport in serial.tools.list_ports.comports()]:
        print_err(f"ERROR: Please \"input\" correct comport:")
        Usage(); quit()
    COM_PORT=args[2]

    if BOARD == "s4sk":
        if os.path.isfile(CHECK_FILE) is False:
            print_err(f"ERROR: Is the board selected correct?")
            Usage(); quit()

    for arg in args[3:]:
        if arg in ["all", "g4mh", "cr52"]:
            burn_mode = arg
        elif arg in ["-1", "-2", "-3", "-4"]:
            G4MHOS = burn_patterns[abs(int(arg))][0]
            CR52OS = burn_patterns[abs(int(arg))][1]
        elif arg in ["-g", "-r"]:
            if arg == "-g":   USE_CAN="g4mh"
            elif arg == "-r": USE_CAN="cr52"
        elif arg in ["--dry-run"]:
            DRY_RUN=True

    prepare_flash_loader(BOARD, G4MHOS, CR52OS, USE_CAN)

    cmd = ["python3", "ipl_burning.py" ,BOARD, COM_PORT, MOT_PATH, IPL_PATH, BURN_MODE]
    if DRY_RUN is False:
        subprocess.run(cmd)

if __name__ == "__main__":
    main()

