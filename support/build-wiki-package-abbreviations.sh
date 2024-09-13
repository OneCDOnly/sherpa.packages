#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/vars.source || exit

objects_built=false

Objects:Load()
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

Packages:Load()
	{

	readonly r_packages_pathfile=$qpkgs_support_path/$packages_source_file

	if [[ ! -e $r_packages_pathfile ]]; then
		echo 'package list missing'
		exit 1
	fi

	. "$r_packages_pathfile"

	readonly r_base_qpkg_conflicts_with
	readonly r_base_qpkg_warnings
	readonly r_essential_ipks
	readonly r_essential_pips
	readonly r_exclusion_pips
	readonly r_min_perl_version
	readonly r_min_python_version
	readonly r_packages_epoch

	# Package list arrays are now full, so lock them.
	readonly r_qpkg_abbrvs
	readonly r_qpkg_appl_author
	readonly r_qpkg_appl_author_email
	readonly r_qpkg_appl_version
	readonly r_qpkg_arch
	readonly r_qpkg_author
	readonly r_qpkg_author_email
	readonly r_qpkg_can_backup
	readonly r_qpkg_can_clean
	readonly r_qpkg_can_log
	readonly r_qpkg_can_restart_to_update
	readonly r_qpkg_conflicts_with
	readonly r_qpkg_depends_on
	readonly r_qpkg_description
	readonly r_qpkg_hash
	readonly r_qpkg_is_sherpa_compatible
	readonly r_qpkg_max_os_version
	readonly r_qpkg_min_os_version
	readonly r_qpkg_min_ram_kb
	readonly r_qpkg_name
	readonly r_qpkg_note
	readonly r_qpkg_requires_ipks
	readonly r_qpkg_test_for_active
	readonly r_qpkg_url
	readonly r_qpkg_version

	QPKGs-GRall:Add "${r_qpkg_name[*]}"

	}

echo -n "building wiki 'Package abbreviations' page ... "

a=$wiki_path/Package-abbreviations.md

Objects:Load
Packages:Load 2>/dev/null	# packages source file throws a lot of syntax errors until it's processed - ignore these.

	{

	echo -e '![Static Badge](https://img.shields.io/badge/page_status-live-green?style=for-the-badge)\n'
	echo -e 'These abbreviations are recognised by **sherpa** and may be used in-place of each [package name](Packages):\n'
	echo '| package name | acceptable abbreviations |'
	echo '| ---: | :--- |'

	} > "$a"

for b in $(QPKGs-GRall:Array); do
	abs=$(QPKG.Abbrvs "$b")
	echo "| $b | \`${abs// /\` \`}\` |" >> "$a"
done

[[ $objects_built = true ]] && rm -f "$r_objects_pathfile"

ShowDone
exit 0
