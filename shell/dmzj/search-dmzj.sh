#变量名称规定
#json* 索引拆分次数
#count* 计数器
search=$@
if [ -z ${search} ]
then
    read -p "请输入要搜索的关键词:" search

fi
DIR="$( cd "$( dirname "$0"  )" && pwd  )"  
[ -f ${DIR}/dmzj.json ]||(${DIR}/json.sh)
json0=$(cat ${DIR}/dmzj.json|grep "${search}")
count1=1
json2=$(echo "${json0}"|sed -n "${count1}p")
while [ -n "${search}" ]&&[ "${json2:2:2}" == id ]
do
    count1=$(echo "${count1}+1"|bc)
    lnovel_name=$(echo $json2|jq .name)
    echo -e "书名：《${lnovel_name}》"
    author=$(echo $json2|jq .authors)
    echo -e "作者：${author}"
    description=$(echo $json2|jq .introduction)
    echo -e "简介：${description}"
    read -t 15 -p "是否下载[Y/n]" boolean
    case ${boolean} in
	N|n)
	    echo "载入下一条....."
	;;
	*)
	    #	    book=$(echo "${json2}"|jq .lnovel_url |xargs -d / printf "%s\n" |sed -n "2p")
	    book=$(echo "${json2}"|jq .id)
	    book1=$(echo "${book1} ${book}")
	    ;;
    esac
    json2=$(echo "${json0}"|sed -n "${count1}p")
done
echo "书目编号：${book1}"
#./dmzj.sh ${book1}
read -p "确认下载？ [Y/n]" -t 15  download
case ${download} in
    N|n)
	exit
	;;
    *)
	echo "${book1}" |xargs ${DIR}/dmzj-epub.sh
	;;
esac
