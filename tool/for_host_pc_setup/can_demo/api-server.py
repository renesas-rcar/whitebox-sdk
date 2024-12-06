#!/usr/bin/env python3

import os
import sys
import subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler
from http import HTTPStatus
from urllib.parse import urlparse, parse_qs

# Check can1 is enabled
ret = subprocess.run(["ifconfig", "can1"], stdout=None, stderr=subprocess.DEVNULL).returncode
CAN1_ENABLED = True if ret == 0 else False
# print(ret, CAN1_ENABLED)

def eprint(*args, **kwargs):
    print("Log: ", end='', file=sys.stderr)
    print(*args, file=sys.stderr, **kwargs)

def canfdtest_control(command):
    cmd = []
    if command[1] == "ON":
        command[1] = "can0"
        cmd = command
    elif command[1] == "OFF":
        cmd = ["killall", "canfdtest"]
    else:
        return
    print(cmd)
    # subprocess.run(cmd, stdout=None, stderr=None) # Wait for exit
    subprocess.Popen(cmd, stdout=None, stderr=None) # Run on background
    
    if CAN1_ENABLED is True:
        cmd[1] = "can1"
        subprocess.Popen(cmd, stdout=None, stderr=None) # Run on background


def cansend_control(command):
    cmd = command
    cmd[1] = "can0" # replace canX to real socket an device
    # '#'はurlとして送れないので、一度'_'に変換してから送信する形になっている。
    cmd[2] = cmd[2].replace("_", "#")
    # print(cmd)
    # subprocess.run(cmd, stdout=None, stderr=None) # Wait for exit
    subprocess.Popen(cmd, stdout=None, stderr=None) # Run on background
    
    if CAN1_ENABLED is True:
        cmd[1] = "can1"
        subprocess.Popen(cmd, stdout=None, stderr=None) # Run on background

def canviewer_control(command):
    if command[1] == "RESET":
        cmd = "ps -ax | grep can.viewer | grep /usr/bin/python3 | awk '{print $1}' | xargs kill"
        subprocess.run(cmd, capture_output=True, shell=True)
    
class HttpHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200, "ok")
        self.send_header('Access-Control-Allow-Credentials', 'true')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header("Access-Control-Allow-Headers", "X-Requested-With, Content-type")

    def do_GET(self):
        eprint(self.path[1:])
        host = urlparse(self.path[1:]).netloc
        commands = urlparse(self.path).path[1:].split("/")
        command  = commands[0]
        query = urlparse(self.path).query
        query_dict = parse_qs(query)
        args = ""
        for value in query_dict.values():
            args += value[0] + " "

        # command
        if command == "canfdtest":
            canfdtest_control(commands)
        elif command == "canviewer":
            canviewer_control(commands)
        elif command == "cansend":
            cansend_control(commands)
        # Others
        else:
            # Print command
            _command = args.rstrip()
            print(_command)
            sys.stdout.flush()

        # Response to client
        ## make header
        self.send_response(HTTPStatus.OK)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        ## Make response
        self.wfile.write(b"Hello")
    def log_message(self, format, *args):
        return

if __name__ == '__main__':
    server_address = ('0.0.0.0', 9000)
    eprint(server_address)
    httpd = HTTPServer(server_address, HttpHandler)
    httpd.serve_forever()

