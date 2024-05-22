#!/usr/bin/env bash
#* Please don't edit this file directly, it was built/modified programmatically with the 'build-qpkgs.sh' script. (source: 'nzbhydra2.source')
#* nzbhydra2.sh
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
readonly QPKG_NAME=NZBHydra2
readonly SERVICE_SCRIPT_VERSION='240522'
readonly SERVICE_SCRIPT_TYPE=8
InitService()
{
interpreter=/opt/bin/python3
nice_daemon_to=15
pip_cache_path=$QPKG_PATH/pip-cache
qpkg_repo_path=$QPKG_PATH/repo-cache
venv_path=$QPKG_PATH/venv
venv_pip_pathfile=$venv_path/bin/pip
venv_python_pathfile=$venv_path/bin/python3
qpkg_ini_file=nzbhydra.yml
qpkg_ini_pathfile=$QPKG_CONFIG_PATH/$qpkg_ini_file
qpkg_ini_default_pathfile=$qpkg_ini_pathfile.def
get_ui_listening_address_cmd='parse_yaml '$qpkg_ini_pathfile' | /bin/grep main_host= | cut -d\" -f2'
get_ui_port_cmd='parse_yaml '$qpkg_ini_pathfile' | /bin/grep main_port= | cut -d\" -f2'
get_ui_port_secure_cmd='parse_yaml '$qpkg_ini_pathfile' | /bin/grep main_port= | cut -d\" -f2'
get_ui_port_secure_enabled_test_cmd='[[ $(parse_yaml '$qpkg_ini_pathfile' | /bin/grep main_ssl= | cut -d\" -f2) = true ]]'
local_temp_path=$QPKG_PATH/tmp
pidfile_is_managed_by_app=true
recheck_daemon_pid_after_launch=true
daemon_pathfile=$qpkg_repo_path/nzbhydra2wrapperPy3.py
daemon_launch_cmd="export NZBHYDRA_TEMP_FOLDER=$local_temp_path;$venv_python_pathfile $daemon_pathfile --nobrowser --daemon --datafolder $QPKG_CONFIG_PATH --pidfile $daemon_pid_pathfile"
remote_arch=amd64-linux
remote_url='https://api.github.com/repos/theotherp/nzbhydra2/releases/latest'
resolve_remote_url=true
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
