deld_txt="$(cat ${2})"
num=1
while [ ${num} -le $(echo "${deld_txt}"|wc -l) ]
do
	deld_txt_m=$(echo "${deld_txt}"|sed -n "${num}p")
	sed "s#${deld_txt_m}##g" $1 -i
	let num=num+1
done
