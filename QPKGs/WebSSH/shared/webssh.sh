#!/usr/bin/env bash
#* Please don't edit this file directly, it was built/modified programmatically with the 'build-qpkgs.sh' script. (source: 'webssh.source')
#* webssh.sh
#* copyright (C) 2017-2024 OneCD.
#* Contact:
#*   one.cd.only@gmail.com
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
readonly r_qpkg_name=WebSSH
readonly r_service_script_version='241012'
InitService()
{
pip_cache_path=$r_qpkg_path/pip-cache
qpkg_wheels_path=$r_qpkg_path/qpkg-wheels
venv_path=$r_qpkg_path/venv
daemon_exec_pathfile=$venv_path/bin/python
daemon_script_pathfile=$venv_path/bin/wssh
qpkg_backup_pathfile=undefined
qpkg_ini_pathfile=undefined
qpkg_ini_default_pathfile=undefined
venv_pip_pathfile=$venv_path/bin/pip
venv_python_pathfile=$venv_path/bin/python
can_restart_to_update=true
run_daemon_in_screen_session=true
interpreter=/opt/bin/python3
source_git_branch=master
ui_listening_address=0.0.0.0
ui_port=8010
get_ui_listening_address_cmd="echo $ui_listening_address"
get_ui_port_cmd="echo $ui_port"
get_ui_port_secure_cmd="echo $ui_port_secure"
get_ui_port_secure_enabled_test_cmd='false'
daemon_launch_cmd="$daemon_exec_pathfile $daemon_script_pathfile --address=$ui_listening_address --port=$ui_port --encoding=850"
}
library_path=$(/usr/bin/readlink "$0" 2>/dev/null)
[[ -z $library_path ]] && library_path=$0
readonly r_service_library_pathfile=$(/usr/bin/dirname "$library_path")/service.lib
if [[ -e $r_service_library_pathfile ]];then
. $r_service_library_pathfile
else
printf '\033[1;31m%s\033[0m: %s\n' 'derp' "QPKG service function library not found, can't continue."
exit 1
fi
ProcessArgs
