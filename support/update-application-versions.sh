#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

git add "$packages_source_file" && git commit -m '[update] application version(s)' && git push
