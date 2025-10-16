#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

git add "$qpkgs_root_path"/*.{cfg,md5,lib,sh} && git commit -m '[update] built files' && git push
