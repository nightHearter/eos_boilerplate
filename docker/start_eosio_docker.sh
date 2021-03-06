#!/usr/bin/env bash
set -o errexit

# change to script's directory
cd "$(dirname "$0")"

PROJ="$1"
CONTRACTDIR="$(dirname "$PWD")"

if [ "$2" == "-rm" ]
then
    echo "== stop docker container and rm the data dir."
    docker stop "$PROJ" || true && docker rm --force "$PROJ" || true
    rm -rf "data" || true && mkdir -p "data" || true
fi

if [ -e "data/initialized" ]
then
    script="./scripts/continue_blockchain.sh"
else
    script="./scripts/init_blockchain.sh"
fi

echo "=== run docker container from the eosio/eos-dev image ==="
docker run --rm --name "$PROJ" -d \
-p 7777:8888 -p 5555:5555 -p 9876:9876 \
--mount type=bind,src="$CONTRACTDIR"/contracts,dst=/opt/eosio/bin/contracts \
--mount type=bind,src="$(pwd)"/scripts,dst=/opt/eosio/bin/scripts \
--mount type=bind,src="$(pwd)"/data,dst=/mnt/dev/data \
-w "/opt/eosio/bin/" eosio/eos-dev:v1.4.2 /bin/bash -c "$script"

if [ "$1" != "--nolog" ]
then
    echo "=== follow $PROJ logs ==="
    docker logs "$PROJ" --follow
fi
