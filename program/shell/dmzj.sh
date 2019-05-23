#变量名称规定
#json* 索引拆分次数
#count* 计数器
#cycle* 循环跳出

book1=$@
if [ -z ${book1} ]
then
    read -p "请输入书籍变量" book1
fi
book1=$(echo $book1|xargs -d , printf "%s\n")
#function download ()
#{
#    
#    ZHENHE=$(curl http://v2.api.dmzj.com/novel/chapter/$(echo $book|xargs -d ,).json)
#    wget https://v3api.dmzj.com/novel/download/${title}_${volume}_${chapter}.txt
#}
while [ -n ${book1} ]
do
    title=$(echo ${book1}|sed -n "1p")
    json0=$(curl http://v2.api.dmzj.com/novel/chapter/${title}.json) #获取索引json
    count2=0
    json2=aaaaavolume_id
    while [ $(json2:5:9} == volume_id ]
    do
	json1=$(echo ${json0}|jq .[${count2}]) #拆分json
	count2=$(echo "${count2}+1"|bc)
	volume=$(echo ${json1}|jq .id) #获取卷id
	json2=$(echo ${json1}|jq .chapters)#获取卷索引
	count3=0
	json3=aaaaachapter_id
	while [ "${json3:5:10}" == "chapter_id" ]
	do
	    json3=$(echo ${json2}|jq .[${count3}])
	    count3=$(echo "${count3}+1"|bc)
	    chapter=$(echo ${json3}|jq .chapter_id) #获取章节id
	    curl https://v3api.dmzj.com/novel/download/${title}_${volume}_${chapter}.txt >${title}_${volume}_${chapter}.txt
	done
    done
    book1=$(echo $book1|sed '1d')
done
