#!/usr/bin/env bash

set -o nounset

./build-all.sh || exit
./copy-qpkgs-to-staging.sh || exit
./create-now-release.sh || exit
./move-assets-to-now-release.sh || exit
./purge-old-qpkgs.sh || exit
