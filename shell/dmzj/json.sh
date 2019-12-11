#! /bin/bash
id=0
#书目编号/开始id
num=0
#记次
exitnum=50
#连续空结果次数(超过退出)
file=./dmzj.json
while [ ${num} -lt ${exitnum} ]
do
    curl -s http://v2.api.dmzj.com/novel/${id}.json|jq -c|grep -v "\[\]" >> ${file} #||let num=num+1&&echo 空
    let id=id+1
    sleep $(echo ${RANDOM}%2|bc)
    echo -en "正在下载生成索引文件，已下载${id}个。\r"
done
