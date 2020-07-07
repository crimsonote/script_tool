file=/tmp/.duxiu-url-test.log
#downboox.sh第一个参数，源链接。第二个参数，书名。第三个参数，类型值。第四个参数，该类的页码。第五个参数，图片大小。
basedir=`cd $(dirname $0); pwd -P`
nano ${file}
url=$(cat ${file}|sed 's#/n/#\nhttp://img.sslibrary.com&#g'|grep "\/n\/"|sed 's#......?zoom=.##g')
#url=$(cat ${file}|sed 's#......?zoom=.##g')
rm ${file}
echo "正要执行bash -x ${basedir}/downboox.sh ${url} ${1} ${2} ${3} ${4}"
read -p "是否执行[y/n]" yn
if [ "${yn}" == "y" ]
then
  bash -x ${basedir}/downboox.sh ${url}  ${1} ${2} ${3} ${4}
fi
