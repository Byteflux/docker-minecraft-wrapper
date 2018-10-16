#!/bin/bash

stop() {
  wrapper-exec "$SHUTDOWN_COMMAND"
}

trap stop SIGTERM

screen -dmS wrapper java \
  "-Xms$HEAP_SIZE" \
  "-Xmx$HEAP_SIZE" \
  -XX:+UseG1GC \
  -XX:+UnlockExperimentalVMOptions \
  -XX:MaxGCPauseMillis=100 \
  -XX:+DisableExplicitGC \
  -XX:TargetSurvivorRatio=90 \
  -XX:G1NewSizePercent=50 \
  -XX:G1MaxNewSizePercent=80 \
  -XX:G1MixedGCLiveThresholdPercent=35 \
  -XX:+AlwaysPreTouch \
  -XX:+ParallelRefProcEnabled \
  -Dusing.aikars.flags=mcflags.emc.gs \
  -Dfile.encoding=UTF-8 \
  -Dcom.sun.management.jmxremote.port=9010 \
  -Dcom.sun.management.jmxremote.rmi.port=9010 \
  -Dcom.sun.management.jmxremote.authenticate=false \
  -Dcom.sun.management.jmxremote.ssl=false \
  -Djava.rmi.server.hostname=localhost \
  -Xdebug -Xrunjdwp:transport=dt_socket,address=8888,server=y,suspend=n \
  -agentpath:/opt/yjp/bin/linux-x86-64/libyjpagent.so=listen=0.0.0.0:10001,delay=10000,exceptions=off,disableoomedumper,probe_disable=* \
  -jar "$JAR_FILE"

tail -n 0 -F "$LOG_FILE" 2>/dev/null &

for i in {1..6}; do
  if [[ i -eq 6 ]]; then
    echo "The server failed to start."
    exit 1
  fi

  PID=$(pgrep java)
  if [[ -z "$PID" ]]; then
    sleep 1
  else
    break
  fi
done

while :; do
  if [[ -d "/proc/$PID" ]]; then
    sleep 0.1
  else
    break
  fi
done
