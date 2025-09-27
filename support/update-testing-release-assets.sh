#!/usr/bin/env bash

set -o nounset

./build-all.sh
./copy-qpkgs-to-staging.sh
./delete-testing-release.sh
./create-testing-release.sh
./move-assets-to-testing-release.sh
./purge-old-qpkgs.sh
