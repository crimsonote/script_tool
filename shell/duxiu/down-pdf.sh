#! /bin/bash
url=$1
if [ -z ${url:0:1} ]
then
    read -p "请输入url:" url
fi
function duxiu-downimg(){
    #downimg "链接url" "补全位数" "类型编码" 
    num=1
    nums=$(printf "%0${2}i" "${num}")
    file=${3}${nums}.jpg
    while [ "$(md5sum "${files}"|awk -F " " '{print $1}')" != "9bcaf3fe00d1c5c5f4fe16cd0db266c4" ]
    do
	wget -c --random-wait "${1}${3}${nums}?zoom=2" -O "${file}"
	let num=num+1
	nums=$(printf "%0${2}i" "${num}")
	file=${3}${nums}.jpg
	sleep "$(echo "${RANDOM}%30"|bc)"
	files="${file}"
    done
    printf "下载完成（疑似）" >&2
    echo "${num}"
    return 0	  
}

function dir_down(){
    a=$(echo "3 cov,3 bok,3 leg,3 fow,5 !,6"|tr ',' '\n')
    
    }

function downcov(){
    #下载封面
    duxiu-downimg "${url}" "3" "cov"
}

function downbok(){
    #下载开题
    duxiu-downimg "${url}" "3" "bok"
}

function downleg(){
    #下载书目信息
    duxiu-downimg "${url}" "3" "leg"
}

function downfow(){
    #下载前言
    duxiu-downimg "${url}" "3" "fow"
}

function downtoc(){
    #下载目录
    duxiu-downimg "${url}" "5" "!"
}

function downnull(){
    #下载正文
    duxiu-downimg "${url}" "6"
}

