#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/vars.source || exit

source=$qpkgs_support_path/$packages_source_file
target=$qpkgs_support_path/$packages_file

buffer=$(<"$source")

checksum_pathfilename=''
checksum_filename=''
qpkg_filename=''
package_name=''
version=''
arch=''
hash=''
previous_package_name=''
previous_version=''
previous_arch=''
match=false
packages_epoch=$(date +%s)

TranslateQPKGArch()
	{

	# Translate arch from QPKG filename to sherpa arch.
	# sherpa arch for target NAS is a single 3 character-code.
	# 'a' for ARM, 'i' for Intel.

	case $1 in
		x86_ce53xx)
			printf i53			# For TS-269H only.
			;;
		i686|x86)
			printf i86
			;;
		x86_64)
			printf i64
			;;
		arm-x19)
			printf a19
			;;
		arm-x31)
			printf a31
			;;
		arm-x41)
			printf a41
			;;
		arm_64)
			printf a64
			;;
		'')
			printf all
			;;
		*)
			echo "${1::3}"		# passthru first 3 characters only.
	esac

	}

StripComments()
	{

	# Input:
	#   $1 = string to strip comment lines, empty lines, and so-on.

	# Output:
	#   stdout = stripped string.

	[[ -n $1 ]] || return

	local a="$1"

	a=$(/bin/sed -e '/^#[[:space:]].*/d;/#$/d;s/[[:space:]]#[[:space:]].*//' <<< "$a")		# Remove comment lines and line comments.
	a=$(/bin/sed -e 's/^[[:space:]]*//' <<< "$a")											# Remove leading whitespace.
	a=$(/bin/sed 's/[[:space:]]*$//' <<< "$a")												# Remove trailing whitespace.
	a=$(/bin/sed "/^$/d" <<< "$a")															# Remove empty lines.

	echo "$a"

	}

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
		printf '%-36s %-32s %-20s %-12s %-6s %s\n' "$checksum_filename" "$qpkg_filename" "$package_name" "$version" "$(TranslateQPKGArch "$arch")" "$(cut -d' ' -f1 < "$checksum_pathfilename")"
		previous_package_name=$package_name
		previous_version=$version
		previous_arch=$arch
	fi
done <<< "$sorted" | uniq > "$highest_package_versions_found_pathfile"

ShowDone

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

# multi-line regex: https://superuser.com/questions/1766993/find-and-replace-text-in-a-file-only-after-2-different-patterns-match-using-sed

while read -r checksum_filename qpkg_filename package_name version arch hash; do
	for property in version package_name qpkg_filename hash; do
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
done <<< "$(sort "$highest_package_versions_found_pathfile")"

ShowDone

echo -n "building 'packages' file ... "

echo "$buffer" > "$target"

if [[ ! -e $target ]]; then
	ColourTextBrightRed "'$target' was not written to disk"; echo
	exit 1
else
	ShowDone
fi

if grep -q '<?\|?>' "$target"; then
	ColourTextBrightRed "'$target' contains unswapped tags, can't continue"; echo
	exit 1
fi

Squeeze "$target" "$target"
[[ -f $target ]] && chmod 444 "$target"

# Sort and add header line for easier viewing.

[[ -f $highest_package_versions_found_sorted_pathfile ]] && chmod 644 "$highest_package_versions_found_sorted_pathfile"
printf '%-36s %-32s %-20s %-12s %-6s %s\n%s\n' '# checksum_filename' qpkg_filename package_name version arch hash "$(sort "$highest_package_versions_found_pathfile")" > "$highest_package_versions_found_sorted_pathfile"

rm -f "$highest_package_versions_found_pathfile"
[[ -f $highest_package_versions_found_sorted_pathfile ]] && chmod 444 "$highest_package_versions_found_sorted_pathfile"

exit 0
