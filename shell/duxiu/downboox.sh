#!/bin/bash
#第一个参数，源链接。第二个参数，书名。第三个参数，类型值。第四个参数，该类的页码。第五个参数，图片大小。
url="$(echo "${1}"|sed 's#......?zoom=.##g')"
title="${2}"
series_list="cov,bok,leg,fow,ncx,txt"
series_list_num="$(echo ${series_list}|tr ',' '\n'|wc -l)"
series_num=${3:-1}
pages=${4:-1}
img_size=${5:-2}

img_size=${img_size:-2}
#ncx替换为!,txt替换为null(空)
pwdth=$(pwd)
wget_param="-e "http_proxy=http://localhost:8888" --user-agent="Mozilla/5.0""

function edit_url(){
    #处理url链接
    orig_url="${1}"
    url=$(echo "${orig_url}"|sed 's#......?zoom=.##g')
    wget ${wget_param} ${url} -O trash/error.log
    }


function mk_dir_x(){
    #创建文件夹
    mkdir -p "${title}"&&cd "${title}"
    echo ${series_num:-1} >/dev/null
    while [ "${series_num:-1}" -le "${series_list_num}" ]
    do
	series_name="$(echo "${series_list}"|cut -d , -f ${series_num})"
	mkdir -p "${series_name}"&&cd "${series_name}"
	down_image "${series_name}" ${pages} 
	cd ..
	let series_num=series_num+1
    done
#    img_merge_pdf
    cd ${pwdth}
}

function down_image(){
    #下载图片
    series_name_type="$(echo "${1}"|sed -e 's#ncx#!#g' -e 's#txt##g' )"
    img_x="$(echo "6-$(echo ${series_name_type}|tr -d '\n'|wc -c)"|bc)"
    seq=${2}
    echo ${seq:-1} >/dev/null
    file=${seq}.jpg
    while [ "${error_num}" != "2"  ]
    do
	seqs=$(printf "%0${img_x}i" "${seq}")
	wget ${wget_param} --limit-rate=300k --random-wait ${url}${series_name_type}${seqs}?zoom=${img_size} -O ${file} || let error_num=error_num+1
	#	[ "$(md5sum "${file}"|cut -f 1 -d ' ')" != "9bcaf3fe00d1c5c5f4fe16cd0db266c4" ] || (let error_num=error_num+1&&rm ${file})
	xxx=999
	file_hash=$(md5sum "${file}"|cut -f 1 -d ' ')
	while [ "${xxx}" == "999" ]
	do
	    case ${file_hash} in
		9bcaf3fe00d1c5c5f4fe16cd0db266c4)
		    echo "下载到无资源文件"
		    let seq=seq+1
		    let error_num=error_num+1
		    mkdir -p trash
		    mv ${file} trash
		    xxx=5
		    ;;
		
		a1ec31a16605c707bdcb6c00066f5c7b)
		    echo "网址要求验证码"
		    read -p "使用浏览器打开？[y/N]" -t 60 enter
		    if [ "${enter}" == "y" -o "${enter}" == "Y" ]
		    then
			firefox  ${url}${series_name_type}${seqs}?zoom=${img_size}
			read -p "验证码输入成功后请按回车" enter
		    fi
		    mkdir -p trans;mv ${file} trans
		    sleep $(echo $RAMDOM%200+${delay})
		    let delay=delay+60
		    wget ${wget_param} --limit-rate=300k --random-wait ${url}${series_name_type}${seqs}?zoom=${img_size} -O ${file} || let error_num=error_num+1
		    xxx=999
		    file_hash=$(md5sum "${file}"|cut -f 1 -d ' ')
		    ;;

		other)
		    mkdir -p trans;mv ${file} trans
		    echo "下载到非图片文件，可能需要暂停和手动处理——更新链接"
		    echo "可能需验证码或登陆凭据失效"
		    read -p "输入update更新url，输入Ctrl+C退出脚本,60s无输入自动退出" -t 60 other
		    case $other in
			update)
			    read -p "请在这里输入新的url: " new_url
			    edit_url "${new_url}"&& file_hash="OK"
			    ;;
			*)
			    echo "退出"
			    exit 2
			    ;;
		    esac
		    ;;
		
		*)
		    if file "${file}"|grep image >/dev/null
		       then
			   echo "${1} ${series_num}  ${seq}" >${pwdth}/history-${title}.log
			   echo "${file}" >> file.log
			   echo "${1}"/"${file}" >> ${pwdth}/${title}/img_to_pdf.log
			   let seq=seq+1
			   xxx=0
		    else
			x=999
			file_hash=other
		    fi
		    ;;
	    esac
	done
	delay=0
	file=${seq}.jpg
	sleep $(echo $RANDOM%10+10|bc)
    done
    
    echo "$(date)在${1}下载了${seq}张图片。" >>down.log
    error_num=0
    convert $(ls *.jpg|sort -n) $1.pdf >/dev/null
}

function img_merge_pdf(){
    convert cov/1.jpg cov/1.pdf
    convert cov/2.jpg cov/2.pdf
    tmp_pdf_list="cov/1.pdf,bok/bok.pdf,leg/leg.pdf,fow/fow.pdf,ncx/ncx.pdf,txt/txt.pdf,cov/2.pdf"
    tmp_pdf_list_num="$(echo "${tmp_pdf_list}"|tr ',' '\n'|wc -l)"
    tmp_pdf_num=1
    while [ "${tmp_pdf_num}" -le "${tmp_pdf_list_num}" ]
    do
	tmp_pdf_file=$(echo ${tmp_pdf_list}|cut -f ${tmp_pdf_num} -d ',')
	if [ -f ${tmp_pdf_file} ]
	then
	    tmp_pdf_file_ok=${tmp_pdf_file}
	fi
	tmp_pdf="${tmp_pdf} ${tmp_pdf_file_ok}"
	let tmp_pdf_num=tmp_pdf_num+1
	tmp_pdf_file_ok=""
    done
    gs -q -sDEVICE=pdfwrite -dBATCH -sOUTPUTFILE=${title}.pdf -dNOPAUSE ${tmp_pdf}
    rm cov/1.pdf cov/2.pdf
}
mk_dir_x
