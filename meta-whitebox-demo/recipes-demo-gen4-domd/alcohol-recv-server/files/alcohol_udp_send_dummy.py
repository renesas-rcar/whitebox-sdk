import socket
import time

M_SIZE = 1024

serv_address = ('192.168.137.11', 12345)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
counter = 0

while True:
    try:
        buf = b'\x20\x30'
        buf = bytes([counter//0xff,counter%0xff])
        send_len = sock.sendto(buf, serv_address)
        time.sleep(1)
        counter += 10
        if counter > 0xffff:
            counter = 0
        continue

    except KeyboardInterrupt:
        print('closing socket')
        sock.close()
        print('done')
        break

