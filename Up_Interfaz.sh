#!/bin/bash
# Script para reconectar la interfaz wlan1 (antena tplink) a la red WiFi de casa.
# Mata wpa_supplicant/dhclient, resetea la interfaz, crea configuración wpa_supplicant
# para la red de casera, inicia wpa_supplicant.
set -e

IFACE="wlan1"

if [ "$EUID" -ne 0 ]; then
  echo "Ejecuta con sudo: sudo $0"
  exit 1
fi

echo "[+] Matando procesos viejos en $IFACE (wpa_supplicant/dhclient)..."
pkill -f "wpa_supplicant.*$IFACE" 2>/dev/null || true
pkill -f "dhclient.*$IFACE" 2>/dev/null || true
sleep 1

echo "[+] Reseteando interfaz $IFACE..."
ip link set "$IFACE" down || true
ip addr flush dev "$IFACE" || true
rfkill unblock wifi || true
ip link set "$IFACE" up

echo "[+] Creando config para SSID 'TU_SSID_CASA'..."
cat > /tmp/wpa-$IFACE-casa.conf <<EOF
ctrl_interface=/var/run/wpa_supplicant
update_config=1
country=MX

network={
    ssid="SSID_CASA"
    psk="PASSWORD_CASA"
    key_mgmt=WPA-PSK
}
EOF

echo "[+] Iniciando wpa_supplicant en $IFACE..."
wpa_supplicant -B -D nl80211 -i "$IFACE" -c /tmp/wpa-$IFACE-casa.conf

echo "[+] Esperando asociación..."
sleep 5

echo "[+] Pidiendo IP por DHCP en $IFACE..."
dhclient "$IFACE"

echo "[✔] Script para casa terminado."