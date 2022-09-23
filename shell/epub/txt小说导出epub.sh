#! /bin/bash
_ad_text="
更新快无广告。  
２３ＵＳ．ＣＯＭ更新最快  
无广告的站点  
手机无广告 m. 最省流量了。  
手机无广告m.最省流量了。  
grep -v 本站重要通知
醋溜儿文学 更新最快  
顶点更新最快  
.手机最省流量,。  
.手机最省流量的站点。
[炫书网：www.3uww.cc]
声明：本书为炫书网(3uww.cc)的用户上传至其在本站的存储空间，本站只提供TXT全集电子书存储服务以及免费下载服务，以上作品内容之版权与本站无任何关系。
更多精彩电子书请登陆炫书网www.3uww.cc
<ahref=http://>欢迎广大友光临阅读，最新、最快、最火的连载作品尽在起点原创！
"
#_ad_text=$(cat ad_text.txt)
function _grep(){
    #file
    echo "${_ad_text}"|xargs -i -n 1 sed -i "s#{}##g" ${1}
}

function _html_h2(){
    tr -d '\r'|sed "s#^第.*#<h2>&</h2>#g"|sed "s#^..*\$#<p>&</p>#g"|sed "s#<p><h2>#<h2>#"|sed "s#</h2></p>#</h2>#g"
}
