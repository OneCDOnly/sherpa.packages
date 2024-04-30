#!/usr/bin/env bash
#* Please don't edit this file directly, it was built/modified programmatically with the 'build-qpkgs.sh' script. (source: 'oqbittorrent.source')
#* oqbittorrent.sh
#* copyright (C) 2017-2024 OneCD.
#* Contact:
#*   one.cd.only@gmail.com
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
readonly USER_ARGS_RAW=$*
readonly QPKG_NAME=OqBittorrent
readonly SERVICE_SCRIPT_VERSION='240501'
readonly SERVICE_SCRIPT_TYPE=3
InitService()
{
daemon_pathfile=/opt/bin/qbittorrent-nox
daemon_launch_cmd="$daemon_pathfile --profile=$QPKG_PATH/config --daemon"
get_ui_listening_address_cmd="echo '0.0.0.0'"
get_ui_port_secure_enabled_test_cmd='false'
orig_daemon_service_script=/opt/etc/init.d/S89qbittorrent
qpkg_ini_file=qBittorrent.conf
qpkg_ini_pathfile=$QPKG_CONFIG_PATH/qBittorrent/config/$qpkg_ini_file
get_ui_port_cmd="/sbin/getcfg Preferences 'WebUI\Port' -d 0 -f $qpkg_ini_pathfile"
get_ui_port_secure_cmd="/sbin/getcfg Preferences 'WebUI\Port' -d 0 -f $qpkg_ini_pathfile"
qpkg_ini_default_pathfile=$qpkg_ini_pathfile.def
}
library_path=$(/usr/bin/readlink "$0" 2>/dev/null)
[[ -z $library_path ]] && library_path=$0
readonly SERVICE_LIBRARY_PATHFILE=$(/usr/bin/dirname "$library_path")/service.lib
if [[ -e $SERVICE_LIBRARY_PATHFILE ]];then
. $SERVICE_LIBRARY_PATHFILE
else
printf '\033[1;31m%s\033[0m: %s\n' 'derp' "QPKG service function library not found, can't continue."
exit 1
fi
ProcessArgs
