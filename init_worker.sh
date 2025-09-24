#!/bin/bash
# init_worker.sh
# Uso: sudo ./init_worker.sh <OVS_NAME> <IFACE1> [IFACE2 ...]

OVS_NAME=$1
shift
IFACES=$@

# Crear bridge si no existe
ovs-vsctl br-exists $OVS_NAME || ovs-vsctl add-br $OVS_NAME
ip link set $OVS_NAME up

# Conectar interfaces
for IFACE in $IFACES; do
    ip link set $IFACE up
    ovs-vsctl list-ports $OVS_NAME | grep -w $IFACE >/dev/null || ovs-vsctl add-port $OVS_NAME $IFACE
done
