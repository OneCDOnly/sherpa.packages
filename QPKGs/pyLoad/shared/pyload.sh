#!/usr/bin/env bash
#* Please don't edit this file directly, it was built/modified programmatically with the 'build-qpkgs.sh' script. (source: 'pyload.source')
#* pyload.sh
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
readonly USER_ARGS_RAW=$*
readonly QPKG_NAME=pyLoad
readonly SERVICE_SCRIPT_VERSION='240831'
InitService()
{
pip_cache_path=$QPKG_PATH/pip-cache
qpkg_wheels_path=$QPKG_PATH/qpkg-wheels
venv_path=$QPKG_PATH/venv
qpkg_ini_file=pyload.cfg
daemon_exec_pathfile=$venv_path/bin/python3
daemon_script_pathfile=$venv_path/bin/pyload
qpkg_ini_pathfile=$QPKG_CONFIG_PATH/settings/$qpkg_ini_file
qpkg_ini_default_pathfile=$qpkg_ini_pathfile.def
venv_pip_pathfile=$venv_path/bin/pip
venv_python_pathfile=$venv_path/bin/python3
can_restart_to_update=true
interpreter=/opt/bin/python3
get_ui_listening_address_cmd="GetPyloadConfig $qpkg_ini_pathfile webui host"
get_ui_port_cmd="GetPyloadConfig $qpkg_ini_pathfile webui port"
get_ui_port_secure_cmd="GetPyloadConfig $qpkg_ini_pathfile webui port"
get_ui_port_secure_enabled_test_cmd="[[ $(GetPyloadConfig "$qpkg_ini_pathfile" webui use_ssl) = True ]]"
daemon_launch_cmd="export TEMP=$QPKG_TEMP_PATH;$daemon_exec_pathfile $daemon_script_pathfile --daemon --userdir $QPKG_PATH/config"
}
GetPyloadConfig()
{
local source_pathfile=${1:?no pathfilename supplied}
local target_section_name=${2:?no section supplied}
local target_var_name=${3:?no variable supplied}
if [[ ! -e $source_pathfile ]];then
echo false
return
fi
local result_line=''
local -i line_num=0
local section_raw=''
local blank=''
local section_description=''
local section_name=''
local -i start_line_num=0
local target_section=''
local end_line_num='$'
local raw_var_type=''
local raw_var_description=''
local value_raw=''
local var_type=''
local value=''
local var_found=false
while read -r result_line;do
IFS=':' read -r line_num section_raw <<< "$result_line"
IFS=' ' read -r section_name blank section_description <<< "$section_raw"
if [[ $section_name = "$target_section_name" ]];then
[[ $start_line_num -eq 0 ]] && start_line_num=$((line_num+1))
else
if [[ $start_line_num -ne 0 ]];then
end_line_num=$((line_num-2))
break
fi
fi
done <<< "$(/bin/grep '.*:$' -n "$source_pathfile")"
if [[ $start_line_num -eq 0 ]];then
echo 'section match not found'
return 1
fi
target_section=$(/bin/sed -n "${start_line_num},${end_line_num}p" "$source_pathfile")
while read -r section_line;do
IFS=':' read -r raw_var_type raw_var_description <<< "$section_line"
read -r var_type var_name <<< "$raw_var_type"
[[ $var_name != "$target_var_name" ]] && continue
var_found=true
IFS='"' read -r blank var_description value_raw <<< "$raw_var_description"
IFS='=' read -r blank value <<< "$value_raw"
value=${value% };value=${value# }
break
done <<< "$target_section"
if [[ $var_found = false ]];then
echo 'variable match not found'
return 1
fi
echo "$value"
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
