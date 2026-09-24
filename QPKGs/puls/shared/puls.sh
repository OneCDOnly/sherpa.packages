#!/usr/bin/env bash
set -o nounset
shopt -s extglob
[[ -L /dev/fd ]]||ln -fns /proc/self/fd /dev/fd
readonly r_user_args_raw=$*
Init(){
readonly r_qpkg_name=puls
/sbin/setcfg $r_qpkg_name Status complete -f /etc/config/qpkg.conf
[[ -e /sbin/qpkg_cli ]]&&/sbin/qpkg_cli --clean $r_qpkg_name &>/dev/null
readonly r_linkname_pathfile=/usr/bin/puls
readonly r_linktarget_pathfile=$(/sbin/getcfg $r_qpkg_name Install_Path -f /etc/config/qpkg.conf)/puls.bin
readonly r_qpkg_version=$(/sbin/getcfg $r_qpkg_name Version -d 000000 -f /etc/config/qpkg.conf)
readonly r_service_action_pathfile=/var/log/$r_qpkg_name.action
readonly r_service_result_pathfile=/var/log/$r_qpkg_name.result;}
StartQPKG(){
if IsNotQPKGEnabled;then
echo -e "This QPKG is disabled. Please enable it first with:\n\tqpkg_service enable $r_qpkg_name"
return 1
else
ln -sf "$r_linktarget_pathfile" "$r_linkname_pathfile"
echo 'application link(s) created'
fi;}
StopQPKG(){
rm -f "$r_linkname_pathfile"
echo 'application link(s) removed';}
ShowTitle(){
echo "$(ShowAsTitleName) $(ShowAsVersion)";}
ShowAsTitleName(){
TextBrightWhite "$r_qpkg_name";}
ShowAsVersion(){
printf '%s' "v$r_qpkg_version";}
ShowAsUsage(){
echo -e "\nUsage: $0 {start|stop|restart|status}"
echo -e "\nTo view the application help: $(basename "$r_linkname_pathfile") --help";}
StatusQPKG(){
if [[ -L $r_linkname_pathfile ]];then
echo active
exit 0
else
echo inactive
exit 1
fi;}
SetServiceAction(){
service_action=${1:-none}
CommitServiceAction
SetServiceResultAsInProgress;}
SetServiceResultAsOK(){
service_result=ok
CommitServiceResult;}
SetServiceResultAsFailed(){
service_result=failed
CommitServiceResult;}
SetServiceResultAsInProgress(){
service_result=in-progress
CommitServiceResult;}
CommitServiceAction(){
echo "$service_action">"$r_service_action_pathfile";}
CommitServiceResult(){
echo "$service_result">"$r_service_result_pathfile";}
TextBrightWhite(){
[[ -n ${1:-} ]]||return
printf '\033[1;97m%s\033[0m' "${1:-}";}
IsQPKGEnabled(){
[[ $(Lowercase "$(/sbin/getcfg ${1:-$r_qpkg_name} Enable -d false -f /etc/config/qpkg.conf)") = true ]];}
IsNotQPKGEnabled(){
! IsQPKGEnabled "${1:-$r_qpkg_name}";}
Lowercase(){
/bin/tr 'A-Z' 'a-z'<<<"${1:-}";}
Init
user_arg=${r_user_args_raw%% *}
case $user_arg in
?(-)r|?(--)restart)
SetServiceAction restart
if StopQPKG &&StartQPKG;then
SetServiceResultAsOK
else
SetServiceResultAsFailed
fi;;
?(--)start)
SetServiceAction start
if StartQPKG;then
SetServiceResultAsOK
else
SetServiceResultAsFailed
fi;;
?(-)s|?(--)status)
StatusQPKG;;
?(--)stop)
SetServiceAction stop
if StopQPKG;then
SetServiceResultAsOK
else
SetServiceResultAsFailed
fi;;
*)ShowTitle
ShowAsUsage
esac
exit 0
