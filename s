<html><head>
<title>中国重汽ERP信息网</title>
<!--meta http-equiv="Content-Type" content="text/html; charset=gb2312"-->
<style type="text/css">
<!--
.STYLE9 {font-size: 12px}
.STYLE12 {color: #999999}
.STYLE13 {color: #999999; font-size: 12px; }
.STYLE11 {font-size: 12px; color: #003300; }
.STYLE19 {	color: #000033;
	font-size: 12px;
}
.STYLE21 {color: #000033}
.STYLE23 {color: #003300}
.STYLE43 {color: #CCCCCC; font-size: 12px; }
.STYLE50 {color: #CCCCCC}
.STYLE45 {color: #000000; font-size: 12px; }
a:link {
	color: #666666;
	text-decoration: none;
}
a:visited {
	color: #666666;
	text-decoration: none;
}
a:hover {
	color: #FF0000;
	text-decoration: underline;
}
a:active {
	color: #00FF00;
	text-decoration: none;
}
.STYLE8 {font-size: 14px}
.STYLE22 {	font-family: "Times New Roman", Times, serif;
	font-size: 18px;
	font-weight: bold;
	font-style: italic;
	color: #003366;
}
.STYLE15 {	font-family: "Times New Roman", Times, serif;
	font-size: 12px;
	color: #666666;
}
.STYLE17 {font-size: 12px; color: #666666; }
a:link {
	color: #666666;
}
.STYLE53 {color: #0000FF; font-size: 12px;}
-->
</style>
<script id="clientEventHandlersJS" language="javascript">
<!--
function plogin_onclick() {
   var Location="http://mail.cnhtc.cn/exchange/";         //定义你的exchange 2000 server OWA路径
   
if (window.XMLHttpRequest) 
	{ //Mozilla浏览器
		var auth = new XMLHttpRequest();
	}
else if (window.ActiveXObject) 
{ //IE浏览器
	try 
		{
			var auth = new ActiveXObject("Msxml2.XMLHTTP");
		} 
	catch (e) 
		{
			try 
			{
				var auth = new ActiveXObject("Microsoft.XMLHTTP");
			}
			catch (e) {}
		}
	}
    //var auth = newXMLHttpRequest()
   //var auth = new ActiveXObject("msxml2.xmlhttp")      //创建msxml2.xmlhttp对象

   auth.open("get",Location,false,login.name.value ,login.pwd.value )  
      //auth的open方法，用HTML页面里的login form里的name和pwd 以及Location作为参数，具体说明见参考信息（2）
   auth.send()                           //auth的send 方法。 
            
   switch(auth.status){                  //检测auth.send以后的状态，
     case 200:                           //状态为：200代表用户名密码正确，
       window.location.href = Location; //浏览器重转向至exchange 2000 server OWA
       break; 
     case 401:                           //状态为：401代表用户名密码不正确，身份验证错误
       alert("用户无效或密码错误。");    //报错
       break;  
     default:                            //其它状态，如服务器无法访问
       alert("对不起，服务器发生错误，请稍后再试！");      //报错
   } 
}

function MM_openBrWindow(theURL,winName,features) { //v2.0
  window.open(theURL,winName,features);
}
//-->
</script>
<meta http-equiv="Content-Type" content="text/html; charset=gbk"></head>
<body leftmargin="0" topmargin="0" bgcolor="#FFFFFF" marginheight="0" marginwidth="0">
<form name="login" method="post">
<!-- ImageReady Slices (erp.psd) -->
<table id="__01" height="1176" align="center" border="0" cellpadding="0" cellspacing="0" width="1001">
	<tbody><tr>
		<td rowspan="4">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_01.jpg" alt="" height="240" width="1"></td>
		<td colspan="3" rowspan="3">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_02.jpg" alt="" height="239" width="264"></td>
		<td colspan="8">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_03.jpg" alt="" height="16" width="735"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="16" width="1"></td>
	</tr>
	<tr>
		<td colspan="8" background="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_04.jpg"><table border="0" cellpadding="0" cellspacing="0" width="100%">
          <tbody><tr>
            <td width="5%">&nbsp;</td>
            <td width="13%"><span class="STYLE8"><a href="http://www.cnhtcerp.com/bbs" target="_blank">进入论坛</a></span></td>
            <td width="6%"><span class="STYLE8"></span></td>
            <td width="12%"><span class="STYLE8"><a href="http://mail.cnhtc.cn/" target="_blank">企业邮箱</a></span></td>
            <td width="6%"><span class="STYLE8"></span></td>
            <td width="12%"><span class="STYLE8"><a href="http://www.cnhtcerp.com/down.html" target="_blank">下载专区</a></span></td>
            <td width="6%"><span class="STYLE8"></span></td>
            <td width="12%"><span class="STYLE8"><a href="http://www.cnhtcerp.com/glzd" target="_blank">管理制度</a></span></td>
            <td width="7%"><span class="STYLE8"></span></td>
            <td width="11%"><span class="STYLE8"><a href="#" target="_blank">联系我们</a></span></td>
            <td width="10%">&nbsp;</td>
          </tr>
        </tbody></table></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="38" width="1"></td>
	</tr>
	<tr>
		<td colspan="8" rowspan="3" background="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_05.jpg"><object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,19,0" height="273" width="733">
          <param name="movie" value="images/59.swf">
          <param name="quality" value="high">
          <param name="wmode" value="transparent">
          <embed src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/59.swf" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" wmode="transparent" height="273" width="733">
        </object></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="185" width="1"></td>
	</tr>
	<tr>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_06.jpg" alt="" height="1" width="105"></td>
		<td colspan="2" rowspan="3" background="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_07.jpg">
		
		<table height="102" border="0" cellpadding="0" cellspacing="0" width="158">
          <tbody><tr>
            <td height="30">&nbsp;</td>
          </tr>
          <tr>
            <td height="20"><span class="STYLE9">用户：</span>
            <input name="name" size="14" maxlength="20" type="text"></td>
          </tr>
          <tr>
            <td height="19"><span class="STYLE9">口令：</span>
            <input name="pwd" size="14" maxlength="20" type="password"></td>
          </tr>
          <tr>
            <td>
                <input name="plogin" value="登陆" language="javascript" onclick="return plogin_onclick()" type="button">
                <span class="STYLE53" onclick="MM_openBrWindow('email.html','邮箱登陆','width=450,height=650')"><a href="#">无法登陆怎么办？</a></span></td>
          </tr>
        </tbody></table></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="1"></td>
	</tr>
	<tr>
		<td colspan="2" rowspan="2">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_08.jpg" alt="" height="105" width="106"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="91" width="1"></td>
	</tr>
	<tr>
		<td colspan="8">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_09.jpg" alt="" height="14" width="735"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="14" width="1"></td>
	</tr>
	<tr>
		<td colspan="4" rowspan="5" background="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_10.jpg"><object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,19,0" height="185" width="265">
          <param name="movie" value="images/flash8net_8444.swf">
          <param name="quality" value="high">
          <param name="BGCOLOR" value="#F3F3F3">
          <param name="wmode" value="transparent">
          <embed src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/flash8net_8444.swf" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" bgcolor="#F3F3F3" wmode="transparent" height="185" width="265">
        </object></td>
		<td colspan="5" rowspan="2">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/1t4.jpg" alt="" height="55" width="464"></td>
		<td colspan="3">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_12.jpg" alt="" height="52" width="271"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="52" width="1"></td>
	</tr>
	<tr>
		<td colspan="2" rowspan="2" background="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_13.jpg"><table height="97" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tbody><tr>
            <td width="11%"><div class="STYLE11" align="center">◇</div></td>
            <td class="STYLE19" width="89%"><a href="http://www.cnhtcerp.com/hydt/hydt_5yglxxhdsj.html" target="_blank" class="STYLE9">5月管理信息化大事记</a></td>
          </tr>
          <tr>
            <td><div class="STYLE11" align="center">◇</div></td>
            <td><a href="http://www.cnhtcerp.com/hydt/hydt_gclqwrhsngwr.html" target="_blank" class="STYLE9">盖茨离去 微软还是那个微软?</a></td>
          </tr>
          <tr>
            <td><div class="STYLE11" align="center">◇</div></td>
            <td><a href="http://www.cnhtcerp.com/hydt/hydt_hwxcxsSAPqdQXERPXT.html" target="_blank" class="STYLE9">海王星辰携手SAP启动全新ERP系统</a></td>
          </tr>
          <tr>
            <td><div class="STYLE11" align="center">◇</div></td>
            <td class="STYLE21"><a href="http://www.cnhtcerp.com/hydt/hydt_zgqclbjdjs.html" target="_blank" class="STYLE9">观察:中国汽车零部件的“救赎”</a></td>
          </tr>
          <tr>
            <td><div class="STYLE11" align="center">◇</div></td>
            <td><span class="STYLE9"><a href="#" target="_blank">更多...&gt;</a>&gt;</span></td>
          </tr>
        </tbody></table></td>
		<td rowspan="20">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_14.jpg" alt="" height="778" width="28"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="3" width="1"></td>
	</tr>
	<tr>
		<td colspan="5" rowspan="2" background="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_15.jpg"><table height="98" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tbody><tr>
            <td width="8%">&nbsp;</td>
            <td width="92%"><span class="STYLE9">&nbsp;&nbsp;&nbsp;&nbsp;中国重汽ERP信息网是中国重汽技术发展部建立的用于对企业信息化</span></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><span class="STYLE9">建设进行宣传、探讨与学习的窗口，也是企业信息系统的门户，同时也是</span></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><span class="STYLE9">大家交流与学习信息技术相关知识的平台。</span></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><span class="STYLE9">&nbsp;&nbsp;&nbsp;&nbsp;随着中国重汽产量与销量的连年递增，随着中国重汽在中国重型汽车</span></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><span class="STYLE9">市场上突飞猛进的发展，中国重汽的信息化建设近几年内也取得了前所未有的</span></td>
          </tr>
        </tbody></table></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="102" width="1"></td>
	</tr>
	<tr>
		<td colspan="2" rowspan="3">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/1t2.jpg" alt="" height="53" width="243"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="1"></td>
	</tr>
	<tr>
		<td rowspan="17">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_17.jpg" alt="" height="672" width="43"></td>
		<td colspan="2" rowspan="3">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/1pic1.jpg" alt="" height="95" width="143"></td>
		<td rowspan="6"><table height="168" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tbody><tr>
            <td width="9%">&nbsp;</td>
            <td width="91%"><span class="STYLE9">成绩。中国重汽完全凭借自己的力量先后开</span></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><span class="STYLE9">发了销售一线通管理信息系统、服务备件一</span></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><span class="STYLE9">线通管理信息系统、国际服务备件一线通系</span></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><span class="STYLE9">统、人力资源管理系统、全面资金预算管理</span></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><span class="STYLE9">系统、企业资产管理系统等应用系统。我们</span></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><span class="STYLE9">本着简单开发、快速应用、分步实施、逐渐</span></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><span class="STYLE9">完善的原则，为企业量身定做了上述信息系</span></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><span class="STYLE9">统。在企业生产经营活动中起到了重要的作用。</span></td>
          </tr>
        </tbody></table></td>
		<td rowspan="2">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/1t2-21.jpg" alt="" height="52" width="1"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="27" width="1"></td>
	</tr>
	<tr>
		<td colspan="4" rowspan="3">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_21.jpg" alt="" height="120" width="265"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="25" width="1"></td>
	</tr>
	<tr>
		<td colspan="3" rowspan="3"><table height="109" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tbody><tr>
            <td width="13%"><div class="STYLE11" align="center">◇</div></td>
            <td width="86%"><span class="STYLE9"><a href="http://www.cnhtcerp.com/soft/new2007/xs_fwz.msi">卡车服务备件一线通服务站</a></span></td>
          </tr>
          <tr>
            <td><div class="STYLE11" align="center">◇</div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/down.html">服务备件一线通下载网</a></span></td>
          </tr>
          <tr>
            <td><div class="STYLE11" align="center">◇</div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/down.htnl" target="_blank">更多下载...&gt;&gt;</a></span></td>
          </tr>
        </tbody></table></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="43" width="1"></td>
	</tr>
	<tr>
		<td colspan="2" rowspan="3">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_23.jpg" alt="" height="79" width="143"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="52" width="1"></td>
	</tr>
	<tr>
		<td colspan="3" rowspan="4" background="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_24.jpg"><table height="156" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tbody><tr>
            <td width="10%">&nbsp;</td>
            <td width="8%"><div class="STYLE12" align="center"><span class="STYLE9">◆</span></div></td>
            <td width="82%"><a href="http://www.cnhtcerp.com/sales/" target="_blank" class="STYLE9">中国重汽营销管理协作平台</a></td>
          </tr>
  	<tr>
            <td></td>
            <td></td>
            <td></td>
          </tr>
  	<tr>
            <td></td>
            <td></td>
            <td></td>
          </tr>
  	<tr>
            <td></td>
            <td></td>
            <td></td>
          </tr>
  	<tr>
            <td></td>
            <td></td>
            <td></td>
          </tr>
          </tbody></table></td>
		<td rowspan="13">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_25.jpg" alt="" height="525" width="1"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="17" width="1"></td>
	</tr>
	<tr>
		<td colspan="3" rowspan="2">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/1t3.jpg" alt="" height="54" width="244"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="10" width="1"></td>
	</tr>
	<tr>
		<td colspan="3">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_27.jpg" alt="" height="44" width="420"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="44" width="1"></td>
	</tr>
	<tr>
		<td colspan="3" rowspan="3"><table height="186" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tbody><tr>
            <td width="3%"><div align="center"><span class="STYLE11">□</span></div></td>
            <td width="49%"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_winxpwfqd.html" target="_blank" class="STYLE9">排除WindowsXP无法启动故障(10方法)</a></td>
            <td width="3%"><div align="center"><span class="STYLE11">□</span></div></td>
            <td width="43%"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_outlook.html" target="_blank" class="STYLE9">OutLook使用技巧大全</a></td>
          </tr>
          <tr>
            <td><div align="center"><span class="STYLE11">□</span></div></td>
            <td><span class="STYLE9"><span class="STYLE21"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_dn10gryfsdwt.html" target="_blank">电脑10个容易发生的问题及解决方法</a></span></span></td>
            <td><div align="center"><span class="STYLE11">□</span></div></td>
            <td><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_zqyx.html" target="_blank" class="STYLE9">重汽邮箱使用方法</a></td>
          </tr>
          <tr>
            <td><div align="center"><span class="STYLE11">□</span></div></td>
            <td><span class="STYLE9"><span class="STYLE21"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_firefox.html" target="_blank">Firefox 3 更快、更安全、更个性</a></span></span></td>
            <td><div align="center"><span class="STYLE11">□</span></div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_wjjm.html" target="_blank">文件加密与解密的应用技巧</a></span></td>
          </tr>
          <tr>
            <td><div align="center"><span class="STYLE11">□</span></div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_czczxt.html" target="_blank">重装操作系统以后避免中毒的十件大事</a></span></td>
            <td><div class="STYLE9" align="center"><span class="STYLE23">□</span></div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_nczsk.html" target="_blank">内存知识库之什么是内存双通道</a></span></td>
          </tr>
          <tr>
            <td><div align="center"><span class="STYLE11">□</span></div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/xxyjl/xxjyl_tgjckmm.html" target="_blank">透过进程巧妙判断出病毒和木马</a></span></td>
            <td><div class="STYLE9" align="center"><span class="STYLE23">□</span></div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_WinXPjc.html" target="_blank">WinXP常见进程</a></span></td>
          </tr>
          <tr>
            <td><div align="center"><span class="STYLE11">□</span></div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_bksbd.html" target="_blank">格式化都没用?清除"不可杀"病毒技巧</a></span></td>
            <td><div class="STYLE9" align="center"><span class="STYLE23">□</span></div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_arp.html" target="_blank">六招解决ARP病毒反复发作</a></span></td>
          </tr>
          <tr>
            <td><div align="center"><span class="STYLE11">□</span></div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_jcmmml.html" target="_blank">检查电脑是否被安装木马三个小命令</a></span></td>
            <td><div class="STYLE9" align="center"><span class="STYLE23">□</span></div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_rsjywbd.html" target="_blank">认识局域网病毒七大特点</a></span></td>
          </tr>
          <tr>
            <td height="20"><div align="center"><span class="STYLE11">□</span></div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_wlaqdqdwq.html" target="_blank">网络安全的七大误区</a></span></td>
            <td><div class="STYLE9" align="center"><span class="STYLE23">□</span></div></td>
            <td><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_WinXPAZ.html" target="_blank" class="STYLE9">如何安装XP系统--图文详解</a></td>
          </tr>
          <tr>
            <td height="16"><div align="center"><span class="STYLE11">□</span></div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_tsaqx.html" target="_blank">提升安全性XP必禁的十大服务</a></span></td>
            <td><div class="STYLE9" align="center"><span class="STYLE23">□</span></div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_wordsyjq.html" target="_blank">10个Word实用技巧</a></span></td>
          </tr>
          <tr>
            <td height="18"><div align="center"><span class="STYLE11">□</span></div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/xxyjl/xxyjl_windowsxtgz.html" target="_blank">Windows系统故障快速解决技巧大集合</a></span></td>
            <td><div class="STYLE9" align="center"><span class="STYLE23">□</span></div></td>
            <td><a href="#" target="_blank" class="STYLE9">更多...&gt;&gt;</a></td>
          </tr>
        </tbody></table></td>
		<td colspan="3" rowspan="4"><table height="204" border="0" cellpadding="0" cellspacing="3" width="100%">
          <tbody><tr>
            <td height="30">&nbsp;</td>
            <td><a href="http://www.sinotruk.com/" target="_blank"><img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/cnhtc_logo.gif" alt="中国重汽（香港）有限公司" height="30" border="1" width="138"></a></td>
            <td><span class="STYLE50"><span class="STYLE43">&nbsp;</span><span class="STYLE9">中国重汽</span></span></td>
          </tr>
          <tr>
            <td height="32" width="11%">&nbsp;</td>
            <td width="57%"><a href="http://www.baidu.com/" target="_blank"><img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/logo-yy.gif" alt="百度搜索" height="30" border="1" width="138"></a></td>
            <td width="32%"><span class="STYLE43"> &nbsp;百度</span></td>
          </tr>
          <tr>
            <td height="29">&nbsp;</td>
            <td><a href="http://www.google.cn/" target="_blank"><img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/logo_cn.gif" alt="Google搜索" height="30" border="1" width="138"></a></td>
            <td><span class="STYLE43">&nbsp;谷歌</span></td>
          </tr>
          <tr>
            <td height="32">&nbsp;</td>
            <td><a href="http://www.gcerp.cn/" target="_blank"><img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/toplogo.gif" alt="大中华ERP网" height="30" border="1" width="138"></a></td>
            <td><span class="STYLE43">&nbsp;大中华ERP</span></td>
          </tr>
          <tr>
            <td height="32">&nbsp;</td>
            <td><a href="http://www.mydrivers.com/" target="_blank"><img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/mydrivers.gif" alt="驱动之家" height="30" border="1" width="138"></a></td>
            <td><span class="STYLE43">&nbsp;驱动之家</span></td>
          </tr>
          <tr>
            <td height="32">&nbsp;</td>
            <td><a href="http://www.ccw.com.cn/" target="_blank"><img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/index_r3_c2.jpg" alt="计算机世界网" height="30" border="1" width="138"></a></td>
            <td><span class="STYLE43">&nbsp;计世网</span></td>
          </tr>
        </tbody></table></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="87" width="1"></td>
	</tr>
	<tr>
		<td colspan="3">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_30.jpg" alt="" height="58" width="264"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="58" width="1"></td>
	</tr>
	<tr>
		<td colspan="3" rowspan="6" background="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_31.jpg"><table height="168" border="0" cellpadding="0" cellspacing="0" width="100%">

        

          <tbody><tr>
            <td width="10%">&nbsp;</td>
            <td width="9%"><div class="STYLE13" align="center">◆</div></td>
            <td width="81%"><a href="http://www.cnhtcerp.com/soft/new2007/xs_fwz.msi" target="_blank" class="STYLE9">卡车服务备件一线通服务站</a></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><div class="STYLE13" align="center">◆</div></td>
            <td><a href="#" target="_blank" class="STYLE9">济南商用车服务一线通服务站</a></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><div class="STYLE13" align="center">◆</div></td>
            <td><a href="#" target="_blank" class="STYLE9">济南特种车服务一线通服务站</a></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><div class="STYLE13" align="center">◆</div></td>
            <td><a href="#" target="_blank" class="STYLE9">济宁商用车公司服务管理系统</a></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><div class="STYLE13" align="center">◆</div></td>
            <td><span class="STYLE9"><a href="http://www.cnhtcerp.com/down.html" target="_blank">服务备件一线通下载网</a></span></td>
          </tr>
	  
          </tbody></table></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="46" width="1"></td>
	</tr>
	<tr>
		<td colspan="3" rowspan="2">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_32.jpg" alt="" height="50" width="420"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="23" width="1"></td>
	</tr>
	<tr>
		<td colspan="3" rowspan="3">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_33.jpg" alt="" height="50" width="244"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="27" width="1"></td>
	</tr>
	<tr>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_34.jpg" alt="" height="2" width="1"></td>
		<td colspan="2" rowspan="4"><table height="93" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tbody><tr>
            <td height="19" width="6%"><span class="STYLE11">○</span></td>
            <td width="94%"><p class="STYLE9" align="left"><a href="http://www.cnhtcerp.com/qyxxh/qyxxh_ITglzx.html" target="_blank">IT管理咨询如何能服务于制造业信息化</a></p></td>
          </tr>
          <tr>
            <td><span class="STYLE11">○</span></td>
            <td><div align="left"><span class="STYLE9"><a href="http://www.cnhtcerp.com/qyxxh/qyxxh_wlwb.html" target="_blank">把握企业信息化命脉—浅析企业基础网络的外包趋势</a></span></div></td>
          </tr>
          <tr>
            <td><span class="STYLE11">○</span></td>
            <td><div align="left"><span class="STYLE19"><a href="http://www.cnhtcerp.com/qyxxh/qyxxh_xxzzy.html" target="_blank">信息化：新型制造业生存发展的灵魂</a></span></div></td>
          </tr>
          <tr>
            <td><span class="STYLE11">○</span></td>
            <td><span class="STYLE19"><a href="http://www.cnhtcerp.com/qyxxh/qyxxh_qtzzyxxh.html" target="_blank">浅谈制造业信息化</a></span></td>
          </tr>
          <tr>
            <td><span class="STYLE11">○</span></td>
            <td><div align="left"><a href="http://www.cnhtcerp.com/qyxxh/qyxxh_xxgh.html" target="_blank" class="STYLE9">企业信息化规划由谁来做？</a> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="#" target="_blank" class="STYLE9">更多...&gt;&gt;</a></div></td>
          </tr>
        </tbody></table></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="2" width="1"></td>
	</tr>
	<tr>
		<td rowspan="4">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_36.jpg" alt="" height="211" width="1"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="21" width="1"></td>
	</tr>
	<tr>
		<td colspan="2" rowspan="2"><table height="66" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tbody><tr>
            <td><span class="STYLE19">中国重汽ERP论坛为大家提供了一个交流信息</span></td>
          </tr>
          <tr>
            <td><span class="STYLE19">化相关知识、理论、以及探讨各种应用中所</span></td>
          </tr>
          <tr>
            <td><span class="STYLE45"><span class="STYLE21">遇问题的平台。</span><a href="http://www.cnhtcerp.com/bbs" target="_blank">点击进入...&gt;&gt;</a></span></td>
          </tr>
        </tbody></table></td>
		<td rowspan="3">
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_38.jpg" alt="" height="190" width="1"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="76" width="1"></td>
	</tr>
	<tr>
		<td colspan="3" rowspan="2" background="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_39.jpg"><table height="102" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tbody><tr>
            <td height="41" width="10%">&nbsp;</td>
            <td width="82%"><span class="STYLE22"><a href="http://www.cnhtcerp.com/down.html" target="_blank">服务备件一线通下载网</a></span></td>
            <td width="4%">&nbsp;</td>
            <td width="4%">&nbsp;</td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td height="48">&nbsp;</td>
            <td><span class="STYLE22">WWW.CNHTCERP.COM</span></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
        </tbody></table></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="8" width="1"></td>
	</tr>
	<tr>
		<td colspan="4" background="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/erp_40.jpg"><table height="81" border="0" cellpadding="0" cellspacing="0" width="100%">
          <tbody><tr>
            <td height="53"><div align="center"><span class="STYLE9">| <a href="#" target="_blank">关于我们</a> | <a href="#" target="_blank">企业邮箱</a> | <a href="#" target="_blank">联系我们</a> | <a href="#" target="_blank">技术支持</a> | <a href="#" target="_blank">行业动态</a> | <a href="#" target="_blank">下载专区</a> | <a href="http://www.cnhtcerp.com/bbs" target="_blank">进入论坛</a> | <a href="#" target="_blank">友情链接</a> | <a href="#" target="_blank">企业信息化</a> | </span></div></td>
          </tr>
          <tr>
            <td height="13">&nbsp;</td>
          </tr>
          <tr>
            <td><div align="center"><span class="STYLE15">Copyright &#169; 2008</span><span class="STYLE17"> 中国重汽（香港）有限公司 技术发展部 保留所有权利</span></div></td>
          </tr>
        </tbody></table></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="106" width="1"></td>
	</tr>
	<tr>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="1"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="105"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="158"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="1"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="43"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="1"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="142"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="277"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="1"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="242"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="1"></td>
		<td>
			<img src="%E4%B8%AD%E5%9B%BD%E9%87%8D%E6%B1%BDERP%E4%BF%A1%E6%81%AF%E7%BD%91_files/a.gif" alt="" height="1" width="28"></td>
		<td></td>
	</tr>
</tbody></table>
<!-- End ImageReady Slices -->
</form>

</body></html>