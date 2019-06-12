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
    metadata=$(curl http://v2.api.dmzj.com/novel/${title}.json)  #获取书籍元数据
    json0=$(curl http://v2.api.dmzj.com/novel/chapter/${title}.json) #获取索引json
    #初始化变量
    bookname=$(echo ${metadata}|jq .name -r)   #书名
    authors=$(echo ${metadata}|jq .authors -r) #作者
    introduction=$(echo ${metadata}|jq .introduction -r) #书籍简介
    cover=$(echo ${metadata}|jq .cover -r) #封面图片链接
    curl ${cover} >cover.jpg #下载封面
    count2=0
    json1=$(echo ${json0}|jq .[${count2}]) #拆分json
    #html生成
    mkdir -p ${bookname}&&cd ${bookname}&&touch ${bookname}.html&&echo '<html>''<head>''<title>'"${bookname}"'</title>''</head>''<body>''<h1>'"${bookname}"'</h1>'>${bookname}.html
    while [ "${json1:5:9}" == "volume_id" ]
    do
	count2=$(echo "${count2}+1"|bc)
	volume=$(echo ${json1}|jq .id) #获取卷id
	volume_name=$(echo ${json1}|jq .volume_name -r) #获取卷名
	json2=$(echo ${json1}|jq .chapters -r)#获取卷索引
	echo '<h2>'"${volume_name}"'</h2>' >> ${bookname}.html #输出卷名
	count3=0
	json3=$(echo ${json2}|jq .[${count3}])
	while [ "${json3:5:10}" == "chapter_id" ]
	do
	    count3=$(echo "${count3}+1"|bc)
	    chapter=$(echo ${json3}|jq .chapter_id)  #获取章节id
	    chapter_name=$(echo ${json3}|jq .chapter_name -r)  #获取章节名
	    echo '<h3>'"${chapter_name}"'</h3>'>>${bookname}.html #输出章节名
	    curl https://v3api.dmzj.com/novel/download/${title}_${volume}_${chapter}.txt -O ${title}_${volume}_${chapter}.txt #下载正文
	    cat ${title}_${volume}_${chapter}.txt|sed "s%<br/>%</p><p>%g"| sed "s%<br />%</p><p>%g"|sed "s%^</p><p>% %g"|sed "s%</p><p>%</p>\n<p>%g" >> ${bookname}.html
	    json3=$(echo ${json2}|jq .[${count3}])


	    sleep $(echo $RANDOM % 20|bc)
	done
	json1=$(echo ${json0}|jq .[${count2}])
    done
    shift 
    echo '</p>''</body>''</html>'>> ${bookname}.html #html保存完毕
    cd .. #返回脚本执行时路径
done
