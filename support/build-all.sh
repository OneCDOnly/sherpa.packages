#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/vars.source || exit

declare -a a
declare -i i=0

a+=("$qpkg_support_path/$packages_file")

for i in "${!a[@]}"; do
	[[ -e ${a[i]} ]] && rm -f "${a[i]}"
done

./build-qpkgs.sh sherpa || exit
./build-packages.sh || exit
./build-wiki-package-abbreviations.sh || exit
./build-archives.sh || exit
