#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

arch=''
declare -a arches
b=''
buffer=''
checksum_filename=''
debug=false
f=''
hash=''
package_name=''
packages_epoch=$(date +%s)
qpkg_filename=''
short_path=''
source=''
target=''
version=''

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

echo -n 'replacing placeholders ... '
[[ $debug = true ]] && echo

while read -r checksum_filename qpkg_filename package_name version arch short_path hash; do
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

		# If arch = 'none' then package is not installable, so write 'none' to all fields.

		buffer=$(sed "/r_qpkg_name+=(${package_name})/,/r_qpkg_url+=/s/<?${property}?>/none/" <<< "${!b}")
		declare $b="$buffer"
	done

	# Copy highest build version of this QPKG to release path.

	[[ -e "$checksum_root_path/$short_path/$qpkg_filename" ]] && cp "$checksum_root_path/$short_path/$qpkg_filename" "$qpkgs_staging_path"
done <<< "$(StripComments "$(<"$highest_package_versions_found_pathfile")")"

[[ $debug = true ]] || ShowDone

[[ $debug = true ]] && echo "found ${#arches[@]} package arches (including 'all')"

echo -n "building package files ... "
[[ $debug = true ]] && echo

for arch in "${arches[@]}"; do
	target=$qpkgs_support_path/$arch.packages

	if [[ $arch = all ]]; then			# Don't build an 'all.packages' file. QPKGs to suit all arches are appended to each arch package list.
		rm -f "$target"
		continue
	fi

	[[ $debug = true ]] && echo -n "building '$(basename $target)' file ... "
	buffer=buffer_$arch

	# Add non-arch-specific ('all') packages to the end of each arch list.

	declare buffer_$arch="${!buffer}"$'\n'"$buffer_all"
	echo "${!buffer}" > "$target"

	if [[ ! -e $target ]]; then
		echo; TextBrightRed "'$target' was not written to disk"; echo
		exit 1
	else
		Squeeze "$target" "$target" > /dev/null
		chmod 444 "$target"
		[[ $debug = true ]] && ShowDone
	fi
done

[[ $debug = true ]] || ShowDone

echo -n 'checking all placeholders have been replaced ... '

for f in $qpkgs_support_path/*.packages; do
	if grep -q '<?\|?>' "$f"; then
		echo; TextBrightRed "'$f' contains unprocessed placeholders, can't continue"; echo
		exit 1
	fi
done

ShowDone

exit 0
