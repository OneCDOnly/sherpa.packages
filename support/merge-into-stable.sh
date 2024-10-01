#!/usr/bin/env bash

. $HOME/scripts/nas/sherpa/support/vars.source || exit

echo -en "ready to merge '$(ColourTextBrightRed "$unstable_branch")' branch into '$(ColourTextBrightGreen "$stable_branch")' branch: proceed? "
read -rn1 response
echo

case ${response:0:1} in
	y|Y)
		: # OK to continue
		;;
	*)
		exit 0
esac

cd "$qpkgs_support_path" || exit

./build-all.sh || exit
./commit.sh '[update] archives [pre-merge]' || exit

cd "$qpkgs_root_path" || exit

git checkout "$stable_branch" || exit
git merge --no-ff -m "[merge] from \`$unstable_branch\` into \`$stable_branch\`" "$unstable_branch" && git push || exit
git checkout "$unstable_branch" || exit

cd "$qpkgs_support_path" || exit

./reset-qpkg-datetimes.sh || exit
git diff			# run this now so don't need to wait during manual (user) check.
