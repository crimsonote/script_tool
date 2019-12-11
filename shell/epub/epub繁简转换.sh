#!/bin/bash
#批量转换可以使用
#xargs -i -n 1 bash ~/private_notes/program/shell/epub繁简转换.sh "{}"
PATH=${HOME}/local/bin:${PATH}
TMPFILE="$(mktemp -d)"
mkdir -p t2s
trap "rm -rf ${TMPFILE}; exit" 2 15 13
path="$(pwd)/"
epubfile="$@"
unzip -d "${TMPFILE}" "${epubfile}"
cd ${TMPFILE}
function t2s_file(){
#将给定文件转换为简体
while [ -n "$1" ]
do  #判断是否为纯文本文件
    [ -n "$(file "${1}" |grep text)" ] && opencc -c t2s -i "${1}" -o "${1}"
    shift
done
}

t2s_file $(find ${TMPFILE}|grep -vE ".jpg|.png|.jpeg"|tr '\n' ' ')
zip -Xu0 "${epubfile##*/}" mimetype
zip -Xu9r "${epubfile##*/}" */
cp "${epubfile##*/}" "$(echo "${path}/t2s/""${epubfile##*/}"|sed "s#.epub#-t2s.epub#g")"
rm -rf ${TMPFILE}
