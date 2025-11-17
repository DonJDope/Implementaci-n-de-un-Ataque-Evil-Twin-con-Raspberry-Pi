#!/bin/bash
# Resetea completamente la interfaz wlan1 (antena tplink): mata wpa_supplicant/dhclient,
# limpia IPs y levanta de nuevo la interfaz.

IFACE="wlan1"

echo "[+] Matando cualquier wpa_supplicant/dhclient en $IFACE..."
pkill wpa_supplicant 2>/dev/null || true
pkill -f "dhclient.*$IFACE" 2>/dev/null || true

echo "[+] Borrando socket viejo de control..."
rm -f /var/run/wpa_supplicant/$IFACE

echo "[+] Reseteando interfaz $IFACE..."
ip link set "$IFACE" down || true
ip addr flush dev "$IFACE" || true
rfkill unblock wifi || true
ip link set "$IFACE" up || true

echo "[✔] $IFACE reseteada. Lista para volver a conectar."