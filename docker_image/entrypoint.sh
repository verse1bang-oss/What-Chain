#!/bin/sh

if [ -z "${BIN_PATH}" ]; then
  echo "BIN_PATH not provided using /bin/cli as default"
  export BIN_PATH="/bin/cli"
else
  echo "using existing BIN_PATH $BIN_PATH"
fi

if [ -f "/root/.canopy/cli" ]; then
  echo "Found existing persistent cli version"
else
  echo "Persisting build version for current cli"
  cp "$BIN_PATH" /root/.canopy/cli
fi
ln -sf /root/.canopy/cli "$BIN_PATH"

# Update walletPort in config.json to match Railway exposed port
if [ -f "/root/.canopy/config.json" ]; then
  sed -i 's/"walletPort": "[^"]*"/"walletPort": "9001"/' /root/.canopy/config.json
  echo "Updated walletPort to 9001"
fi

exec /app/canopy "$@"
