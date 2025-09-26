#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

arch=''
checksum_filename=''
checksum_pathfilename=''
hash=''
highest_table=''
package_name=''
qpkg_filename=''
qpkg_pathfilename=''
re=''
short_path=''
version=''

[[ ! -f $highest_package_versions_found_pathfile ]] && ./build-multiple-packages.sh

if [[ -e $highest_package_versions_found_pathfile ]]; then
	highest_table="$(StripComments "$(<"$highest_package_versions_found_pathfile")")"
else
	echo; TextBrightRed "file '$highest_package_versions_found_pathfile' not found"; echo
	exit 1
fi

echo -n 'loading latest QPKG versions ... '

while read -r qpkg_filename package_name version arch short_path hash; do
	highest_qpkg_pathfilenames+=($checksum_root_path/$short_path/$qpkg_filename)
done <<< "$highest_table"

ShowDone

echo -n 'looking for obsolete QPKG versions ... '

while read -r checksum_pathfilename; do
	qpkg_pathfilename=${checksum_pathfilename//.md5/}

	[[ -e $qpkg_pathfilename ]] || continue			# Ignore MD5 files without QPKG files like QDK.

 	checksum_filename=$(basename "$checksum_pathfilename")
	qpkg_filename=${checksum_filename//.md5/}
	re=\\b$qpkg_filename\\b

	if ! [[ ${highest_qpkg_pathfilenames[*]} =~ $re ]]; then
		[[ -e $qpkg_pathfilename ]] && pathfiles_to_delete+=($qpkg_pathfilename)
		[[ -e $checksum_pathfilename ]] && pathfiles_to_delete+=($checksum_pathfilename)
	fi
done <<< "$(find "$qpkgs_root_path" -name '*.qpkg.md5')"	# Scan for MD5 files only. If an MD5 doesn't exist for a QPKG file, ignore the QPKG file.

ShowDone

# echo "pathfiles_to_delete: [${pathfiles_to_delete[*]}]" | tr ' ' '\n'

echo -n 'deleting obsolete QPKG versions ... '

for f in ${pathfiles_to_delete[*]}; do
	rm -f "$f"
# 	echo "deleted: '$f'"
done

ShowDone

echo 'running garbage collection ... '

this_path="$PWD"
cd "$qpkgs_root_path" || exit
# git gc --aggressive || exit
git gc || exit
cd "$this_path" || exit

ShowDone

exit 0
