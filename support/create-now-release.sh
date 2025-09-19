#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

./create-release.sh "v${build_date}"
