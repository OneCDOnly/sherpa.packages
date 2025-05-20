#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/vars.source || exit

a=$qpkgs_support_path/$service_library_source_file
b=''

# shellcheck disable=SC2013
for b in $(grep '()$' "$a" | grep -v unused-ignore | grep -v '=\|\$\|_(' | sed 's|()||g'); do
	if [[ $(grep -ow "$b" < "$a" | wc -l) -eq 1 ]]; then
		if [[ ${b:0:1} = '#' ]]; then
			echo "$b()"
		else
			TextBrightOrange "$b()"; echo
		fi
	fi
done

exit 0
