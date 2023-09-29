#!/usr/bin/env python3

#
# Copyright (c) 2023, Renesas Electronics Corporation. All rights reserved.
#
# SPDX-License-Identifier: MIT
#


####################################################################################################
# Import from standard libraries
####################################################################################################
import serial
import sys
import time
import os
import json
from serial.tools.list_ports import comports


####################################################################################################
# Print debug data
####################################################################################################
def print_debug(type_mesg, data):
    if sys.platform == "win32":
        if type_mesg == "ERROR":
            PREFIX = "[ERROR]"
        elif type_mesg == "WARNING":
            PREFIX = "[WARNING]"
        elif type_mesg == "INFO":
            PREFIX = "[INFO]"
    else:
        if type_mesg == "ERROR":
            PREFIX = "[\033[01;31mERROR\033[01;0m]"
        elif type_mesg == "WARNING":
            PREFIX = "[\033[01;33mWARNING\033[01;0m]"
        elif type_mesg == "INFO":
            PREFIX = "[\033[01;34mINFO\033[01;0m]"
    print("%s %s" % (PREFIX, data))


class Serial_conn(serial.Serial):
    """
    Serial connection class
    """
    # send a command line
    def sendln(self, cmd_to_send=""):
        str_send = cmd_to_send + "\r"
        return self.write(str_send.encode())

    # send a string
    def send(self, cmd_to_send=""):
        str_send = cmd_to_send
        return self.write(str_send.encode())

    # send a file
    def sendfile(self, file_path):
        print_debug("INFO", "Sending file %s" % file_path)
        return self.write(open(file_path, "rb").read())

    # wait a line by pattern, then send next_command if any, timeout 10 in minutes
    def wait(self, pattern, delay_send=0, cmd_to_send="NONE", time_out=600):
        buffer = ""
        end_time = int(time.time()) + time_out
        while int(time.time()) < end_time:
            bytes_to_read = self.inWaiting()
            if bytes_to_read:
                line = self.read(bytes_to_read).decode('ISO-8859-1')
                buffer += line
                sys.stdout.write(line)
                sys.stdout.flush()
                if pattern in buffer:
                    time.sleep(delay_send)
                    if cmd_to_send != "NONE":
                        self.sendln(cmd_to_send)
                    return 0
        return 255

    # wait for a pattern in list, then send command if any, timeout 10 in minutes
    def waitls(self, patternList=[], delay_send=0, cmd_to_send="NONE", time_out=600):
        buffer = ""
        end_time = int(time.time()) + time_out
        while int(time.time()) < end_time:
            bytes_to_read = self.inWaiting()
            if bytes_to_read:
                line = self.read(bytes_to_read).decode('ISO-8859-1')
                buffer += line
                sys.stdout.write(line)
                sys.stdout.flush()
                index = 0
                for pattern in patternList:
                    if pattern in buffer:
                        time.sleep(delay_send)
                        if cmd_to_send != "NONE":
                            self.sendln(cmd_to_send)
                        return index
                    index = index + 1
        return 255  # timeout


####################################################################################################
# Burn file
####################################################################################################
def flash_burn_file(dev, index, ipl_path, soc, ipl_config, img_addr, flash_addr):
    dev.sendln()
    dev.wait(">", 0.2, "xls2")
    if soc in ["v3u", "spider", "s4sk"]:
        dev.wait("Select (1-3)>", 0.1, "1")
    else:
        dev.wait("Select (1-3)>", 0.1, "3")

    res = 0
    while res == 0:
        ex_list = ["Setting OK? (Push Y key)", "H'"]
        res = dev.waitls(ex_list, 0.1)
        if res == 0:
            dev.send("y")
            time.sleep(0.1)

    dev.sendln(img_addr)
    dev.wait("Please Input : H", 0.2, flash_addr)
    time.sleep(0.4)
    dev.wait("please send ! (Motorola S-record)", 0.2)
    dev.sendfile(ipl_path + "/" + ipl_config["ipl"][soc][index]["name"])

    ex_list = ["Clear OK?(y/n)", ">"]
    res = dev.waitls(ex_list, 0.1)
    if res == 0:
        dev.send("y")
        time.sleep(0.2)
        dev.sendln()
        dev.sendln()

