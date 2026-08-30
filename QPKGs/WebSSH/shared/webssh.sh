#!/bin/bash
#*
#* Please don't edit this file directly, it was built or modified programmatically with the 'build-qpkgs.sh' script. (source: 'webssh.source')
#*
#* webssh.sh
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
readonly r_qpkg_name=WebSSH
readonly r_service_script_version=260830
InitService(){
allow_access_to_sys_packages=true
can_restart_to_update=true
run_daemon_in_screen_session=true
source_git_branch=master
start_retries=3
ui_listening_address=0.0.0.0
ui_port=8010
qpkg_pip_path=$r_qpkg_path/pip-cache
qpkg_venv_path=$r_qpkg_path/venv
qpkg_wheels_path=$r_qpkg_path/qpkg-wheels
daemon_exec_pathfile=$qpkg_venv_path/bin/python
daemon_pid_pathfile=$r_sys_run_path/$r_qpkg_name.pid
daemon_script_pathfile=$qpkg_venv_path/bin/wssh
venv_pip_pathfile=$qpkg_venv_path/bin/pip
venv_python_pathfile=$qpkg_venv_path/bin/python
export HOME=$qpkg_config_path
interpreter=/opt/bin/python3
daemon_launch_cmd="$daemon_exec_pathfile $daemon_script_pathfile --address=$ui_listening_address --port=$ui_port --encoding=850"
get_ui_listening_address_cmd="echo $ui_listening_address"
get_ui_port_cmd="echo $ui_port"
get_ui_port_secure_cmd="echo $ui_port_secure"
get_ui_port_secure_enabled_test_cmd=false;}
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
