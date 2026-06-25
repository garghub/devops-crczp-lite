#!/bin/bash

VM_ID="a9c7bb3"
LOG_DIR="/home/dn/local/crcz/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/log_$(date '+%Y-%m-%d_%H-%M-%S').log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Restart script started at $(date) ==="
echo "Log file: $LOG_FILE"

echo "=== Halting VM ==="
sudo docker run --rm -e LIBVIRT_DEFAULT_URI -v /var/run/libvirt/:/var/run/libvirt/ -v /home/dn/.vagrant.d:/.vagrant.d -v /home/dn/local/crcz:/home/dn/local/crcz -w /home/dn/local/crcz --network host vagrantlibvirt/vagrant-libvirt:latest vagrant halt "$VM_ID"

echo "=== Waiting 1 minute after halt ==="
sleep 60

echo "=== Starting VM ==="
sudo docker run --rm -e LIBVIRT_DEFAULT_URI -v /var/run/libvirt/:/var/run/libvirt/ -v /home/dn/.vagrant.d:/.vagrant.d -v /home/dn/local/crcz:/home/dn/local/crcz -w /home/dn/local/crcz --network host vagrantlibvirt/vagrant-libvirt:latest vagrant up "$VM_ID"

echo "=== Waiting for OpenStack services to start (3 minutes) ==="
sleep 180

echo "=== Starting OpenStack instances ==="
sudo docker run --rm -e LIBVIRT_DEFAULT_URI -v /var/run/libvirt/:/var/run/libvirt/ -v /home/dn/.vagrant.d:/.vagrant.d -v /home/dn/local/crcz:/home/dn/local/crcz -w /home/dn/local/crcz --network host vagrantlibvirt/vagrant-libvirt:latest vagrant ssh "$VM_ID" -- -t 'sudo su -c "source /root/kolla-ansible-venv/bin/activate && source /etc/kolla/admin-openrc.sh && openstack server list --status SHUTOFF -f value -c ID | xargs -r openstack server start"'

echo "=== Done at $(date) ==="
