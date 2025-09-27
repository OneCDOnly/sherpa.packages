#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

arch=''
buffer=''
debug=false
hash=''
highest_table=''
package_name=''
packages_epoch=$(date +%s)
qpkg_filename=''
short_path=''
source=$qpkgs_support_path/$packages_source_file
	buffer=$(<"$source")
target=$qpkgs_support_path/$packages_file
version=''

[[ $1 = debug ]] && debug=true
# debug=true

if [[ -e $highest_package_versions_found_pathfile ]]; then
	highest_table="$(StripComments "$(<"$highest_package_versions_found_pathfile")")"
else
	echo; TextBrightRed "file '$highest_package_versions_found_pathfile' not found"; echo
	exit 1
fi

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

[[ -e $target ]] && chmod +w "$target"
echo "$buffer" > "$target"
SwapTags "$source" "$target" > /dev/null
buffer=$(<"$target")

echo -n 'process placeholders ... '
[[ $debug = true ]] && echo

while read -r qpkg_filename package_name version arch short_path hash; do
	[[ $debug = true ]] && echo "found new package_name/arch: '$package_name/$arch'"

	for property in version package_name qpkg_filename hash; do
		# multi-line regex: https://superuser.com/questions/1766993/find-and-replace-text-in-a-file-only-after-2-different-patterns-match-using-sed

		buffer=$(sed "/r_qpkg_name+=(${package_name})/,/^$/{/r_qpkg_arch+=(${arch})/,/r_qpkg_url+=/s/<?${property}?>/${!property}/}" <<< "$buffer")

		case $package_name in
			nzbget|QDK)
				if [[ $property = version ]]; then
					# Run this a second time as there are 2 version placeholders in 'packages.source' for nzbget and QDK.

					# echo "running a second swap: QPKG '$package_name', arch '$arch', property '$property', value '${!property}'"
					buffer=$(sed "/r_qpkg_name+=(${package_name})/,/^$/{/r_qpkg_arch+=(${arch})/,/r_qpkg_url+=/s/<?${property}?>/${!property}/}" <<< "$buffer")
				fi
		esac

		# If arch = 'none' then package is not installable, so write 'none' to all fields.

		buffer=$(sed "/r_qpkg_name+=(${package_name})/,/^$/{/r_qpkg_arch+=(none)/,/r_qpkg_url+=/s/<?${property}?>/none/}" <<< "$buffer")
	done
done <<< "$highest_table"

[[ $debug = true ]] || ShowDone

echo -n "write package file ... "
[[ $debug = true ]] && echo

echo "$buffer" > "$target"

if [[ ! -e $target ]]; then
	TextBrightRed "file '$target' was not written to disk"; echo
	exit 1
else
	Squeeze "$target" "$target" > /dev/null
	chmod 444 "$target"
fi

[[ $debug = true ]] || ShowDone

[[ $SHLVL -eq 2 ]] && CheckPlaceholdersInPackages			# Only check when running this script manually.

exit 0
