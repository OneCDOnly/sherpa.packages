#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/vars.source || exit

[[ ! -f $highest_package_versions_found_sorted_pathfile ]] && ./build-packages.sh

echo -n 'loading latest QPKG versions ... '

while read -r checksum_filename qpkg_filename package_name version arch hash; do
	highest_checksum_filenames+=($checksum_filename)
	highest_qpkg_filenames+=($qpkg_filename)
done <<< "$(sed -e '/^#[[:space:]].*/d;/#$/d;s/[[:space:]]#[[:space:]].*//' "$highest_package_versions_found_sorted_pathfile")"

ShowDone

echo -n 'scanning QPKG files ... '

raw=$(find "$qpkgs_root_path" -name '*.qpkg.md5')

ShowDone

echo -n 'looking for obsolete QPKG versions ... '

while read -r checksum_pathfilename; do
	checksum_filename=$(basename "$checksum_pathfilename")
	re=\\b$checksum_filename\\b

	if ! [[ ${highest_checksum_filenames[*]} =~ $re ]]; then
		files_to_delete+=($checksum_pathfilename)
		files_to_delete+=(${checksum_pathfilename//.md5/})
	fi
done <<< "$raw"

ShowDone

echo -n 'deleting obsolete QPKG versions ... '

for file_to_delete in ${files_to_delete[*]}; do
	rm -f "$file_to_delete"
done

ShowDone

this_path=$PWD
cd "$qpkgs_root_path" || exit
git gc --aggressive || exit
cd "$this_path" || exit

exit 0
