#!/usr/bin/env bash

set -o nounset

./build-all.sh || exit
./copy-qpkgs-to-staging.sh || exit
./delete-testing-release.sh || exit
./create-testing-release.sh || exit
./move-assets-to-testing-release.sh || exit
./purge-old-qpkgs.sh || exit
