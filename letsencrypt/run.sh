#!/bin/bash
set -e

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir
CONFIG_PATH=/data/options.json

EMAIL=$(jq --raw-output ".email" $CONFIG_PATH)
DOMAINS=$(jq --raw-output ".domains[]" $CONFIG_PATH)
KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)

mkdir -p "$CERT_DIR"

# Generate new certs
if [ ! -d "$CERT_DIR/live" ]; then
    DOMAIN_ARR=()
    for line in $DOMAINS; do
        DOMAIN_ARR+=(-d "$line")
    done

    echo "$DOMAINS" > /data/domains.gen
    certbot --text --agree-tos --email "$EMAIL" -d "${DOMAIN_ARR[@]}" --manual --preferred-challenges dns --expand --renew-by-default  --manual-public-ip-logging-ok certonly

# Renew certs
else
    certbot --text --agree-tos --email "$EMAIL" -d "${DOMAIN_ARR[@]}" --manual --preferred-challenges dns --expand --renew-by-default  --manual-public-ip-logging-ok certonly
fi

# copy certs to store
cp "$CERT_DIR"/live/*/privkey.pem "/ssl/$KEYFILE"
cp "$CERT_DIR"/live/*/fullchain.pem "/ssl/$CERTFILE"
