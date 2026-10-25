#!/usr/bin/env bash


declare -i max=0

while IFS= read -r line; do
	(( ${#line} > max )) && max=${#line}
done <<< $(grep --no-filename '^r_qpkg_description' *.packages.source | sed 's|^r_qpkg_description+=(||;s|)$||' | sort | uniq)

echo "$max"
