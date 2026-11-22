#!/bin/bash
#*
#* Please don't edit this file directly, it was built and/or modified programmatically with the 'build-qpkgs.sh' script. (source: 'sherpa-service.source')
#*
#* sherpa-service.sh
#*	  Copyright (C) 2017-2026 OneCD.
#*
#* Contact:
#*	  one.cd.only@gmail.com
#*
#* Description:
#*	  This is the service-script for the QPKG name show below as $r_qpkg_name
#*
#* Project:
#*	  https://git.io/sherpa
#*
#* Support forum topic:
#*	  https://community.qnap.com/t/qpkg-sherpa-a-mini-package-manager-cli/1081
#*
#* Tested on:
#*	  GNU bash, version 3.2.57(1)-release (aarch64-QNAP-linux-gnu)
#*	  GNU bash, version 3.2.57(1)-release (arm-none-linux-gnueabi)
#*	  GNU bash, version 3.2.57(1)-release (arm-openwrt-linux-gnu)
#*	  GNU bash, version 3.2.57(4)-release (arm-unknown-linux-gnueabihf)
#*	  GNU bash, version 3.2.57(2)-release (i686-pc-linux-gnu)
#*	  GNU bash, version 3.2.57(1)-release (x86_64-QNAP-linux-gnu)
#*		 Copyright (C) 2007 Free Software Foundation, Inc.
#*
#* Notes:
#*	  All sherpa scripts are optimised for compatibility with Bash 3.2 (via QTS BusyBox), as this is the native QNAP NAS shell. Be-careful reusing code in other shells. These scripts contain syntax quirks often compatible only with Bash.
#*
#* License:
#*	  This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#*	  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#*	  You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/
#*
set -o nounset -o pipefail
shopt -s extglob
[[ $- != *m* ]]||set +m
[[ -L /dev/fd ]]||ln -fns /proc/self/fd /dev/fd
readonly r_user_args_raw=$*
Init(){ r_qpkg_name=sherpa
readonly r_qpkg_name
local r_qpkg_path
r_qpkg_path=$(/sbin/getcfg $r_qpkg_name Install_Path -f /etc/config/qpkg.conf)
r_qpkg_log_path=$r_qpkg_path/log
r_sys_log_path=/var/log
local -r r_qpkg_path
readonly r_qpkg_log_path
readonly r_sys_log_path
readonly r_real_log_pathfile=$r_qpkg_log_path/session.archive.log
readonly r_real_loader_script_pathname=$r_qpkg_path/sherpa-loader.sh
readonly r_apparent_loader_script_pathname=/usr/sbin/sherpa
readonly r_gui_log_pathfile=/home/httpd/sherpa.debug.log
readonly r_service_action_pathfile=$r_sys_log_path/$r_qpkg_name.action
readonly r_service_result_pathfile=$r_sys_log_path/$r_qpkg_name.result
readonly r_qpkg_version=$(/sbin/getcfg $r_qpkg_name Version -f /etc/config/qpkg.conf)
[[ ! -d $r_qpkg_log_path ]]&&mkdir -p "$r_qpkg_log_path"
[[ ! -d $r_sys_log_path ]]&&mkdir -p "$r_sys_log_path"
[[ ! -e $r_real_log_pathfile ]]&&/bin/touch "$r_real_log_pathfile";}
StartQPKG(){ [[ ! -L $r_apparent_loader_script_pathname ]]&&/bin/ln -s "$r_real_loader_script_pathname" "$r_apparent_loader_script_pathname"
[[ ! -L $r_gui_log_pathfile ]]&&/bin/ln -s "$r_real_log_pathfile" "$r_gui_log_pathfile"
echo 'symlinks created';}
StopQPKG(){ [[ -L $r_apparent_loader_script_pathname ]]&&rm -f "$r_apparent_loader_script_pathname"
[[ -L $r_gui_log_pathfile ]]&&rm -f "$r_gui_log_pathfile"
echo 'symlinks removed';}
StatusQPKG(){ if [[ -L $r_apparent_loader_script_pathname ]];then echo active
exit 0;else echo inactive
exit 1;fi;}
ShowHelp(){ Display "$(TextBrightWhite "$(/usr/bin/basename "$0")") v$r_qpkg_version • a service control script for the $(FormatAsPackageName $r_qpkg_name) QPKG";Display;Display "Usage: $0 [ACTION]";Display;Display '[ACTION] must be one of the following:'
DisplayAsHelp disable "disable $(FormatAsPackageName $r_qpkg_name) to prevent it starting (on NAS bootup)"
DisplayAsHelp enable "enable $(FormatAsPackageName $r_qpkg_name) so it can be started"
DisplayAsHelp 'start, activate' "start $(FormatAsPackageName $r_qpkg_name) if inactive"
DisplayAsHelp 'stop, deactivate' "stop $(FormatAsPackageName $r_qpkg_name) if active"
DisplayAsHelp 'r, restart, reactivate' "stop, then start $(FormatAsPackageName $r_qpkg_name)"
DisplayAsHelp 's, status' "check if $(FormatAsPackageName $r_qpkg_name) application is active. Returns \$? = 0 if active, 1 if not"
Display;}
ShowEnabled(){ Display "$(FormatAsPackageName "$r_qpkg_name") QPKG is enabled.";}
ShowDisabled(){ Display "= $(FormatAsPackageName "$r_qpkg_name") QPKG is disabled.";}
ShowDisabledPrompt(){ service_explanation="QPKG is disabled. Please enable it first with: $0 enable"
Display "= $service_explanation";}
ShowEnableFailed(){ Display "= $(FormatAsPackageName "$r_qpkg_name") QPKG enable failed.";}
ShowDisableFailed(){ Display "= $(FormatAsPackageName "$r_qpkg_name") QPKG disable failed.";}
SetServiceAction(){ service_action=${1:-none}
CommitServiceAction
SetServiceResultAsInProgress;}
SetServiceResultAsOK(){ service_result=ok
CommitServiceResult;}
SetServiceResultAsFailed(){ service_result=failed
CommitServiceResult;}
SetServiceResultAsInProgress(){ service_result=in-progress
CommitServiceResult;}
CommitServiceAction(){ echo "$service_action">"$r_service_action_pathfile";}
CommitServiceResult(){ echo "$service_result">"$r_service_result_pathfile";}
SetError(){ IsError&&return
_error_flag=true
false;}
UnsetError(){ IsNtError&&return
_error_flag=false;}
IsError(){ [[ ${_error_flag:=false} = true ]];}
IsNtError(){ ! IsError;}
IsQpkgEnabled(){ [[ $(/sbin/getcfg ${1:-$r_qpkg_name} Enable -u -d FALSE -f /etc/config/qpkg.conf) = TRUE ]];}
IsNtQpkgEnabled(){ ! IsQpkgEnabled "${1:-$r_qpkg_name}";}
FormatAsPackageName(){ echo "'${1:-}'";}
DisplayAsHelp(){ printf '  %-22s  - %s\n' "${1:-}" "${2:-}.";}
Display(){ echo "${1:-}";}
TextBrightWhite(){ [[ -n ${1:-} ]]||return
printf '\033[1;97m%s\033[0m' "$1";}
Init
user_arg=${r_user_args_raw%% *}
case $user_arg in ?(--)disable)
SetServiceAction disable
/sbin/qpkg_service disable "$r_qpkg_name"
if IsNtQpkgEnabled;then ShowDisabled;else ShowDisableFailed
SetError;fi;;?(--)enable)
SetServiceAction enable
/sbin/qpkg_service enable "$r_qpkg_name"
if IsQpkgEnabled;then ShowEnabled;else ShowEnableFailed
SetError;fi;;?(--)restart|?(-)r|?(--)reactivate)
SetServiceAction restart
if IsQpkgEnabled;then StopQPKG&&StartQPKG;else ShowDisabledPrompt
SetError;fi;;?(--)start|?(--)activate)
SetServiceAction start
if IsQpkgEnabled;then StartQPKG;else ShowDisabledPrompt
SetError;fi;;?(-)s|?(--)status)
StatusQPKG;;?(--)stop|?(--)deactivate)
SetServiceAction stop
StopQPKG;;*)ShowHelp
esac;if IsError;then SetServiceResultAsFailed
exit 1;else SetServiceResultAsOK;fi;exit 0
