#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# For sqlite
import json
from datetime import datetime
import sqlite3
import random
import time
import argparse

# for UDP communication
import socket

HOST_NAME = ''
PORT = 12345
db_file = './db/statestorage.db'

###########################################################################
# Alcohol sensor functions                                                #
#   Following two functions are ported from MikroSDK v2.0.0.0             #
#     URL: https://libstock.mikroe.com/projects/view/3359/alcohol-3-click #
#   Original C code: Copyright© 2020 MikroElektronika d.o.o.              #
#   Python code:     ported by Yuya Hamamachi                             #
###########################################################################
def ppm_2_mgl(ppm):
    mgl = (1.82 * ppm) / 1000.0
    return mgl;

def etanol_in_co(co):
    etanol = 0
    if co == 0:
        etanol = 0
    elif co <= 10:
        etanol = co / 10.0
    elif co > 10 and co <= 50:
        etanol = (float)(6 / 50.0) * co
    elif co > 50 and co <= 100:
        etanol = (0.18 * co)
    elif co > 100:
        etanol = (float)(274 / 500.0) * co

    return etanol

##########################################################################


# update db file
def update(data_list):
    con = sqlite3.connect(db_file)
    cur = con.cursor()
    for data in data_list:
        cur.execute('SELECT * FROM VSS_MAP where path="{}"'.format(data['path']))
        if len(cur.fetchall()) < 1:
            cur.execute('INSERT INTO VSS_MAP(path) VALUES ("{}")'.format(data['path']))
    cur.executemany(
        #"UPDATE VSS_MAP SET value=:value, timestamp=:timestamp WHERE path=:path",
        "UPDATE VSS_MAP SET c_value=:value, c_ts=:timestamp WHERE path=:path",
        data_list)
    con.commit()
    con.close()

def update_private_alcohol_value(b_value):
    print("Call update func#")
    print(b_value)
    now = time.time()
    dt = datetime.utcfromtimestamp(now)
    ts = dt.isoformat(timespec='seconds') + 'Z'
    data_list = [
        {
            'path': 'Vehicle.Private.Safety.AlcoholSensor.value',
            'value': b_value,
            'timestamp': ts
        }
    ]
    update(data_list)

def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(5.0)
    sock.bind((HOST_NAME, PORT))
    value = -1.0

    while True:
        try:
            rcv_data, addr = sock.recvfrom(1024)
            co_ppm = int(rcv_data[0]<<8) + int(rcv_data[1])
            ethanol_ppm = etanol_in_co(co_ppm)
            alcohol_mg_per_L = ppm_2_mgl(ethanol_ppm)
            print("receive data : [{}] mgl={}  from {}".format(rcv_data.hex(),alcohol_mg_per_L, addr))
            value = alcohol_mg_per_L
        except socket.timeout:
            print("timeout")
            value = -1.0
        finally:
            pass
            # update_private_dms_face(value)
            update_private_alcohol_value(value)

    sock.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
            '--dbfile', help='db file path', default='./db/statestorage.db')
    parser.add_argument(
            '-i', '--ip', help='ip', default='0.0.0.0')
    parser.add_argument(
            '-p', '--port', help='port number', default=PORT, type=int)
    parser.add_argument(
            '--verbose', help='stdout verbose enabled', default=0, type=int)
    args = parser.parse_args()

    db_file = args.dbfile
    print('dbfile: ' + args.dbfile)
    HOST_NAME = args.ip
    print('ip: ' + HOST_NAME)
    PORT = args.port
    print('port: ' + str(PORT))

    main()

