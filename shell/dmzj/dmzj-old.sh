#变量名称规定
#json*a 详情拆分次数
#json*b 索引拆分次数
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
    title_id=$1
    json0a=$(curl http://v2.api.dmzj.com/novel/${title_id}.json)
    json0b=$(curl http://v2.api.dmzj.com/novel/chapter/${title_id}.json) #获取索引json
    count2=0
    json1b=$(echo ${json0b}|jq .[${count2}]) #拆分json
    while [ "${json1b:5:9}" == "volume_id" ]
    do
	count2=$(echo "${count2}+1"|bc)
	volume_id=$(echo ${json1b}|jq .id) #获取卷id
	json2b=$(echo ${json1b}|jq .chapters)#获取卷索引
	count3=0
	json3b=$(echo ${json2b}|jq .[${count3}])
	while [ "${json3b:5:10}" == "chapter_id" ]
	do
	    count3=$(echo "${count3}+1"|bc)
	    chapter_id=$(echo ${json3b}|jq .chapter_id) #获取章节id
	    curl https://v3api.dmzj.com/novel/download/${title_id}_${volume_id}_${chapter_id}.txt >${title_id}_${volume_id}_${chapter_id}.txt
	    json3b=$(echo ${json2b}|jq .[${count3}])
	done
	json1b=$(echo ${json0b}|jq .[${count2}])
    done
    shift
done
