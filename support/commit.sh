#!/usr/bin/env bash

# Inputs: (local)
#	$1 (optional) = commit message.
#	$2 (optional) = 'nocheck' : skip code syntax check. Default is to perform syntax check before committing.

this_path=$PWD
. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

cd "$qpkgs_support_path" || exit
./clean-source.sh

# if [[ ${2:-} != nocheck ]]; then
# 	./check-syntax.sh || exit
# 	./check-whitespace.sh || exit
# fi

cd "$qpkgs_root_path" || exit

if [[ -z ${1:-} ]]; then
	git add . && git commit && git push || exit
else
	git add . && git commit -m "$1" && git push || exit
fi

cd "$this_path" || exit
