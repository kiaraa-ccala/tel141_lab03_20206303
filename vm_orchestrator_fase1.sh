#!/bin/bash
# vm_orchestrator_fase1.sh
# Orquesta la Fase 1 del laboratorio: inicializa Workers, OFS y crea VMs.

set -e

### CONFIGURACIÓN ###
# Ajusta estos valores a tu topología real

# Workers: [OVS_NAME IFACE_UPLINK]
WORKERS=(
    "br-int ens4"   # Worker 1
    "br-int ens4"   # Worker 2
    "br-int ens4"   # Worker 3
)

# OFS
OFS_NAME="br-ofs"
OFS_INTERFACES="ens4 ens5 ens6 ens7"

# Definición de VMs: "VM_NAME OVS_NAME VLAN_ID VNC_ID"
VMS=(
    "vm1_w1 br-int 100 1"
    "vm2_w1 br-int 200 2"
    "vm3_w1 br-int 300 3"
    "vm1_w2 br-int 100 4"
    "vm2_w2 br-int 200 5"
    "vm3_w2 br-int 300 6"
    "vm1_w3 br-int 100 7"
    "vm2_w3 br-int 200 8"
    "vm3_w3 br-int 300 9"
)
#####################

echo "== [1] Inicializando Workers =="
for W in "${WORKERS[@]}"; do
    ./init_worker.sh $W
done

echo "== [2] Inicializando OFS =="
./init_ofs.sh $OFS_NAME $OFS_INTERFACES

echo "== [3] Creando VMs =="
for VM in "${VMS[@]}"; do
    ./vm_create.sh $VM
done

echo "[✔] Topología de Fase 1 creada correctamente."
