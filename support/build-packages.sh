#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

arch=''
buffer=''
checksum_filename=''
hash=''
package_name=''
packages_epoch=$(date +%s)
qpkg_filename=''
source=$qpkgs_support_path/$packages_source_file
target=$qpkgs_support_path/$packages_file
version=''

buffer=$(<"$source")

[[ $1 = debug ]] && debug=true
# debug=true							# Force this for-now.

echo -n 'loading IPK essentials ... '

a=$qpkgs_support_path/ipk-essential.txt

if [[ -e $a ]]; then
	essential_ipks=$(/bin/tr '\n' ' ' <<< "$(StripComments "$(<"$a")")")
	essential_ipks=${essential_ipks%* }
	essential_ipks=${essential_ipks,,}
fi

ShowDone

echo -n 'loading PIP essentials ... '

a=$qpkgs_support_path/pip-essential.txt

if [[ -e $a ]]; then
	essential_pips=$(/bin/tr '\n' ' ' <<< "$(StripComments "$(<"$a")")")
	essential_pips=${essential_pips%* }
	essential_pips=${essential_pips,,}
fi

ShowDone

echo -n 'loading PIP exclusions ... '

a=$qpkgs_support_path/pip-exclusions.txt

if [[ -e $a ]]; then
	exclusion_pips=$(/bin/tr '\n' ' ' <<< "$(StripComments "$(<"$a")")")
	exclusion_pips=${exclusion_pips%* }
	exclusion_pips=${exclusion_pips,,}
fi

ShowDone

[[ -e $target ]] && chmod +w "$target"
echo "$buffer" > "$target"
SwapTags "$source" "$target"
buffer=$(<"$target")

echo -n 'updating QPKG fields ... '
[[ $debug = true ]] && echo

while read -r checksum_filename qpkg_filename package_name version arch hash; do
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
done <<< "$(StripComments "$(<"$highest_package_versions_found_pathfile")")"

[[ $debug = true ]] || ShowDone

[[ $debug = true ]] && echo -n "building $(basename $target) file ... "

echo "$buffer" > "$target"

if [[ ! -e $target ]]; then
	TextBrightRed "'$target' was not written to disk"; echo
	exit 1
else
	Squeeze "$target" "$target"
	[[ -f $target ]] && chmod 444 "$target"
	[[ $debug = true ]] && ShowDone
fi


if grep -q '<?\|?>' "$target"; then
	TextBrightRed "'$target' contains unswapped tags, can't continue"; echo
	exit 1
fi

exit 0
