#!/usr/bin/env bash

#run the app
if [[ -z "$TIZEN" ]]; then
  echo "Error: TIZEN must be set."
  exit 1
fi

# parse the manifest, get package="org.example.zig-app"
pkg=$(grep -m1 -oP 'package="\K[^"]+' ./pkg/tizen-manifest.xml)

# run the app
${TIZEN}/tools/sdb shell launch_app $pkg
${TIZEN}/tools/sdb shell dlogutil -b apps | grep "APP_$pkg"