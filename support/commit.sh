#!/usr/bin/env bash

# Input:
#	$1 = commit message (optional)
#	$1 = 'nocheck' (optional) = skip syntax check. Default is to perform syntax check before committing.

this_path=$PWD
. $HOME/scripts/nas/sherpa/support/vars.source || exit

cd "$qpkgs_support_path" || exit

[[ -e $packages_file ]] && rm -f "$packages_file"

cd "$qpkgs_root_path" || exit

if [[ -z ${1:-} || ${1:-} = nocheck ]]; then
	git add . && git commit && git push || exit
else
	git add . && git commit -m "$1" && git push || exit
fi

cd "$this_path" || exit
