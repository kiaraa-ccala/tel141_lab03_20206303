#!/bin/bash
# init_ofs.sh
# Inicializa el OFS: limpia las IPs de la red de datos y conecta las interfaces al OvS.
#
# Uso:
#   sudo ./init_ofs.sh <OVS_NAME> <IFACE1> [IFACE2 ...]

set -e

if [ $# -lt 2 ]; then
    echo "Uso: $0 <OVS_NAME> <IFACE1> [IFACE2 ...]"
    exit 1
fi

OVS_NAME=$1
shift
IFACES=$@

# Verificar que el bridge ya existe
if ! ovs-vsctl br-exists "$OVS_NAME"; then
    echo "El bridge $OVS_NAME no existe. Primero créalo con ovs-vsctl add-br."
    exit 1
fi

# Activar el bridge
ip link set "$OVS_NAME" up

# Procesar cada interfaz
for IFACE in $IFACES; do
    echo "[*] Configurando $IFACE para $OVS_NAME"

    # Limpiar configuración IP (solo capa 2 en Data Network)
    ip addr flush dev "$IFACE"
    ip link set "$IFACE" up

    # Agregar al OvS si aún no está
    if ovs-vsctl list-ports "$OVS_NAME" | grep -qw "$IFACE"; then
        echo "    - $IFACE ya estaba en $OVS_NAME"
    else
        ovs-vsctl add-port "$OVS_NAME" "$IFACE"
        echo "    - $IFACE agregado a $OVS_NAME"
    fi
done

echo "[✔] OFS $OVS_NAME inicializado con interfaces: $IFACES"
