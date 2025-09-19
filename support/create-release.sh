#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

release_tag=v${build_date}

echo "release_tag: '$release_tag'"

gh release create "$release_tag" --generate-notes
