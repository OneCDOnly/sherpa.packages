#!/usr/bin/env bash

# Set all QPKG file change datetimes to that of current sherpa QPKG release file.
# 	Must also update datetime of sherpa function library files.
# 	Auto QPKG rebuilder should therefore ignore datetimes updated by git during 'git checkout'. However, all these files will need to be pushed again, as git will see them as modified since last push.

. $HOME/scripts/nas/sherpa/support/vars.source || exit

# latest_release=$(git -C "$root_path" describe --tags "$(git -C "$root_path" rev-list --tags --max-count=1)" | tr --delete v)
# latest_release_pathfile=$qpkgs_path/sherpa/build/sherpa_${latest_release}.qpkg

a=$(cd "$qpkgs_path/sherpa/build" || exit; ls -t1 --reverse | tail -n1)

if [[ -n $a ]]; then
	echo "datetime reference file: '$a'"
	latest_release_pathfile=$qpkgs_path/sherpa/build/$a
else
	echo 'datetime reference file could not be determined'
	exit 1
fi

if [[ ! -e $latest_release_pathfile ]]; then
	echo "datetime reference file not found: '$latest_release_pathfile'"
	exit 1
fi

echo "latest release file: $latest_release_pathfile"

find "$qpkgs_path" -not -path '*/.*' -not -path '*/workshop*' -not -path '*/docs*' -not -path '*/support*' -not -name '*.tar.gz' -type f -exec touch {} -r "$latest_release_pathfile" \;

touch "$service_library_source_file" -r "$latest_release_pathfile"
touch "$service_library_file" -r "$latest_release_pathfile"

exit 0