def eMMC_burn_file(dev, index, ipl_path, soc, ipl_config, img_addr, flash_addr):
    dev.sendln()
    dev.wait(">", 0.2, "em_w")
    dev.wait("Setting OK? (Push Y key)", 0.2)
    dev.send("y")
    dev.wait("Select area(0-2)>", 0.1, "1")
    dev.wait("Please Input Start Address in sector :", 0.2, flash_addr)
    dev.wait("Please Input Program Start Address :", 0.2, img_addr)

    time.sleep(0.4)
    dev.wait("please send ! (Motorola S-record)", 0.2)
    dev.sendfile(ipl_path + "/" + ipl_config["ipl"][soc][index]["name"])

    dev.wait("EM_W Complete!", 0.2)
    time.sleep(0.2)
    dev.sendln()
    dev.sendln()

def get_imgaddr(file):
    """Get Image address in file srec.
    Address stores in the second line from character 5th to 12th.
    """
    with open(file, "r") as f:
        lines = f.readlines()
    return lines[1][4: 12]


####################################################################################################
# Help
####################################################################################################
def help(ipl_config):
    print("\tPlease use as syntax below:")
    print("\t python ipl_burning.py [SOC] [SERIAL] [PATH_TO_FILE_MOT] [PATH_TO_IPL_FILE] [OPTION]")
    print("\t    [SOC]          : %s" % ipl_config["flash_writer"].keys())
    print("\t    [SERIAL]       : %s " % [node.device for node in list(comports())])
    print("\t    [PATH_TO_FILE_MOT]")
    print("\t    [PATH_TO_IPL_FILE]")
    print("\t    [OPTION]:")
    print("\t       all               : download all of file ipl")
    print("\t       <name_of_file>    : download only file ipl <name_of_file>")
    print("\t       param  : download file bootparam...")
    print("\t       bl2    : download file bl2...")
    print("\t       cert   : download file cert_header...")
    print("\t       cr7    : download file cr7...")
    print("\t       cert3  : download file cert_header_sa3...")
    print("\t       cert6  : download file cert_header_sa6...")
    print("\t       cert17 : download file cert_header_sa17...")
    print("\t       tee    : download file tee...")
    print("\t       fw     : download file dummy_fw...")
    print("\t       rtos   : download file dummy_rtos...")
    print("\t       icumxa : download file icumxa_loader...")
    print("\t       bl31   : download file bl31...")
    print("\t       smoni  : download file smoni...")
    print("\t       uboot  : download file u-boot...")
    print("\t       ca55   : download file ca55 loader...")
    exit(1)


