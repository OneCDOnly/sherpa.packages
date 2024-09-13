#!/usr/bin/env bash
#* Please don't edit this file directly, it was built/modified programmatically with the 'build-qpkgs.sh' script. (source: 'sherpa-loader.source')
#* sherpa-loader.sh
#* copyright (C) 2017-2024 OneCD.
#* Contact:
#*   one.cd.only@gmail.com
#* Description:
#*	 This is the loader script for the sherpa mini-package-manager and is part of the `sherpa` QPKG.
#* Project:
#*	 https://git.io/sherpa
#* Forum:
#*	 https://forum.qnap.com/viewtopic.php?t=132373
#* Tested on:
#*	 GNU bash, version 3.2.57(2)-release (i686-pc-linux-gnu)
#*	 GNU bash, version 3.2.57(1)-release (aarch64-QNAP-linux-gnu)
#*	   Copyright (C) 2007 Free Software Foundation, Inc.
#*   ... and periodically on:
#*	 GNU bash, version 5.0.17(1)-release (aarch64-openwrt-linux-gnu)
#*	   Copyright (C) 2019 Free Software Foundation, Inc.
#* License:
#*   This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#*	 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#*	 You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/
readonly r_user_args_raw=$*
Init()
{
export LOADER_SCRIPT_VERSION='240914'
export LOADER_SCRIPT_PPID=$PPID
readonly r_qpkg_name=sherpa
readonly r_chars_regular_prompt='$ '
readonly r_chars_super_prompt='# '
readonly r_chars_sudo_prompt="${r_chars_regular_prompt}sudo "
IsQNAP || return
IsSU || return
local source_git_branch=stable
local test_branch=$(/sbin/getcfg $r_qpkg_name Git_Branch -d unknown -f /etc/config/qpkg.conf)
if [[ $test_branch = unknown ]];then
/sbin/setcfg $r_qpkg_name Git_Branch $source_git_branch -f /etc/config/qpkg.conf
else
source_git_branch=$test_branch
fi
local -r r_work_path=$(/sbin/getcfg sherpa Install_Path -f /etc/config/qpkg.conf)/cache
[[ ! -d $r_work_path ]] && mkdir -p "$r_work_path"
local -r r_manager_file='sherpa-manager.sh'
local -r r_manager_archive_file=${r_manager_file%.*}.tar.gz
readonly r_manager_archive_url='https://raw.githubusercontent.com/OneCDOnly/sherpa'/$source_git_branch/$r_manager_archive_file
readonly r_manager_archive_pathfile=$r_work_path/$r_manager_archive_file
readonly r_manager_pathfile=$r_work_path/$r_manager_file
local -r r_nas_firmware=$(/sbin/getcfg System Version -f /etc/config/uLinux.conf)
[[ ${r_nas_firmware//.} -lt 426 ]] && curl_insecure_arg=' --insecure' || curl_insecure_arg=''
readonly GNU_FIND_CMD=/opt/bin/find
previous_msg=''
return 0
}
EnsureFileIsCurrent()
{
if [[ ! -e $1 ]] || ! IsThisFileRecent "$1" 60;then
if ! (/sbin/curl"$curl_insecure_arg" --silent --fail "$2" > "$3");then
ShowAsWarn 'Remote file download failed'
else
/bin/tar --extract --gzip --no-same-owner --file="$3" --directory="$(/usr/bin/dirname "$3")" 2>/dev/null
fi
fi
}
IsThisFileRecent()
{
[[ -e ${1:-} && $((($(/bin/date +%s)-$(/usr/bin/stat "$1" -c %Y))/60)) -le ${2:-1440} ]]
}
IsQNAP()
{
if [[ ! -e /etc/init.d/functions ]];then
ShowAsAbort 'QNAP functions not found ... is this a QNAP NAS?'
return 1
fi
return 0
}
IsSU()
{
if [[ $EUID -ne 0 ]];then
if [[ -e /usr/bin/sudo ]];then
ShowAsError 'this utility must be run with superuser privileges. Try again as:'
echo "${r_chars_sudo_prompt}sherpa $r_user_args_raw" >&2
else
ShowAsError "this utility must be run as the 'admin' user. Please login via SSH as 'admin' and try again"
fi
return 1
fi
return 0
}
ShowAsWarn()
{
WriteToDisplay.New "$(ColourTextBrightOrange warn)" "${1:-}"
return 0
}
ShowAsAbort()
{
WriteToDisplay.New "$(ColourTextBrightRed bort)" "${1:-}"
return 0
}
ShowAsError()
{
local capitalised=$(Capitalise "${1:-}")
WriteToDisplay.New "$(ColourTextBrightRed derp)" "$capitalised"
return 0
}
Capitalise()
{
echo "$(Uppercase ${1:0:1})${1:1}"
}
Uppercase()
{
tr 'a-z' 'A-Z' <<< "$1"
}
WriteToDisplay.New()
{
local new_message=''
local strbuffer=''
local new_length=0
new_message=$(printf '%-10s: %s' "$1" "$2")
if [[ $new_message != "$previous_msg" ]];then
previous_length=$((${#previous_msg}+1))
new_length=$((${#new_message}+1))
strbuffer=$(echo -en "\r$new_message ")
if [[ $new_length -lt $previous_length ]];then
appended_length=$((new_length-previous_length))
strbuffer+=$(printf "%${appended_length}s")
fi
echo "$strbuffer"
fi
return 0
}
ColourTextBrightOrange()
{
printf '\033[1;38;5;214m%s\033[0m' "${1:-}"
}
ColourTextBrightRed()
{
printf '\033[1;31m%s\033[0m' "${1:-}"
}
Init || exit
EnsureFileIsCurrent "$r_manager_pathfile" "$r_manager_archive_url" "$r_manager_archive_pathfile"
eval '/usr/bin/env bash' "$r_manager_pathfile" "$r_user_args_raw"
