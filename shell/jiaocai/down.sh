#!/usr/bin
url=${1}
pwdpwd=$(pwd)
num_title=1
function mk_pdf_dir (){
    wget ${url} -O index.html
    while [ ${num_title} -le "$(cat index.html|grep '<h4>'|wc -l)" ]
    do
	num=$(cat index.html|grep -n '<h4>'|sed -n "${num_title},$(echo "${num_title}+1"|bc)p")
	#提取类别名，并创建文件夹
	series_name=$(echo "${num}"|head -n 1|cut -d : -f 2|sed 's#<*.h4>##g')
	mkdir ${series_name} ;cd ${series_name}
	#粗提取链接和书名
	sed -n "$(echo "${num}"|sed -n "1,2p"|cut -d : -f 1|tr '\n' ','|sed 's#,$##g')p" ../index.html > index.txt
	downpdf
	let num_title=num_title+1
    done
}
function downpdf (){
    cat index.txt|grep -e h6 -e pdf >url.txt
    num_title_url=1
    while [ "${num_title_url}" -le "$(wc -l url.txt|cut -f 1 -d ' ')" ]
    do
	let num_url=num_title_url+1
	url_file="$(sed -n "${num_title_url},${num_url}p" url.txt)"
	echo "${url_file}"|sed -e "s#href#\n&#g" -e "s#title#\n&#g" -e "s#\" #&\n#g"|tr '<' '\n'|tr '>' '\n'|grep -v 下载|grep -e pdf -e title >var.txt
	source var.txt
	filename="$(echo ${title}|tr ' ' '_').pdf"
	pdf_href="${url}${href}"
	wget -c ${pdf_href} -O ${filename}
	let num_title_url=num_title_url+2
	sleep $(echo "$RANDOM"%20+10|bc)
    done
    cd ${pwdpwd}
    }
mk_pdf_dir
