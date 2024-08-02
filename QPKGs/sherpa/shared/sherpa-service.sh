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
#*	 https://forum.qnap.com/viewtopic.php?f=320&t=132373
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
ln -fns /proc/self/fd /dev/fd
readonly USER_ARGS_RAW=$*
Init()
{
readonly QPKG_NAME=sherpa
local -r QPKG_PATH=$(/sbin/getcfg $QPKG_NAME Install_Path -f /etc/config/qpkg.conf)
readonly REAL_LOG_PATHFILE=$QPKG_PATH/logs/session.archive.log
readonly REAL_LOADER_SCRIPT_PATHNAME=$QPKG_PATH/sherpa-loader.sh
readonly APPARENT_LOADER_SCRIPT_PATHNAME=/usr/sbin/sherpa
readonly GUI_LOG_PATHFILE=/home/httpd/sherpa.debug.log
readonly QPKG_VERSION=$(/sbin/getcfg $QPKG_NAME Version -f /etc/config/qpkg.conf)
readonly SERVICE_ACTION_PATHFILE=/var/log/$QPKG_NAME.action
readonly SERVICE_RESULT_PATHFILE=/var/log/$QPKG_NAME.result
[[ ! -d $(/usr/bin/dirname "$REAL_LOG_PATHFILE") ]] && mkdir -p "$(/usr/bin/dirname "$REAL_LOG_PATHFILE")"
[[ ! -e $REAL_LOG_PATHFILE ]] && /bin/touch "$REAL_LOG_PATHFILE"
}
StartQPKG()
{
[[ ! -L $APPARENT_LOADER_SCRIPT_PATHNAME ]] && /bin/ln -s "$REAL_LOADER_SCRIPT_PATHNAME" "$APPARENT_LOADER_SCRIPT_PATHNAME"
[[ ! -L $GUI_LOG_PATHFILE ]] && /bin/ln -s "$REAL_LOG_PATHFILE" "$GUI_LOG_PATHFILE"
echo 'symlinks created'
}
StopQPKG()
{
[[ -L $APPARENT_LOADER_SCRIPT_PATHNAME ]] && rm -f "$APPARENT_LOADER_SCRIPT_PATHNAME"
[[ -L $GUI_LOG_PATHFILE ]] && rm -f "$GUI_LOG_PATHFILE"
echo 'symlinks removed'
}
StatusQPKG()
{
if [[ -L $APPARENT_LOADER_SCRIPT_PATHNAME ]];then
echo active
exit 0
else
echo inactive
exit 1
fi
}
ShowTitle()
{
echo "$(ShowAsTitleName) $(ShowAsVersion)"
}
ShowAsTitleName()
{
TextBrightWhite $QPKG_NAME
}
ShowAsVersion()
{
printf '%s' "v$QPKG_VERSION"
}
ShowAsUsage()
{
echo -e "\nUsage: $0 {start|stop|restart|status}"
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
echo "$service_action" > "$SERVICE_ACTION_PATHFILE"
}
CommitServiceResult()
{
echo "$service_result" > "$SERVICE_RESULT_PATHFILE"
}
TextBrightWhite()
{
[[ -n ${1:-} ]] || return
printf '\033[1;97m%s\033[0m' "$1"
}
Init
user_arg=${USER_ARGS_RAW%% *}
case $user_arg in
?(--)start)
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
?(--)stop)
SetServiceAction stop
if StopQPKG;then
SetServiceResultAsOK
else
SetServiceResultAsFailed
fi
;;
?(-)r|?(--)restart)
SetServiceAction restart
if StopQPKG && StartQPKG;then
SetServiceResultAsOK
else
SetServiceResultAsFailed
fi
;;
*)
ShowTitle
ShowAsUsage
esac
exit 0
