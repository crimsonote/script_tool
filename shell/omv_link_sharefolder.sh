#集中创建的共享文件夹
rootlink_path=/sharedfolder
#OMV配置文件夹
CONF_PATH=/etc/openmediavault/config.xml
function _init(){
    mkdir -p ${rootlink_path}
    link_sharedfolder $(sharedfolder-list)
}
function sharedfolder-list(){
    #提取共享文件夹数据，并使用引号分隔
    xmllint --xpath '/config/system/shares/sharedfolder/name/child::text()|/config/system/shares/sharedfolder/reldirpath/child::text()|/config/system/shares/sharedfolder/mntentref/child::text()' $(readlink -f ${CONF_PATH})|tr '\n' '\r'|sed 's#\r$#\"#g'|sed 's#\r#" "#g'|sed 's#^#\"#g'
}
function filesystem-uuid-to-mountpath(){
    #文件系统uuit转挂载点位置,使用tr删除uuid的引号
    uuid="'$(echo $1|tr -d '"')'"
#   echo uuid $uuid >&2
    xmllint --xpath "/config/system/fstab/mntent/uuid[text()=${uuid}]/../dir/child::text()"  $(readlink -f ${CONF_PATH})
}
function link_sharedfolder(){
    #循环，创建软连接
    while [ ! -z ${2} ]
    do
	mount_point=$(filesystem-uuid-to-mountpath ${2})
	local path=$(echo ${mount_point}/${3}|tr -d '"')
	local sharedfolder=$(echo ${rootlink_path}/${1}|tr -d '"')
	#echo "${path}" "${sharedfolder}"
	ln -s "${path}" "${sharedfolder}"
	shift 3
    done
}
#filesystem-uuid-to-mountpath fafc4445-bcb2-47a5-a876-bfcec0e0b860
_init
