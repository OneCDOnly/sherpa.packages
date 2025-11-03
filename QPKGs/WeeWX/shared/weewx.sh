#!/bin/bash
#*
#* Please don't edit this file directly, it has been programmatically built or modified with the 'build-qpkgs.sh' script. (source: 'weewx.source')
#*
#* weewx.sh
#*	  Copyright (C) 2017-2025 OneCD.
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
#* Support forums:
#*	  https://community.qnap.com/t/qpkg-sherpa-a-mini-package-manager-cli/1081
#*	  https://forum.qnap.com/viewtopic.php?t=132373
#*
#* Tested on:
#*	  GNU bash, version 3.2.57(1)-release (aarch64-QNAP-linux-gnu)
#*	  GNU bash, version 3.2.57(1)-release (x86_64-QNAP-linux-gnu)
#*	  GNU bash, version 3.2.57(2)-release (i686-pc-linux-gnu)
#*		 Copyright (C) 2007 Free Software Foundation, Inc.
#*
#* Notes:
#*	  All sherpa scripts are optimised for compatibility with bash 3.2 (via QTS BusyBox) as this is the native QNAP NAS shell. Be-careful reusing code in other shells, as these scripts contain syntax quirks often compatible only with bash.
#*
#* License:
#*	  This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#*	  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#*	  You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/
#*
readonly r_user_args_raw=$*
readonly r_qpkg_name=WeeWX
readonly r_service_script_version=251103
InitService(){
can_restart_to_update=true
daemon_pidfile_is_managed_by_app=true
install_pip_deps=true
qpkg_config_path=$r_qpkg_path/config
qpkg_pip_path=$r_qpkg_path/pip-cache
qpkg_venv_path=$r_qpkg_path/venv
qpkg_wheels_path=$r_qpkg_path/qpkg-wheels
daemon_exec_pathfile=$qpkg_venv_path/bin/python3
daemon_pid_pathfile=/var/run/$r_qpkg_name.pid
daemon_script_pathfile=$qpkg_venv_path/bin/weewxd
venv_pip_pathfile=$qpkg_venv_path/bin/pip
venv_python_pathfile=$qpkg_venv_path/bin/python3
interpreter=/opt/bin/python3
daemon_launch_cmd="$daemon_exec_pathfile $daemon_script_pathfile --daemon --pidfile $daemon_pid_pathfile --exit";}
PreStartQpkgCustom(){
local control_pathfile=$qpkg_venv_path/bin/weectl
local launcher_pathfile=$r_qpkg_path/weectl-launch.sh
local userlink_pathfile=/usr/bin/weectl
local gui_log_path=/home/httpd/weewx
local real_log_path=$qpkg_config_path/weewx-data/public_html
if [[ ! -e $launcher_pathfile ]];then
/bin/cat>"$launcher_pathfile"<<EOF
#!/usr/bin/env bash
export HOME=$qpkg_config_path
if [[ -e $control_pathfile ]];then
eval "$venv_python_pathfile" "$control_pathfile" "\$@"
else
echo "error: unable to find 'weectl' binary!"
exit 1
fi
exit 0
EOF
chmod +x "$launcher_pathfile"
fi
[[ ! -L $userlink_pathfile &&-e $launcher_pathfile ]]&&ln -s "$launcher_pathfile" "$userlink_pathfile"
if [[ ! -d $qpkg_config_path/weewx-data ]];then
if IsInstall;then
SetSkipDaemonStart
else
DisplayAndCommitErrorToAllLogs "unable to launch weather recording daemon: a weather station hasn't been defined. Do this with 'weectl station create' then restart this QPKG"
SetError
fi
else
[[ ! -L $gui_log_path ]]&&ln -s "$real_log_path" "$gui_log_path"
fi;}
library_path=$(/usr/bin/readlink "$0" 2>/dev/null)
[[ -z $library_path ]]&&library_path=$0
library_path=$(/usr/bin/dirname "$library_path")
service_library_pathfile=$library_path/service-library.source
[[ ! -e $service_library_pathfile ]]&&service_library_pathfile=$library_path/service.lib
if [[ ! -e $service_library_pathfile ]];then
printf '\033[1;31m%s\033[0m: %s\n' derp "QPKG service function library not found, can't continue."
exit 1
fi
. $service_library_pathfile
ProcessArgs
