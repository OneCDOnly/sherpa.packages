#!/usr/bin/env bash

# Copy QPKG builds with the highest version numbers to the staging path.

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

arch=''
checksum_filename=''
debug=false
hash=''
highest_table=''
package_name=''
qpkg_filename=''
short_path=''
version=''

if [[ -e $highest_package_versions_found_pathfile ]]; then
	highest_table="$(StripComments "$(<"$highest_package_versions_found_pathfile")")"
else
	echo; TextBrightRed "file '$highest_package_versions_found_pathfile' not found"; echo
	exit 1
fi

echo -n 'copy QPKGs to staging ... '
[[ $debug = true ]] && echo

while read -r checksum_filename qpkg_filename package_name version arch short_path hash; do
	# Copy highest build version of this QPKG to release path.

	[[ -e "$checksum_root_path/$short_path/$qpkg_filename" ]] && cp "$checksum_root_path/$short_path/$qpkg_filename" "$qpkgs_staging_path"
done <<< "$highest_table"

[[ $debug = true ]] || ShowDone

exit 0
