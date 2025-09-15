#!/usr/bin/env bash

# compiler for sherpa QPKG archives.

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

declare -a a
declare -a b
f=''
declare -i i=0

$qpkgs_support_path/build-multiple-arch-packages.sh

echo 'writing multiple arch archives ...'

# Add source and target filenamepaths.

for f in "$qpkgs_support_path"/*.packages; do
	a+=($f)
	b+=($qpkgs_staging_path/$(basename "$f").tar.gz)
done

for i in "${!a[@]}"; do
	[[ -e ${b[i]} ]] && rm -f "${b[i]}"

	if [[ ! -e ${a[i]} ]]; then
		TextBrightRed "'${a[i]}' not found, "
		continue
	fi

	echo -n "writing file '$(basename ${b[i]})' ... "
	tar --create --gzip --numeric-owner --file="${b[i]}" --directory="$qpkgs_support_path" "$(basename "${a[i]}")"

	if [[ ! -s ${b[i]} ]]; then
		TextBrightRed "'${b[i]}' was not written"; echo
		exit 1
	fi

	rm -f "${a[i]}"

	ShowDone

	[[ -e ${a[i]} ]] && rm -f "${a[i]}"
	chmod 444 "${b[i]}"
done

exit 0
