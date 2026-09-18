#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

GetCodeStringArrayValues()
	{

	# Return value from within round brackets in a virtual code line.

	local a=${1#*\(}

	printf '%s' "${a%\)*}"

	}

SortNames()
	{

	# Inputs: (local)
	#	$1 = string with space-separated words. Duplicate words will be removed.

	[[ -n ${1:-} ]] || return

	local a=''
	local b=''
	local c=''
	local d=''

	if (/usr/bin/sort -f < /dev/null &> /dev/null); then	# Only use the ignore-case option '-f' if supported by 'sort'.
		tr ' ' '\n' <<< "$1" | /usr/bin/sort -f | /bin/uniq | tr '\n' ' '
	else													# If only basic 'sort' is available, sort the hard-way.
		a=$(tr ' ' '\n' <<< "$(Lowercase "$1")" | /usr/bin/sort | /bin/uniq | tr '\n' ' ')

		for b in $a; do
			for c in $1; do
				[[ $(Lowercase "$c") = "$b" ]] || continue
				d+=" $c"

				break
			done
		done

		[[ -n $d ]] && tr '\n' ' ' <<< "$d"
	fi

	}

declare a=''
declare arch=''
declare -a arches
declare b=''
declare buffer=''
declare debug=false
declare f=''
declare hash=''
declare highest_table=''
declare package_name=''
declare packages_epoch=$(date +%s)
declare qpkg_filename=''
declare short_path=''
declare source=''
declare target=''
declare version=''
declare newline=$'\n'

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

a=$qpkgs_pypi_module_lists_path/base.txt

if [[ -e $a ]]; then
	base_pips=$(/bin/tr '\n' ' ' <<< "$(StripComments "$(<"$a")")")
	base_pips=${base_pips%* }
	base_pips=${base_pips,,}
fi

a=$qpkgs_pypi_module_lists_path/excluded.txt

if [[ -e $a ]]; then
	exclusion_pips=$(/bin/tr '\n' ' ' <<< "$(StripComments "$(<"$a")")")
	exclusion_pips=${exclusion_pips%* }
	exclusion_pips=${exclusion_pips,,}
fi

echo -n 'find: package arches and init package files ... '
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

			declare $b="$(StripComments "$(< $target)")"

			[[ $debug = true ]] && echo "└─ created new arch buffer '$b' and loaded with contents of '$(basename $target)'"
		fi
	fi
done <<< "$highest_table"

[[ $debug = true ]] || ShowDone
[[ $debug = true ]] && echo "found ${#arches[@]} package arches (including 'all')"

echo -n 'process: placeholders ... '
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
					# Must run this a second time as there are 2 version placeholders in '*.packages.source' for nzbget and QDK.

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

# debug=true

# exit

echo -n "write: package databases ... "
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

	# Build tier lists.

	buffer=buffer_$arch

	declare -a all=()
	declare -a independents=()
	declare -a dependents=()
	declare -a optionals=()
	declare -a sorted=()

	readarray -t lines <<< "$(grep -E '^r_qpkg_(name|depends_on|opt_depends_on)\+\=' <<< "${!buffer}")"

	for ((i=0; i<${#lines[@]}; i++)); do
		name="${lines[i]}"
		[[ -n "$name" ]] || continue
		grep -E '^r_qpkg_name' &> /dev/null <<< "$name" || continue		# Only match lines with QPKG internal name.

		depends="${lines[i+1]}"
		[[ -n "$depends" ]] || continue

		opt_depends="${lines[i+2]}"
		[[ -n "$opt_depends" ]] || continue

		name=$(GetCodeStringArrayValues "$name")
		depends=$(GetCodeStringArrayValues "$depends")
		opt_depends=$(GetCodeStringArrayValues "$opt_depends")

		if [[ $opt_depends != none ]]; then
			[[ $debug = true ]] && echo "'$name' optionally depends on '$opt_depends', therefore '$opt_depends' is $(TextBrightYellow optional)"
			optionals+=($opt_depends)
		fi

		if [[ $depends != none ]]; then
			[[ $debug = true ]] && echo "'$name' depends on '$depends', therefore '$name' is $(TextBrightOrange dependent)"
			dependents+=($name)
		fi

		if [[ $depends = none && $opt_depends = none ]]; then
			[[ $debug = true ]] && echo "'$name' is $(TextBrightGreen independent)"
			independents+=($name)
		fi
	done

	# Must `sort` & `uniq` each tier array to remove duplicates.

	sorted=($(SortNames "${dependents[*]} ${independents[*]} ${optionals[*]}")); all=(${sorted[@]})
	sorted=($(SortNames "${dependents[*]}")); dependents=(${sorted[@]})
	sorted=($(SortNames "${independents[*]}")); independents=(${sorted[@]})
	sorted=($(SortNames "${optionals[*]}")); optionals=(${sorted[@]})

	[[ $debug = true ]] && echo "all:"
	[[ $debug = true ]] && printf '%s\n' "${all[@]}"

	[[ $debug = true ]] && echo "dependents:"
	[[ $debug = true ]] && printf '%s\n' "${dependents[@]}"

	[[ $debug = true ]] && echo "independents:"
	[[ $debug = true ]] && printf '%s\n' "${independents[@]}"

	[[ $debug = true ]] && echo "optionals:"
	[[ $debug = true ]] && printf '%s\n' "${optionals[@]}"

	# Append each tier array as a separate array line to buffer_$arch.

	declare buffer_${arch}+="${newline}r_qpkg_names_all=('${all[*]}')${newline}"
	declare buffer_${arch}+="r_qpkg_names_dependent=('${dependents[*]}')${newline}"
	declare buffer_${arch}+="r_qpkg_names_independent=('${independents[*]}')${newline}"
	declare buffer_${arch}+="r_qpkg_names_optional=('${optionals[*]}')${newline}"

	[[ $debug = true ]] && echo "--- end of $arch ------------------------------------------------------------------------------"

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
