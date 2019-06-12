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
function manifest_fun()
{
    manifest=$(echo ${manifest}'<item id="'${1}'" href="'${2}'" media-type="'${3}'" />')
}

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
    types=$(echo ${metadata}|jq .types|jq -r .[0]|xargs -d / printf "%s;") #标签
    count2=0
    json1=$(echo ${json0}|jq .[${count2}]) #拆分json
    
    #epub文件结构生成
    mkdir -p ${bookname}&&cd ${bookname}
    mkdir epub&&mkdir epub/META-INF
    echo -n "application/epub+zip"> epub/minetype
    echo "PD94bWwgdmVyc2lvbj0iMS4wIj8+Cjxjb250YWluZXIgdmVyc2lvbj0iMS4wIiB4bWxucz0idXJuOm9hc2lzOm5hbWVzOnRjOm9wZW5kb2N1bWVudDp4bWxuczpjb250YWluZXIiPgogICAgPHJvb3RmaWxlcz4KICAgICAgICA8cm9vdGZpbGUgZnVsbC1wYXRoPSJib29rL2luZGV4Lm9wZiIKICAgICAgICAgICAgbWVkaWEtdHlwZT0iYXBwbGljYXRpb24vb2VicHMtcGFja2FnZSt4bWwiIC8+CiAgICA8L3Jvb3RmaWxlcz4KPC9jb250YWluZXI+Cg=="|base64 -d > epub/META-INF/container.xml  #生成容器文件
    mkdir epub/book
    mkdir epub/book/image
    curl ${cover} -O epub/image/cover.jpg
    manifest=$(echo ${manifest}'<item id="cover_image" href="image/cover.jpg" media-type="image/jpeg" />')  #追加封面图片文件
    manifest=$(echo ${manifest}'<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml" />')   #追加索引文件
    
    echo '<?xml version="1.0" encoding="UTF-8"?><package version="3.0" xmlns="http://www.idpf.org/2007/opf" unique-identifier="epub"><metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf"><dc:identifier id="epub">'"urn:uuid:$(uuidgen||cat /proc/sys/kernel/random/uuid)"'</dc:identifier><dc:title>'"${bookname}"'</dc:title><dc:language>'"${LANG%.*}"'</dc:language><dc:subject>'"${introduction}"'</dc:subject><dc:creator>'"${authors}"'</dc:creator><meta name="cover" content="cover_image"/></metadata>' > epub/book/index.opf #初始化包装文件
    echo '<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1"><head></head><docTitle><text>'"${bookname}"'</text></docTitle><navMap>' > epub/book/toc.ncx  #初始化目录索引文件

    	echo '<html><head>><meta charset="utf-8" /><title>'"${bookname}"'<title></head><body><p id="title_t"><img src="image/cover.jpg" /></p></body></html><h1>'${bookname}'</h1>' > epub/book/title.html   #生成标题文件
	manifest=$(echo ${manifest}'<item id="title_cover" href="title.html" media-type="application/xhtml+xml" />') #追加标题文件
	echo '<navPoint id="'title_title'"><navLabel><text>'${bookname}'</text></navLabel><content src="'"title.html#$title_t"'" />' >> epub/book/toc.ncx  #目录生成(根）
	spine=$(echo ${spine}'<itemref idref="'title.html'" linear="yes"/>' #载入顺序 标题1

	
    
    while [ "${json1:5:9}" == "volume_id" ]
    do
	count2=$(echo "${count2}+1"|bc)
	volume=$(echo ${json1}|jq .id) #获取卷id
	volume_name=$(echo ${json1}|jq .volume_name -r) #获取卷名
	json2=$(echo ${json1}|jq .chapters -r)#获取卷索引
	count3=0
	json3=$(echo ${json2}|jq .[${count3}])


	#epub,html生成
	echo '<!DOCTYPE html><html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops"><head><meta charset="utf-8" /><title>'"${bookname}-${volume_name}"'</title></head><body><h1>'"${volime_name}"'<\h1 id='"${volume}"'>'"${volume_name}"'<\h1>'  > epub/book/${volume}.html  #生成html头
	echo '<navPoint id="'volume_${volume}'"><navLabel><text>'${volume_name}'</text></navLabel><content src="'"${volume}.html#${volume}"'" />' >> epub/book/toc.ncx #追加链接至索引文件 （2）
	manifest=$(echo ${manifest}'<item id="'${volume}'" href="'${volume}.html'" media-type="application/xhtml+xml" />')  #追加当前卷html入包装文件


	
	while [ "${json3:5:10}" == "chapter_id" ]
	do
	    count3=$(echo "${count3}+1"|bc)
	    chapter=$(echo ${json3}|jq .chapter_id)  #获取章节id
	    chapter_name=$(echo ${json3}|jq .chapter_name -r)  #获取章节名
	    curl --retry 100 https://v3api.dmzj.com/novel/download/${title}_${volume}_${chapter}.txt -O  ${title}_${volume}_${chapter}.txt #下载正文
	    json3=$(echo ${json2}|jq .[${count3}])
	    
	    #epub，html
	    echo '<h2 id="'"${volume}_${chapter}"'">'"${chapter_name}"'</h2>'  #生成html头
	    text_chapter=$(cat ${title}_${volume}_${chapter}.txt)
	    image_download=$(echo ${title}|sed 's#https://xs.dmzj.com#\n&#g'|sed 's#"./>#\n#g'|grep --color=no xs.dmzj.com)  #筛选插画url


	    rows=0 #预定义图片
	    while [ -n "${image_download}" ]
	    do
		rows=$(echo "${rows}+1"|bc)
		image_url=$(echo "${image_down}"|sed -n "${rows}p")
		curl ${image_url} -O ${volume}_${chapter}_rows.${image_url##*.}
		text_chapter=$(echo "test_chapter"|sed "s%${image_url}%image/${volume}_${chapter}_rows.${image_url##*.}%g)"
	    done
	    
	done
	json1=$(echo ${json0}|jq .[${count2}])

    done
    shift
    echo '</package>'结束包装文件
    cd .. #返回脚本执行时路径

done
