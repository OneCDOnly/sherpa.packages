#!/usr/bin/env bash
#* <?dont_edit?>
#
#* <?filename?>
#
#* <?copyright?>
#
#* <?project?>
#
#* <?tested?>
#
#* <?license?>

readonly USER_ARGS_RAW=$*
readonly QPKG_NAME=Codex
readonly SERVICE_SCRIPT_VERSION='<?build_date?>'

InitService()
	{

	# This is a type 6 service-script.

	# NOTE: default session values are set in service function library: uncomment to update, or copy to change.

	# >>> Paths <<<

		# pip_cache_path=undefined
		pip_cache_path=$QPKG_PATH/pip-cache

		# qpkg_repo_path=undefined
		qpkg_repo_path=$QPKG_PATH/repo-cache

		# qpkg_wheels_path=undefined
		qpkg_wheels_path=$QPKG_PATH/qpkg-wheels

		# venv_path=undefined
		venv_path=$QPKG_PATH/venv

	# >>> Filenames <<<

		# qpkg_ini_file=config.ini

	# >>> Pathfilenames <<<

		# app_version_pathfile=undefined

		# daemon_check_pathfile=undefined							# If set, look for this process pathfilename instead of $daemon_exec_pathfile.

		# daemon_exec_pathfile=undefined							# The pathfilename of the main daemon. If $daemon_script_pathfile is set, then this will be the interpreter to launch.
		daemon_exec_pathfile=$venv_path/bin/python3

		# daemon_pid_pathfile=/var/run/$QPKG_NAME.pid

		# daemon_script_pathfile=undefined							# When an interpreter is to be used, interpret this script.
		daemon_script_pathfile=$venv_path/bin/codex

		# launcher_pathfile=undefined								# On-demand executables only.

		# qpkg_backup_pathfile=$BACKUP_PATH/$QPKG_NAME.config.tar.gz
		qpkg_backup_pathfile=undefined								# Backup is unsupported.

		# qpkg_ini_pathfile=$QPKG_CONFIG_PATH/$qpkg_ini_file
		qpkg_ini_pathfile=undefined									# App config is unsupported.

		# qpkg_ini_default_pathfile=$qpkg_ini_pathfile.def
		qpkg_ini_default_pathfile=undefined

		# userlink_pathfile=undefined								# On-demand executables only.

		# venv_pip_pathfile=undefined
		venv_pip_pathfile=$venv_path/bin/pip

		# venv_python_pathfile=undefined
		venv_python_pathfile=$venv_path/bin/python3

	# >>> Switches <<<

		# allow_access_to_sys_packages=true

		# can_restart_to_update=false								# If 'true', application can be updated by restarting service-script.
		can_restart_to_update=true

		# daemon_pidfile_is_managed_by_app=false

		# install_pip_deps=false

		# recheck_daemon_pid_after_kill=false						# If 'true', application PID is reconfirmed shortly after kill confirmed. Some applications kill their main PID, then switch to another during shutdown.
		recheck_daemon_pid_after_kill=true

		# recheck_daemon_pid_after_launch=false						# If 'true', application PID is reconfirmed shortly after initial launch. Some applications launch with one PID, then switch to another.

		# resolve_remote_url=false									# If 'true', URL must be retrieved from remote first, then parsed to get final URL.

		# run_daemon_in_screen_session=false						# If 'true', daemon is always launched in a `screen` session, but will exit `screen` when it can.
		run_daemon_in_screen_session=true

		# silence_pypi_errors=true									# If 'true', PyPI package processing errors won't be shown in system log.

	# >>> Values <<<

		# daemon_port=0

		# interpreter=undefined
		interpreter=/opt/bin/python3

		# nice_daemon_to=0											# If non-zero, daemon proc is niced to this value on-launch.

		# orig_daemon_service_script=undefined						# Specific to Entware binaries only.

		# remote_arch=undefined

		# source_arch=undefined

		# source_git_branch=undefined

		# source_git_branch_depth=undefined							# 'shallow' (depth 1) or 'single-branch' ... 'shallow' implies 'single-branch'.

		# ui_listening_address=undefined
		ui_listening_address=0.0.0.0

		# ui_port=0
		ui_port=9810

		# ui_port_secure=0

	# >>> URLs <<<

		# remote_url=undefined

		# source_git_url=undefined

	# >>> CMDs <<<

		# get_app_version_cmd=undefined

		# get_daemon_port_cmd=undefined

		# get_ui_listening_address_cmd=undefined
		get_ui_listening_address_cmd="echo $ui_listening_address"

		# get_ui_port_cmd=undefined
		get_ui_port_cmd="echo $ui_port"

		# get_ui_port_secure_cmd=undefined
		get_ui_port_secure_cmd='echo 0'

		# get_ui_port_secure_enabled_test_cmd=undefined
		get_ui_port_secure_enabled_test_cmd='false'

		# daemon_launch_cmd=undefined
		daemon_launch_cmd="export TEMP=$QPKG_TEMP_PATH CODEX_CONFIG_DIR=$QPKG_CONFIG_PATH LOGLEVEL=DEBUG; $daemon_exec_pathfile $daemon_script_pathfile"

	}

library_path=$(/usr/bin/readlink "$0" 2>/dev/null)
[[ -z $library_path ]] && library_path=$0
readonly SERVICE_LIBRARY_PATHFILE=$(/usr/bin/dirname "$library_path")/service.lib

if [[ -e $SERVICE_LIBRARY_PATHFILE ]]; then
	. $SERVICE_LIBRARY_PATHFILE
else
	printf '\033[1;31m%s\033[0m: %s\n' 'derp' "QPKG service function library not found, can't continue."
	exit 1
fi

ProcessArgs
