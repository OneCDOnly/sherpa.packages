#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/vars.source || exit

./build-all.sh || exit
./commit.sh '[update] QPKG archives' || exit
