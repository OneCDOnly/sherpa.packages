#!/usr/bin/env bash
exit			# Needs to be modified to work with multiple arch package files.
. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

git add "$packages_source_file" && git commit -m '[update] application version(s)' && git push
