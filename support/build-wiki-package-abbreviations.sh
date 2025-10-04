#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

objects_built=false

LoadObjects()
	{

	readonly r_objects_pathfile=$support_path/$objects_file

	if [[ ! -e $r_objects_pathfile ]]; then
		$support_path/build-objects.sh &>/dev/null
		objects_built=true
	fi

	if [[ -e $r_objects_pathfile ]]; then
		. "$r_objects_pathfile"
	else
		echo 'unable to load objects: file missing'
		return 1
	fi

	return 0

	}

LoadPackages()
	{

	local f=''

	for f in "$qpkgs_support_path"/*.packages.source; do
		. "$f"
	done

	QPKGs-GRall:Add "$(SortNames "${r_qpkg_name[*]}")"

	}

echo -n "building wiki 'Package abbreviations' page ... "

a=$wiki_path/Package-abbreviations.md

LoadObjects
LoadPackages 2>/dev/null	# packages source file throws a lot of syntax errors until it's processed - ignore these.

	{

	echo -e '![Static Badge](https://img.shields.io/badge/page_status-live-green?style=for-the-badge)\n'
	echo -e 'These abbreviations are recognised by **sherpa** and may be used in-place of each [package name](Packages):\n'
	echo '| package name | acceptable abbreviations |'
	echo '| ---: | :--- |'

	} > "$a"

for b in $(QPKGs-GRall:Array); do
	abs=$(QPKGAbbrvs "$b")
	echo "| $b | \`${abs// /\` \`}\` |" >> "$a"
done

[[ $objects_built = true ]] && rm -f "$r_objects_pathfile"

ShowDone
exit 0
