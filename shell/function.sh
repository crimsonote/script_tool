#! /bin/bash
function mas-to-zh (){
    #万以内的阿拉伯数字转中文数字
    #数字初步替换为中文，并倒置
    digital=$(echo "${1}"|sed -e "s#0#零#g" -e "s#1#一#g" -e "s#2#二#g" -e "s#3#三#g" -e "s#4#四#g" -e "s#5#五#g" -e "s#6#六#g" -e "s#7#七#g" -e "s#8#八#g" -e "s#9#九#g"|rev)
    num=$(expr length "${digital}")
    #位数添加
    while [ "${num}" != "0" ]
    do
	  case ${num} in
	      1)
		  #最后的处理
		  endx=0
		  while [ "${endx}" != 10 ]
		  do
		      local digital_local=${digital} ;
		      #删除多余的“零”
		      local digital_local=$(echo "${digital_local}"|sed -e "s#零[^一二三四五六七八九]零#零#g");
		      if [ ${digital_local} != "${digital}" ]
		      then
			  digital=${digital_local}
		      else
			  digital=${digital_local}
			  endx=10
		      fi
		  done
		  #输出前最后的处理
		  echo "${digital}"|sed -e "s#^零##g" -e "s#[十百千万]零#零#g" -e "s#十一\$#十#g"|rev;
		  let num=num-1;;
	      2)
		  #添加数位十
		  digital=$(echo "${digital}"|sed -e "s#^.#&十#g");
		  let num=num-1;;
	      3)
		  #添加数位百
		 digital=$( echo "${digital}"|sed -e "s#^..#&百#g");
		  let num=num-1;;
	      4)
		  #添加数位千
		  digital=$(echo "${digital}"|sed -e "s#^...#&千#g");
		  let num=num-1;;
	      5)
		  #添加数位“万”
		  digital=$(echo "${digital}"|sed -e "s#^....#&万#g");
		  let num=num-1
	  esac
    done
}

function output-random-number (){
    #输出指定范围的随机数。
    #用法 $: output-random-number 数值 大于前项的数值
function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
    echo $(($num%$max+$min))
}
local numa=${1}
local numb=${2}
rnd=$(rand ${numa:-0} ${numb:-100})
echo $rnd

return 0
    }
