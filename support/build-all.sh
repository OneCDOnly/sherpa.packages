#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/vars.source || exit

declare -a a
declare -i i=0

a+=("$qpkg_support_path/$packages_file")

for i in "${!a[@]}"; do
	[[ -e ${a[i]} ]] && rm -f "${a[i]}"
done

$qpkg_support_path/build-qpkgs.sh sherpa || exit
$qpkg_support_path/build-packages.sh || exit
$qpkg_support_path/build-wiki-package-abbreviations.sh || exit
$qpkg_support_path/build-archives.sh || exit
