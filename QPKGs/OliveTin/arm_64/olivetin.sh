#!/usr/bin/env bash
#* Please don't edit this file directly, it was built/modified programmatically with the 'build-qpkgs.sh' script. (source: 'olivetin.source')
#* olivetin.sh
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
readonly r_qpkg_name=OliveTin
readonly r_service_script_version='240911'
InitService()
{
qpkg_repo_path=$r_qpkg_path/repo-cache
qpkg_ini_file=config.yaml
qpkg_ini_pathfile=$r_qpkg_config_path/$qpkg_ini_file
qpkg_ini_default_pathfile=$qpkg_ini_pathfile.def
allow_access_to_sys_packages=false
can_restart_to_update=true
resolve_remote_url=true
run_daemon_in_screen_session=true
remote_arch=linux-arm64
daemon_exec_pathfile=$qpkg_repo_path/OliveTin-$remote_arch/OliveTin
remote_url='https://api.github.com/repos/OliveTin/OliveTin/releases/latest'
get_ui_listening_address_cmd='parse_yaml '$qpkg_ini_pathfile' | /bin/grep listenAddressSingleHTTPFrontend | cut -d= -f2 | cut -d: -f1 | /bin/sed "s|\"||"'
get_ui_port_cmd='parse_yaml '$qpkg_ini_pathfile' | /bin/grep listenAddressSingleHTTPFrontend | cut -d= -f2 | cut -d: -f2 | /bin/sed "s| .*$||"'
get_ui_port_secure_cmd='echo 0'
get_ui_port_secure_enabled_test_cmd='false'
daemon_launch_cmd="cd $qpkg_repo_path/OliveTin-$remote_arch && $daemon_exec_pathfile -configdir $r_qpkg_config_path"
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
