#!/usr/bin/env bash

# compiler for sherpa QPKG archives.

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

echo -n 'building archives ... '

declare -a a
declare -a b
declare -i i=0

a+=($qpkgs_support_path/$packages_file)
b+=($qpkgs_root_path/$packages_archive_file)

[[ ! -e $qpkgs_support_path/$packages_file ]] && $qpkgs_support_path/build-packages.sh

for i in "${!a[@]}"; do
	[[ -e ${b[i]} ]] && rm -f "${b[i]}"

	if [[ ! -e ${a[i]} ]]; then
		TextBrightRed "'${a[i]}' not found, "
		continue
	fi

	tar --create --gzip --numeric-owner --file="${b[i]}" --directory="$qpkgs_support_path" "$(basename "${a[i]}")"

	if [[ ! -s ${b[i]} ]]; then
		TextBrightRed "'${b[i]}' was not written"; echo
		exit 1
	fi

	[[ -e ${a[i]} ]] && rm -f "${a[i]}"
	chmod 444 "${b[i]}"
done

ShowDone
exit 0
