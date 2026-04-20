#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

git add "$qpkgs_root_path"/*.whl "$qpkgs_root_path"/*pypi-lists* && git commit -m '[update] PyPI wheels' && git push
