#!/usr/bin/env python3
import os
import socket
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler


def get_ip():
    host_name = socket.gethostname()
    ip_address = socket.gethostbyname(host_name)
    return ip_address.encode('utf8')


def hosts_update():
    with open('/etc/hosts', 'r+') as f:
        line_found = any("api.ipify.org" in line for line in f)
        if not line_found:
            f.seek(0, os.SEEK_END)
            f.write('127.0.0.1 api.ipify.org\n')


class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(get_ip())


if __name__ == '__main__':
    hosts_update()
    httpd = HTTPServer(('localhost', 80), SimpleHTTPRequestHandler)
    pid = os.fork()
    if pid != 0:
        print(f'running ipify faker with pid: {pid}')
        sys.exit(0)
    httpd.serve_forever()
