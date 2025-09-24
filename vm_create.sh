#!/bin/bash


set -e

if [ $# -ne 4 ]; then
    echo "Uso: $0 <VM_NAME> <OVS_NAME> <VLAN_ID> <VNC_DISPLAY>"
    exit 1
fi

VM_NAME=$1
OVS_NAME=$2
VLAN_ID=$3
VNC_ID=$4

# Nombre de la interfaz TAP (máx 15 caracteres)
TAP_IF="tap_${VM_NAME}"
TAP_IF=${TAP_IF:0:15}

# Imagen base de la VM (ajusta la ruta a tu imagen)
DISK_IMG="/var/lib/libvirt/images/cirros.qcow2"

# Crear TAP si no existe
if ip link show "$TAP_IF" >/dev/null 2>&1; then
    echo "[=] Interfaz $TAP_IF ya existe"
else
    ip tuntap add dev "$TAP_IF" mode tap
    ip link set "$TAP_IF" up
    echo "[+] TAP $TAP_IF creada"
fi

# Conectar TAP al OvS con VLAN
if ovs-vsctl list-ports "$OVS_NAME" | grep -qw "$TAP_IF"; then
    echo "[=] $TAP_IF ya estaba en $OVS_NAME"
else
    ovs-vsctl add-port "$OVS_NAME" "$TAP_IF" tag=$VLAN_ID
    echo "[+] $TAP_IF conectada a $OVS_NAME con VLAN $VLAN_ID"
fi

# MAC aleatoria para la VM
MAC="52:54:00:$(hexdump -n3 -e '/1 ":%02X"' /dev/urandom)"

# Lanzar la VM
qemu-system-x86_64 \
    -enable-kvm \
    -name "$VM_NAME" \
    -m 512 \
    -smp 1 \
    -drive file="$DISK_IMG",if=virtio,format=qcow2 \
    -netdev tap,id=net0,ifname="$TAP_IF",script=no,downscript=no \
    -device virtio-net-pci,netdev=net0,mac="$MAC" \
    -vnc :$VNC_ID \
    -daemonize

echo "[✔] VM $VM_NAME creada en VLAN $VLAN_ID (VNC :$VNC_ID)"
