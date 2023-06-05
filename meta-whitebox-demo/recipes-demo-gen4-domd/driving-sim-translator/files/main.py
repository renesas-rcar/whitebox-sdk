#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import asyncio
import websockets
import json
from datetime import datetime
from translation import translate
import sqlite3
import argparse


# settings
ws_ip = '0.0.0.0'
ws_port = 3000
db_file = '/var/statestorage.db'
verbose = False


# update db file
async def update(data_list):
    con = sqlite3.connect(db_file)
    cur = con.cursor()
    # if detabase file doens't have data
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


# websocket handler
async def handler(websocket, path):
    async for message in websocket:
        request = json.loads(message)
        arg = request['arg']
        data_list = translate(arg)

        dt = datetime.utcfromtimestamp(arg['Timestamp'] / 1000.0)
        ts = dt.isoformat(timespec='seconds') + 'Z'

        for data in data_list:
            data['timestamp'] = ts

            # If boolean, convert to string valid in VISS.
            if type(data['value']) is bool:
                data['value'] = 'true' if data['value'] else 'false'

            if verbose:
                if type(data['value']) is str:
                    print(data['path'] + ': "' + data['value'] + '"')
                else:
                    print(data['path'] + ': ' + str(data['value']))

        await update(data_list)


# main
async def main():
    async with websockets.serve(handler, "0.0.0.0", ws_port):
        await asyncio.Future()  # run forever


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--dbfile', help='db file path', default='./db/statestorage.db')
    parser.add_argument(
        '-i', '--ip', help='ip', default='0.0.0.0')
    parser.add_argument(
        '-p', '--port', help='port number', default=3000, type=int)
    parser.add_argument(
        '--verbose', help='stdout verbose enabled', default=0, type=int)
    args = parser.parse_args()

    db_file = args.dbfile
    print('dbfile: ' + args.dbfile)
    ws_ip = args.ip
    print('ip: ' + ws_ip)
    ws_port = args.port
    print('port: ' + str(ws_port))

    if args.verbose != 0:
        verbose = True
        print('verbose is enabled.')

    asyncio.run(main())