####################################################################################################
# Main
####################################################################################################
def main():
    with open("ipl_burning.json") as ipl_config_file:
        ipl_config = json.load(ipl_config_file)

    if len(sys.argv) < 6:
        print_debug("ERROR", "Lack of argument")
        help(ipl_config)

    if str(sys.argv[1]) not in ipl_config["flash_writer"].keys():
        print_debug("ERROR", 'in valid soc name "%s"' % str(sys.argv[1]))
        help(ipl_config)
    SOC = str(sys.argv[1])

    DEV_NODE = None
    nodes = list(comports())
    if sys.platform == "win32":
        serial_path = str(sys.argv[2])
    else:
        serial_path = os.path.realpath(str(sys.argv[2]))
    for node in nodes:
        if serial_path == node.device:
            DEV_NODE = str(sys.argv[2])
            break

    if DEV_NODE is None:
        print_debug("ERROR", "%s is not exists" % str(sys.argv[2]))
        help(ipl_config)

    if os.path.exists(str(sys.argv[3] + "/" + ipl_config["flash_writer"][SOC])):
        MOT_DIR = str(sys.argv[3])
    else:
        print_debug("ERROR", "%s/%s is not exists" % (sys.argv[3], ipl_config["flash_writer"][SOC]))
        exit(1)

    if os.path.exists(str(sys.argv[4])):
        IPL_DIR = str(sys.argv[4])
    else:
        print_debug("ERROR", "%s is not exists" % str(sys.argv[4]))
        help(ipl_config)

    # Define IPL shortened option
    if SOC == "v3h1":
        IPL_SHORTEN_OPTION = ["param", "icumxa", "fw", "cert6", "rtos", "bl31", "uboot"]
    elif SOC == "v3h2":
        IPL_SHORTEN_OPTION = ["param", "icumxa", "cert6", "fw", "rtos", "smoni", "uboot"]
    elif SOC == "v3u":
        IPL_SHORTEN_OPTION = ["param", "icumxa", "cert17", "fw", "rtos", "smoni", "uboot"]
    elif SOC == "v3m2":
        IPL_SHORTEN_OPTION = ["param", "cr7", "cert3", "bl2", "cert6", "bl31", "uboot"]
    elif SOC == "spider":
        IPL_SHORTEN_OPTION = ["param", "icumxa", "cert9", "fw", "rtos",  "g4mh", "icumh",
                              "smoni", "tee", "uboot"]
    elif SOC == "s4sk":
        IPL_SHORTEN_OPTION = ["param", "icumxa", "cert9", "fw", "rtos", "g4mh", "icumh",
                              "smoni", "tee", "uboot"]
    else:
        IPL_SHORTEN_OPTION = ["param", "bl2", "cert6", "bl31", "tee", "uboot"]

    OPTION = sys.argv[5:]
    FILE_INFO_INDEX = []
    FILE_IPL_WILL_BURN = []
    IMGADR_WILL_BURN = []
    FLASHADR_WILL_BURN = []
    WRITESEL_WILL_USE = []

    ret = 0

    # Load all ipl file
    if "all" in OPTION:
        OPTION = IPL_SHORTEN_OPTION

    for i in range(len(IPL_SHORTEN_OPTION)):
        if IPL_SHORTEN_OPTION[i] in OPTION:
            if not os.path.exists(IPL_DIR + "/" + ipl_config["ipl"][SOC][i]["name"]):
                ret = 1
                print_debug("ERROR", "%s is not exists" % ipl_config["ipl"][SOC][i]["name"])
                continue
            FILE_IPL_WILL_BURN.append(ipl_config["ipl"][SOC][i]["name"])
            IMGADR_WILL_BURN.append(get_imgaddr(IPL_DIR + "/" + ipl_config["ipl"][SOC][i]["name"]))
            FLASHADR_WILL_BURN.append(ipl_config["ipl"][SOC][i]["flash_addr"])
            WRITESEL_WILL_USE.append(ipl_config["ipl"][SOC][i]["write_sel"])
            FILE_INFO_INDEX.append(i)

    if ret == 1:
        exit(1)
    print_debug("INFO", "Download IPL for %s with serial device %s" % (SOC, DEV_NODE))
    print_debug("INFO", "File .mot at %s:" % MOT_DIR)
    print_debug("INFO", "    %s" % ipl_config["flash_writer"][SOC])
    print_debug("INFO", "File .srec at %s:" % IPL_DIR)
    print_debug("INFO", "    %s" % FILE_IPL_WILL_BURN)
    print_debug("INFO", "Image address: \n\t\t%s" % IMGADR_WILL_BURN)
    print_debug("INFO", "flash address: \n\t\t%s" % FLASHADR_WILL_BURN)
    print_debug("INFO", "write select: \n\t\t%s" % WRITESEL_WILL_USE)

    # Serial config
    if SOC == "spider":
        BAUDRATE = 1843200
    elif SOC == "s4sk":
        BAUDRATE = 921600
    else:
        BAUDRATE = 115200
    test_dev = Serial_conn(
        port=DEV_NODE,
        baudrate=BAUDRATE,
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
    )

    if not test_dev.isOpen():
        test_dev.open()
    print_debug("INFO", "Monitor file sending...")
    sys.stdout.flush()
    test_dev.sendfile(MOT_DIR + "/" + ipl_config["flash_writer"][SOC])
    print_debug("INFO", "Send file .mot done")
    sys.stdout.flush()
    test_dev.wait(">", 0.2, "\r")

    if SOC != "spider" and SOC != "s4sk":
        test_dev.wait(">", 0.2, "sup")
        ex_list = [
            "Please change to 921.6Kbps baud rate setting of the terminal.",
            "Please change to 460.8Kbps baud rate setting of the terminal.",
            "Change to 460.8Kbps baud rate setting of the SCIF. OK? (y/n)"
        ]
        res = test_dev.waitls(ex_list, 0.2)
        if res == 0:
            BAUDRATE = 921600
        elif res == 1:
            BAUDRATE = 460800
        else:
            test_dev.send("y")
            time.sleep(0.2)
            test_dev.sendln()
            BAUDRATE = 460800

        test_dev.baudrate = BAUDRATE

    # Loading srec
    test_dev.send("\n")

    for i in range(len(FILE_IPL_WILL_BURN)):
        if WRITESEL_WILL_USE[i] in ["eMMC"]:
            eMMC_burn_file(test_dev, FILE_INFO_INDEX[i], IPL_DIR, SOC, ipl_config, IMGADR_WILL_BURN[i], FLASHADR_WILL_BURN[i])
        else:
            flash_burn_file(test_dev, FILE_INFO_INDEX[i], IPL_DIR, SOC, ipl_config, IMGADR_WILL_BURN[i], FLASHADR_WILL_BURN[i])

    test_dev.wait(">", 1)
    print_debug("INFO", "Download file .srec done")
    test_dev.baudrate = 115200
    test_dev.close()
    exit(0)


if __name__ == "__main__":
    main()
