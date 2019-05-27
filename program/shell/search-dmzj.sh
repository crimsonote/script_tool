#变量名称规定
#json* 索引拆分次数
#count* 计数器
search=$@
if [ -z ${search} ]
then
    read -p "请输入要搜索的关键词:" search

fi

json0=$(curl "http://s.acg.dmzj.com/lnovelsum/search.php?s=${search}")
#json0=$(cat search.json)
json1=${json0:20}
count1=0
json2=$(echo $json1|jq .[${count1}])
while [ -n "${search}" ]&&[ "${json2:5:6}" == author ]
do
    count1=$(echo "${count1}+1"|bc)
    lnovel_name=$(echo $json2|jq .lnovel_name)
    echo "书名：《${lnovel_name}》"
    author=$(echo $json2|jq .author)
    echo "作者：${author}"
    description=$(echo $json2|jq .description)
    echo "简介：${description}"
    read -t 5 -p "是否下载[Y/n]" boolean
    case ${boolean} in
	N|n)
	    echo "载入下一条....."
	;;
	*)
	    book=$(echo "${json2}"|jq .lnovel_url |xargs -d / printf "%s\n" |sed -n "2p")
	    book1=$(echo "${book1} ${book}")
		    ;;
    esac
    json2=$(echo $json1|jq .[${count1}])
done
echo $book1
#./dmzj.sh ${book1}
