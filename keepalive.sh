#!/bin/bash
# Mantiene el Codespace activo durante 4 horas y luego detiene playit sin borrar archivos.
# Ejecútalo en una terminal dentro del Codespace.

DURATION=$((4*60*60))
END_TIME=$((SECONDS + DURATION))
LOGFILE=/workspaces/elpollinipowa/keepalive.log

echo "Keepalive iniciado: $(date)" | tee -a "$LOGFILE"

echo "Arrancando playit si no está activo..." | tee -a "$LOGFILE"
if ! sg playit -c 'playit status' >/dev/null 2>&1; then
  sg playit -c 'playit start' >/dev/null 2>&1 || true
fi

while [ $SECONDS -lt $END_TIME ]; do
  echo "KEEPALIVE $(date)" | tee -a "$LOGFILE"
  sleep 300
  ps aux | grep -E 'playit|minecraft|java' | grep -v grep | tee -a "$LOGFILE"
  echo "---" | tee -a "$LOGFILE"
done

echo "Tiempo cumplido: $(date)" | tee -a "$LOGFILE"
echo "Deteniendo playit seguro..." | tee -a "$LOGFILE"
sg playit -c 'playit stop' >/dev/null 2>&1 || true
sleep 2
sudo pkill -9 playitd >/dev/null 2>&1 || true
sleep 1
rm -f /run/playit/playitd.sock >/dev/null 2>&1 || true

echo "Keepalive finalizado, playit detenido. Archivos conservados." | tee -a "$LOGFILE"
