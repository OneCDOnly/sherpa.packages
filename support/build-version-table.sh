#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

arch=''
checksum_filename=''
checksum_pathfilename=''
match=false
package_name=''
package_versions_raw_pathfile=$qpkgs_support_path/package_versions.raw
previous_arch=''
previous_package_name=''
previous_version=''
qpkg_filename=''
short_path=''
tailend=''
version=''

echo -n 'locating QPKG checksum files ... '

raw=$(find "$checksum_root_path" -name '*.qpkg.md5')

ShowDone

echo -n 'extracting highest QPKG version numbers ... '

sorted=$(sort --version-sort --reverse <<< "$raw")

while read -r checksum_pathfilename; do
	checksum_filename=$(basename "$checksum_pathfilename")
	qpkg_filename=${checksum_filename//.md5/}

	IFS='_' read -r package_name version arch tailend <<< "${checksum_filename//.qpkg.md5/}"

	if [[ $arch = std ]]; then     						# Exception for Entware.
		arch=''
		tailend=''
	fi

	[[ -n $tailend ]] && arch+=_$tailend

	if [[ ${version##*.} = zip ]]; then					# Exception for QDK.
		version=${version%.*}
	fi

	if [[ ${qpkg_filename: -9} = .zip.qpkg ]]; then		# Another exception for QDK.
		qpkg_filename=${qpkg_filename%.*}
	fi

	if [[ $package_name != "$previous_package_name" ]]; then
		match=true
	elif [[ $version = "$previous_version" ]]; then
		if [[ $arch != "$previous_arch" ]]; then
			match=true
		fi
	else
		match=false
	fi

	if [[ $match = true ]]; then
		short_path=$(dirname "$checksum_pathfilename"); short_path=${short_path#$checksum_root_path$'/'}

# 		printf '%-36s %-32s %-20s %-12s %-6s %-40s %s\n' "$checksum_filename" "$qpkg_filename" "$package_name" "$version" "$(TranslateQPKGArch "$arch")" "$short_path" "$(cut -d' ' -f1 < "$checksum_pathfilename")"
		printf '%-32s %-20s %-12s %-6s %-40s %s\n' "$qpkg_filename" "$package_name" "$version" "$(TranslateQPKGArch "$arch")" "$short_path" "$(cut -d' ' -f1 < "$checksum_pathfilename")"

		previous_package_name=$package_name
		previous_version=$version
		previous_arch=$arch
	fi
done <<< "$sorted" | uniq > "$package_versions_raw_pathfile"

ShowDone

# Add header line for easier viewing.

[[ -f $highest_package_versions_found_pathfile ]] && chmod 644 "$highest_package_versions_found_pathfile"
# printf '%-36s %-32s %-20s %-12s %-6s %-40s %s\n%s\n' '# checksum_filename' qpkg_filename package_name version arch short_path hash "$(sort "$package_versions_raw_pathfile")" > "$highest_package_versions_found_pathfile"
printf '%-32s %-20s %-12s %-6s %-40s %s\n%s\n' '# qpkg_filename' package_name version arch short_path hash "$(sort "$package_versions_raw_pathfile")" > "$highest_package_versions_found_pathfile"

rm -f "$package_versions_raw_pathfile"
[[ -f $highest_package_versions_found_pathfile ]] && chmod 444 "$highest_package_versions_found_pathfile"

exit 0
