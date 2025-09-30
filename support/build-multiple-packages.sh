#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

arch=''
declare -a arches
b=''
buffer=''
debug=false
f=''
hash=''
highest_table=''
package_name=''
packages_epoch=$(date +%s)
qpkg_filename=''
short_path=''
source=''
target=''
version=''

[[ $1 = debug ]] && debug=true
# debug=true

if [[ -e $highest_package_versions_found_pathfile ]]; then
	highest_table="$(StripComments "$(<"$highest_package_versions_found_pathfile")")"
else
	echo; TextBrightRed "file '$highest_package_versions_found_pathfile' not found"; echo
	exit 1
fi

rm -f "${qpkgs_support_path:?undefined}"/*.packages

a=$qpkgs_support_path/ipk-essential.txt

if [[ -e $a ]]; then
	essential_ipks=$(/bin/tr '\n' ' ' <<< "$(StripComments "$(<"$a")")")
	essential_ipks=${essential_ipks%* }
	essential_ipks=${essential_ipks,,}
fi

a=$qpkgs_support_path/pip-essential.txt

if [[ -e $a ]]; then
	essential_pips=$(/bin/tr '\n' ' ' <<< "$(StripComments "$(<"$a")")")
	essential_pips=${essential_pips%* }
	essential_pips=${essential_pips,,}
fi

a=$qpkgs_support_path/pip-exclusions.txt

if [[ -e $a ]]; then
	exclusion_pips=$(/bin/tr '\n' ' ' <<< "$(StripComments "$(<"$a")")")
	exclusion_pips=${exclusion_pips%* }
	exclusion_pips=${exclusion_pips,,}
fi

echo -n 'find package arches and init package files ... '
[[ $debug = true ]] && echo

while read -r qpkg_filename package_name version arch short_path hash; do
	[[ $debug = true ]] && echo "found new package_name/arch: '$package_name/$arch'"
	b=buffer_$arch

	if [[ -z ${!b} ]]; then
		[[ $debug = true ]] && echo "└─ found new arch: '$arch'"
		arches+=($arch)
		source=$qpkgs_support_path/$arch.packages.source
		target=$qpkgs_support_path/$arch.packages

		if [[ ! -e $source ]]; then
			echo; TextBrightRed "unable to load '$(basename $source)' as it doesn't exist"; echo
		else
			if [[ $debug = true ]]; then
				echo -n "└─ "; SwapTags "$source" "$target"
			else
				SwapTags "$source" "$target" > /dev/null
			fi

			declare $b="$(StripComments "$(<$target)")"

			[[ $debug = true ]] && echo "└─ created new arch buffer '$b' and loaded with contents of '$(basename $target)'"
		fi
	fi
done <<< "$highest_table"

[[ $debug = true ]] || ShowDone
[[ $debug = true ]] && echo "found ${#arches[@]} package arches (including 'all')"

echo -n 'process placeholders ... '
[[ $debug = true ]] && echo

while read -r qpkg_filename package_name version arch short_path hash; do
	b=buffer_$arch

	for property in version package_name qpkg_filename hash; do
		# multi-line regex: https://superuser.com/questions/1766993/find-and-replace-text-in-a-file-only-after-2-different-patterns-match-using-sed

		buffer=$(sed "/r_qpkg_name+=(${package_name})/,/r_qpkg_url+=/s/<?${property}?>/${!property}/" <<< "${!b}")
		declare $b="$buffer"

		case $package_name in
			nzbget|QDK)
				if [[ $property = version ]]; then
					# Run this a second time as there are 2 version placeholders in '*.packages.source' for nzbget and QDK.

					[[ $debug = true ]] && echo "└─ running a second swap: QPKG '$package_name', arch '$arch', property '$property', value '${!property}'"
					buffer=$(sed "/r_qpkg_name+=(${package_name})/,/r_qpkg_url+=/s/<?${property}?>/${!property}/" <<< "${!b}")
					declare $b="$buffer"
				fi
		esac

		# If arch is 'none' then package is not installable, so write 'none' to all fields.

		buffer=$(sed "/r_qpkg_name+=(${package_name})/,/r_qpkg_url+=/s/<?${property}?>/none/" <<< "${!b}")
		declare $b="$buffer"
	done
done <<< "$highest_table"

[[ $debug = true ]] || ShowDone

echo -n "write package files ... "
[[ $debug = true ]] && echo

for arch in "${arches[@]}"; do
	target=$qpkgs_support_path/$arch.packages

	if [[ $arch = all ]]; then			# Don't build an 'all.packages' file. QPKGs to suit all arches are appended to each arch package list.
		rm -f "$target"
		continue
	fi

	[[ $debug = true ]] && echo -n "write file '$(basename $target)' ... "
	buffer=buffer_$arch

	# Add non-arch-specific ('all') packages to the end of each arch list.

	declare buffer_$arch="${!buffer}"$'\n'"$buffer_all"
	echo "${!buffer}" > "$target"

	if [[ ! -e $target ]]; then
		echo; TextBrightRed "file '$target' was not written to disk"; echo
		exit 1
	else
		Squeeze "$target" "$target" > /dev/null
		chmod 444 "$target"
		[[ $debug = true ]] && ShowDone
	fi
done

[[ $debug = true ]] || ShowDone

[[ $SHLVL -eq 2 ]] && CheckPlaceholdersInMultiplePackages			# Only check when running this script manually.

exit 0
