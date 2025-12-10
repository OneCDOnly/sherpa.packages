#!/bin/bash
#*
#* Please don't edit this file directly, it has been programmatically built or modified with the 'build-qpkgs.sh' script. (source: 'filebrowser.source')
#*
#* filebrowser.sh
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
readonly r_qpkg_name=FileBrowser
readonly r_service_script_version=251211
InitService(){
can_restart_to_update=true
resolve_source_url=true
run_daemon_in_screen_session=true
source_url_arch=amd64
ui_listening_address=0.0.0.0
ui_port=8641
qpkg_config_path=$r_qpkg_path/config
qpkg_repo_path=$r_qpkg_path/repo-cache
qpkg_temp_path=$r_qpkg_path/tmp
daemon_exec_pathfile=$qpkg_repo_path/filebrowser
daemon_pid_pathfile=$r_sys_run_path/$r_qpkg_name.pid
qpkg_backup_pathfile=$r_backup_path/$r_qpkg_name.config.tar.gz
qpkg_config_pathfile=$qpkg_config_path/filebrowser.db
qpkg_config_default_pathfile=$qpkg_config_pathfile.def
export HOME=$qpkg_config_path
source_asset_url_match=linux-${source_url_arch}-filebrowser.tar.gz
source_asset_url=https://api.github.com/repos/filebrowser/filebrowser/releases/latest
daemon_launch_cmd="$daemon_exec_pathfile --database $qpkg_config_pathfile --address $ui_listening_address --port $ui_port --root /"
get_ui_listening_address_cmd="echo $ui_listening_address"
get_ui_port_cmd="echo $ui_port"
get_ui_port_secure_cmd=false
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
