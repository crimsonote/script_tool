#! /bin/bash
DIR="$( cd "$( dirname "$0"  )" && pwd  )"
id=$(tail -1 ${DIR}/dmzj.json |jq .id)
[ -n "${id}" ] || id=0
#书目编号/开始id
num=0
#记次
exitnum=50
#连续空结果次数(超过退出)
file=${DIR}/dmzj.json
while [ ${num} -lt ${exitnum} ]
do
    let id=id+1
    curl -s http://v2.api.dmzj.com/novel/${id}.json|jq -c|grep -v "\[\]" >> ${file} ||let num=num+1
    sleep $(echo ${RANDOM}%2|bc)
    echo -en "正在下载生成索引文件，已下载${id}个。\r"
done
