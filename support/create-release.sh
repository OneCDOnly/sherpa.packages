#!/usr/bin/env bash

set -o nounset

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

release_tag=${1:?no release tag provided}

echo "release_tag: '$release_tag'"

gh release create "$release_tag" --generate-notes
