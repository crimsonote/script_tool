#!/bin/bash
current_path=$(cd "$(dirname $0)";pwd)
source ${current_path}/../function.sh
function txt_toc(){
    #用于提取txt的目录
    #参数1:txt文件路径
    #   cat "${1}" |grep -nE "^第[0-9零一二三四五六七八九十百千]" >> toc.log
    cat "${1}" |grep -nE '^[^　 ]' >toc.log
    list_toc="$(cat toc.log|cut -f 1 -d ":")"
    }
function txt_fenge(){
    #
    
    }

function diff_toc(){
    #比较各版本txt的目录差异
    
    }
