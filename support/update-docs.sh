#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/vars.source || exit

git add "$qpkgs_docs_path" && git commit -m '[update] readme doc(s)' && git push
