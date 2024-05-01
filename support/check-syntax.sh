#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/vars.source || exit

declare -a a
declare -a b
declare -i i=0

a+=("$qpkgs_support_path/$service_library_source_file")
b+=(1087,1090,1117,2012,2015,2016,2018,2019,2034,2086,2119,2120,2128,2155,2181,2194,2206,2207,2254)

a+=("$qpkgs_support_path/$packages_source_file")
b+=(1009,1036,1072,1073,1088,2034)

# a+=("$qpkgs_support_path/*.sh")
# b+=(1036,1090,1091,2001,2006,2012,2016,2028,2034,2054,2086,2154,2155)

for i in "${!a[@]}"; do
	echo -n "checking '${a[i]}' ... "

	if shellcheck --shell=bash --exclude="${b[i]}" "${a[i]}"; then
		ShowPassed
	else
		ShowFailed
		exit 1
	fi
done

exit 0
