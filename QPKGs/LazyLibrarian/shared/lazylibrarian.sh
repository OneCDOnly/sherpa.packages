#!/usr/bin/env bash
#* Please don't edit this file directly, it was built/modified programmatically with the 'build-qpkgs.sh' script. (source: 'lazylibrarian.source')
#* lazylibrarian.sh
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
readonly QPKG_NAME=LazyLibrarian
readonly SERVICE_SCRIPT_VERSION='240812'
InitService()
{
pip_cache_path=$QPKG_PATH/pip-cache
qpkg_repo_path=$QPKG_PATH/repo-cache
qpkg_wheels_path=$QPKG_PATH/qpkg-wheels
venv_path=$QPKG_PATH/venv
app_version_pathfile=$qpkg_repo_path/lazylibrarian/version.py
daemon_exec_pathfile=$venv_path/bin/python3
daemon_script_pathfile=$qpkg_repo_path/LazyLibrarian.py
venv_pip_pathfile=$venv_path/bin/pip
venv_python_pathfile=$venv_path/bin/python3
can_restart_to_update=true
daemon_pidfile_is_managed_by_app=true
install_pip_deps=true
recheck_daemon_pid_after_launch=true
interpreter=/opt/bin/python3
source_git_branch=master
source_git_branch_depth=shallow
ui_listening_address=0.0.0.0
ui_port=5299
source_git_url=https://gitlab.com/LazyLibrarian/LazyLibrarian.git
get_ui_listening_address_cmd="/sbin/getcfg misc host -d $ui_listening_address -f $qpkg_ini_pathfile"
get_ui_port_cmd="/sbin/getcfg General http_port -d $ui_port -f $qpkg_ini_pathfile"
get_ui_port_secure_cmd="/sbin/getcfg General http_port -d $ui_port -f $qpkg_ini_pathfile"
get_ui_port_secure_enabled_test_cmd='[[ $(/sbin/getcfg General https_enabled -d 0 -f '$qpkg_ini_pathfile') = 1 ]]'
daemon_launch_cmd="$daemon_exec_pathfile $daemon_script_pathfile --daemon --nolaunch --datadir $(/usr/bin/dirname "$qpkg_ini_pathfile") --config $qpkg_ini_pathfile --pidfile $daemon_pid_pathfile"
IsSupportGetAppVersion && app_version_cmd="/bin/grep '__version__ =' $app_version_pathfile | /bin/sed 's|^.*\"\(.*\)\"|\1|'"
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
