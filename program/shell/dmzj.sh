#变量名称规定
#json* 索引拆分次数
#count* 计数器
#cycle* 循环跳出

book1=$@
if [ -z ${book1} ]
then
    read -p "请输入书籍变量:" book1
fi
#book1=$(echo $book1|xargs -d , printf "%s\n")

while [ -n "$(echo ${1}|sed -n '/^[0-9][0-9]*$/p')" ]
do
    title=$1
    json0=$(curl http://v2.api.dmzj.com/novel/chapter/${title}.json) #获取索引json
    count2=0
    json1=$(echo ${json0}|jq .[${count2}]) #拆分json
    while [ "${json1:5:9}" == "volume_id" ]
    do
	count2=$(echo "${count2}+1"|bc)
	volume=$(echo ${json1}|jq .id) #获取卷id
	json2=$(echo ${json1}|jq .chapters)#获取卷索引
	count3=0
	json3=$(echo ${json2}|jq .[${count3}])
	while [ "${json3:5:10}" == "chapter_id" ]
	do
	    count3=$(echo "${count3}+1"|bc)
	    chapter=$(echo ${json3}|jq .chapter_id) #获取章节id
	    curl https://v3api.dmzj.com/novel/download/${title}_${volume}_${chapter}.txt >${title}_${volume}_${chapter}.txt
	    json3=$(echo ${json2}|jq .[${count3}])
	done
	json1=$(echo ${json0}|jq .[${count2}])
    done
    shift
done
