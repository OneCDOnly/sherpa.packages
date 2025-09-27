#!/usr/bin/env bash

set -o nounset

release_tag=testing

echo "release_tag: '$release_tag'"

gh release create "$release_tag" --prerelease --title testing --notes 'changelog unavailable at this time'
