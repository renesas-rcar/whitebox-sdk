#!/usr/bin/env python3

import os
import sys
import subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler
from http import HTTPStatus
from urllib.parse import urlparse, parse_qs

def eprint(*args, **kwargs):
    print("Log: ", end='', file=sys.stderr)
    print(*args, file=sys.stderr, **kwargs)

def power_contorl(command):
    POWER_SCRIPT = os.environ.get('POWER_SCRIPT')
    cmd = [POWER_SCRIPT, command]
    subprocess.run(cmd, stdout=None, stderr=None )

def viss_restart():
    cmd = ["systemctl", "restart", "vissv2server"]
    subprocess.run(cmd, stdout=None, stderr=None )

def snort_control(command):
    cmd = ["systemctl", "***COMMAND***", "snort-tsn0"]
    if command == "on":
        cmd[1] = "restart"
    elif command == "off":
        cmd[1] = "stop"
    else:
        return
    subprocess.run(cmd, stdout=None, stderr=None )


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
        command = urlparse(self.path).path[1:]
        query = urlparse(self.path).query
        query_dict = parse_qs(query)
        args = ""
        for value in query_dict.values():
            args += value[0] + " "

        # command is POWER case
        if command == "POWER":
            power_contorl(args.rstrip())
        elif command == "snort":
            snort_control(args.rstrip())
        elif command == "viss_restart":
            viss_restart()
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
    server_address = ('0.0.0.0', 8000)
    eprint(server_address)
    httpd = HTTPServer(server_address, HttpHandler)
    httpd.serve_forever()

