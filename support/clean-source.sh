#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/environment.sourced || exit

declare -a a
declare -i i=0

a+=("$service_library_source_file")

for i in "${!a[@]}"; do
	echo -n "cleaning '${a[i]}' ... "

	touch --reference="$qpkgs_support_path"/"${a[i]}" /tmp/"$i".tmp
	sed -i 's|[ ][\t]|\t|' "$qpkgs_support_path"/${a[i]}					# remove leading space char left by Kate line commenter/uncommenter
	touch --reference=/tmp/"$i".tmp "$qpkgs_support_path"/"${a[i]}"

	ShowDone
done

exit 0
