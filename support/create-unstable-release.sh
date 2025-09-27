#!/usr/bin/env bash

set -o nounset

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

./create-release.sh unstable
