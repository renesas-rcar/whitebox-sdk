# !/bin/sh

# This is WA. TBD: how to deploy certificates for domd UM

domd_url="root@192.168.0.1"
ssh_params="-o ServerAliveInterval=1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

ssh $ssh_params $domd_url 'mkdir -p /var/aos/crypt/um'
scp -r $ssh_params /var/aos/crypt/um/* $domd_url:/var/aos/crypt/um
ssh $ssh_params $domd_url '/opt/aos/provfinish.sh'
