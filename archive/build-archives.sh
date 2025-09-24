#!/usr/bin/env bash

# compiler for sherpa QPKG archives.

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

declare -a a
declare -a b
declare -i i=0

[[ ! -e $qpkgs_support_path/$packages_file ]] && $qpkgs_support_path/build-packages.sh

CheckPlaceholdersInPackages

echo 'writing archives ...'

# Add source and target filenamepaths.

a+=($qpkgs_support_path/$packages_file)
b+=($qpkgs_root_path/$packages_archive_file)

for i in "${!a[@]}"; do
	[[ -e ${b[i]} ]] && rm -f "${b[i]}"

	if [[ ! -e ${a[i]} ]]; then
		TextBrightRed "'${a[i]}' not found, "
		continue
	fi

	echo -n "writing file '$(basename ${b[i]})' ... "
	tar --create --gzip --numeric-owner --file="${b[i]}" --directory="$qpkgs_support_path" "$(basename "${a[i]}")"

	if [[ ! -s ${b[i]} ]]; then
		echo; TextBrightRed "'${b[i]}' was not written"; echo
		exit 1
	fi

	ShowDone

	[[ -e ${a[i]} ]] && rm -f "${a[i]}"
	chmod 444 "${b[i]}"
done

exit 0
