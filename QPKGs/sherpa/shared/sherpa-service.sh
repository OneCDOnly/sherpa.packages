#!/usr/bin/env bash
#* Please don't edit this file directly, it was built/modified programmatically with the 'build-qpkgs.sh' script. (source: 'sherpa-service.source')
#* sherpa-service.sh
#* copyright (C) 2017-2024 OneCD.
#* Contact:
#*   one.cd.only@gmail.com
#* Description:
#*	 This is the service-script for the sherpa mini-package-manager and is part of the `sherpa` QPKG.
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
set -o nounset -o pipefail
shopt -s extglob
[[ $- != *m* ]] || set +m
ln -fns /proc/self/fd /dev/fd
readonly r_user_args_raw=$*
Init()
{
readonly r_qpkg_name=sherpa
local -r r_qpkg_path=$(/sbin/getcfg $r_qpkg_name Install_Path -f /etc/config/qpkg.conf)
readonly r_real_log_pathfile=$r_qpkg_path/logs/session.archive.log
readonly r_real_loader_script_pathname=$r_qpkg_path/sherpa-loader.sh
readonly r_apparent_loader_script_pathname=/usr/sbin/sherpa
readonly r_gui_log_pathfile=/home/httpd/sherpa.debug.log
readonly r_qpkg_version=$(/sbin/getcfg $r_qpkg_name Version -f /etc/config/qpkg.conf)
readonly r_service_action_pathfile=/var/log/$r_qpkg_name.action
readonly r_service_result_pathfile=/var/log/$r_qpkg_name.result
[[ ! -d $(/usr/bin/dirname "$r_real_log_pathfile") ]] && mkdir -p "$(/usr/bin/dirname "$r_real_log_pathfile")"
[[ ! -e $r_real_log_pathfile ]] && /bin/touch "$r_real_log_pathfile"
}
StartQPKG()
{
[[ ! -L $r_apparent_loader_script_pathname ]] && /bin/ln -s "$r_real_loader_script_pathname" "$r_apparent_loader_script_pathname"
[[ ! -L $r_gui_log_pathfile ]] && /bin/ln -s "$r_real_log_pathfile" "$r_gui_log_pathfile"
echo 'symlinks created'
}
StopQPKG()
{
[[ -L $r_apparent_loader_script_pathname ]] && rm -f "$r_apparent_loader_script_pathname"
[[ -L $r_gui_log_pathfile ]] && rm -f "$r_gui_log_pathfile"
echo 'symlinks removed'
}
StatusQPKG()
{
if [[ -L $r_apparent_loader_script_pathname ]];then
echo active
exit 0
else
echo inactive
exit 1
fi
}
ShowHelp()
{
Display "$(TextBrightWhite "$(/usr/bin/basename "$0")") v$r_qpkg_version • a service control script for the $(FormatAsPackageName $r_qpkg_name) QPKG"
Display
Display "Usage: $0 [ACTION]"
Display
Display '[ACTION] must be one of the following:'
DisplayAsHelp 'activate, start' "start $(FormatAsPackageName $r_qpkg_name) if inactive"
DisplayAsHelp 'deactivate, stop' "stop $(FormatAsPackageName $r_qpkg_name) if active"
DisplayAsHelp 'r, reactivate, restart' "stop, then start $(FormatAsPackageName $r_qpkg_name)"
DisplayAsHelp 's, status' "check if $(FormatAsPackageName $r_qpkg_name) application is active. Returns \$? = 0 if active, 1 if not"
Display
}
SetServiceAction()
{
service_action=${1:-none}
CommitServiceAction
SetServiceResultAsInProgress
}
SetServiceResultAsOK()
{
service_result=ok
CommitServiceResult
}
SetServiceResultAsFailed()
{
service_result=failed
CommitServiceResult
}
SetServiceResultAsInProgress()
{
service_result=in-progress
CommitServiceResult
}
CommitServiceAction()
{
echo "$service_action" > "$r_service_action_pathfile"
}
CommitServiceResult()
{
echo "$service_result" > "$r_service_result_pathfile"
}
FormatAsPackageName()
{
echo "'${1:-}'"
}
DisplayAsHelp()
{
printf '  %-22s  - %s\n' "${1:-}" "${2:-}."
}
Display()
{
echo "${1:-}"
}
TextBrightWhite()
{
[[ -n ${1:-} ]] || return
printf '\033[1;97m%s\033[0m' "$1"
}
Init
user_arg=${r_user_args_raw%% *}
case $user_arg in
?(--)activate|?(--)start)
SetServiceAction start
if StartQPKG;then
SetServiceResultAsOK
else
SetServiceResultAsFailed
fi
;;
?(-)s|?(--)status)
StatusQPKG
;;
?(--)deactivate|?(--)stop)
SetServiceAction stop
if StopQPKG;then
SetServiceResultAsOK
else
SetServiceResultAsFailed
fi
;;
?(-)r|?(--)reactivate|?(--)restart)
SetServiceAction restart
if StopQPKG && StartQPKG;then
SetServiceResultAsOK
else
SetServiceResultAsFailed
fi
;;
*)
ShowHelp
esac
exit 0
