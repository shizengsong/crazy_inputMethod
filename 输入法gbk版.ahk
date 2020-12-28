﻿;疯狂输入法,哈哈哈.....
;快捷键说明:
;Lshift:切换中英文输入 f4:切换单字模式 
;翻页按钮: 逗号句号,-号=号 
;中文状态下切换中英文标点:ctrl+句号
;翻页键直接进入选字状态，空格选中第一个词并进入选字状态，其他标点符号也可以进入选字状态
;非单字模式下,在输入三个字符的情况下,按 逗号或句号或tab键 可以盲打出字(例如dee加句号，将打出“的”字，ler加句号，会打出“了”字)
;选字状态中backspace删除已确认文字,delete删除未确认拼音
#singleinstance force
#NoEnv
SetTitleMatchMode 2
SetWinDelay, 0
Sendmode input
CoordMode,caret,screen
menu,tray,icon,%A_ScriptDir%\图标\图标文件.icl,1			;拖盘图标,来自影子输入法,觉得字体不错,借用一下

使用英文标点的程序列表:="emeditor.exe,scite.exe,notepad.exe"		;请把默认英文标点的程序写到这里
									;列表内的程序,将默认英文标点,切换中文标点变为临时切换
启用英文标点:=0								;是否启用全局英文标点,1为启用,0为禁用.切换快捷键为ctrl+句号

表情:={"haha":"O(∩_∩)O","hehe":"^_^ ","oe":"-_-#"			;表情功能,请自行添加(自己定义字符,原本采用的是智能abc双拼,请自行修改)
	,"hj":"-_-!","of":":-) ","hkde":"-)","yn":"$_$","xixi":"^_^"}		

;双拼编码, 设置文件在双拼编码文件夹下,若没有则到双拼编码文件夹中去建(文件后缀为txt,非ini,注意)
;可用的有：智能ABC,微软拼音,拼音加加,紫光拼音,搜狗拼音,自然码,小鹤双拼,请自行修改
双拼编码:="智能ABC"
#include 双拼编码映射.ahk

单字模式:=0								;快捷键为f4
输入法开关:=1								;初始打开中文
;自动进入选字模式时间:=600						;两个字符时，自动进入选字的时间，单位为毫秒，越小越灵敏，小心使用，注释掉则不自动进入选字

字体 := "华文细黑"							;字体调整过后，排版可能会有些问题,请在下面调分割符和窗口高度宽度
									;华文细黑比较好看，建议使用

if(字体=="华文细黑"){
	初始高度:=50, 初始宽度:=520,单行高度:=21,字体大小:=14,文字宽度:=9
}else if(字体=="微软雅黑"){
	初始高度:=54, 初始宽度:=430,单行高度:=23,字体大小:=13,文字宽度:=15
}else{
	初始高度:=45, 初始宽度:=480,单行高度:=18,字体大小:=13,文字宽度:=17
}
gbk单字表 :=生成音词表(A_ScriptDir . "\词典\gbk全字典.txt")		;疯狂输入法特色，包含gbk所有汉字,按计算机编码排序(即gbk2,gbk3,gbk4的顺序放字)
常用拼音表 :=生成音词表(A_ScriptDir . "\词典\小词典.txt")		;一个比较小的词典，载入快，缺点就是比较小，但是还算够用，因为我们还有gbk
单字模式:=0								;每次只打一个字的单字模式，不太常用。f4:切换单字模式 
字母选字键:="qwertyuiopasdfghjklzxcvbnm"				;所有的字母选字键
数字选字键:="1234567890"						;所有的数字选字键，要减少选字项，只需要改这个
数字选字键组:=strSplit(数字选字键)
字母选字键组:=strSplit(字母选字键)
中文标点 :={",":"，"  ,  ".":"。"  , ";":"；"  ,  "/":"、" , "+1":"！" , "+2":"@" 	;此处包含除了引号之外的中文标点
		, "+3":"{#}" ,"+4":"￥" , "+5":"%" , "+6":"……" , "+7":"&" 
		, "+8":"*" , "+9":"（" , "+0":"）" ,  "+,":"《" , "+.":"》" 
		, "+/":"？" , "[":"【" , "]":"】" , "+;":"：","+-":"—" }
英文括号按键:={"+9":"(){left}", "+,":"<>{left}",  "[":"[]{left}"	;简化括号的发送问题，发送对称括号
		,  "+[":"{{}{}}{left}", "+'":"""""{left}"}
引号已发送:=1								;解决双引号问题
已确认文字:= 插入字符:= 构造词记忆:=用户词典字符:= 待转化字符 := 句末标点 :=gb词典字串 :=常用词典字串:=""
用户词典表:={}, 字母键到字表 :={}, 数字键到词表 :={}
上翻页键 := "-[,", 下翻页键 := "=]."
翻页数:=选字状态:=0

#include 获取光标位置.ahk						;调用的函数文件放在这一块

#if			
$f4::									;切换单字模式的按键,自行修改
if(输入法开关){
	if(单字模式:=!单字模式){
		tooltip,单字模式,%A_caretx% ,% A_carety-25
	}else	tooltip,词语模式,%A_caretx% ,% A_carety-25
	settimer,关闭tooltip,-1000
}else send,{f4}
return

^.::									;ctrl+句号切换中英文标点
winget,进程名,ProcessName,A
tooltip,% 进程名
if(进程名&&instr(使用英文标点的程序列表,进程名)){
	临时启用中文标点:=1
	settimer,倒计时进入英文标点,-5000		;临时中文标点的时间,5秒,请自行修改
	tooltip,临时启用中文标点_5秒,%A_caretx% ,% A_carety-25
}else {		;英文标点切中文标点
	if(启用英文标点:=!启用英文标点 ){
		tooltip,英文标点,%A_caretx% ,% A_carety-25
	}else tooltip,中文标点,%A_caretx% ,% A_carety-25
}
	settimer,关闭tooltip,-1000
return

倒计时进入英文标点:
	临时启用中文标点:=0
	tooltip,恢复英文标点,%A_caretx% ,% A_carety-25
	settimer,关闭tooltip,-1000
return

^space::gosub,切换输入法
~Lshift::
keywait,shift,T1							;用此句修正和其他的按键的冲突
if(A_thishotkey!="~Lshift")
	return
切换输入法:
光标位置:=获取光标位置()
if (输入法开关:=!输入法开关){						;切换中英文
	mousegetpos,x,y
	tooltip, 中文输入,% x ,% y-25
	menu,tray,icon,%A_ScriptDir%\图标\图标文件.icl,1
	Hotkey, IfWinActive
	for 序号,值 in 字母选字键组{
		hotkey,% "$" 值,on
	}
	for 序号,值 in 数字选字键组{
		hotkey,% "$" 值,on
	}
	hotkey,^.,on
	hotkey,space,off
}else{
	send,% 已确认文字 . 插入字符 . 待转化字符 . 句末标点
	输入置空()
	mousegetpos,x,y
	tooltip,　EN　,% x ,% y-25
	Hotkey, IfWinActive
	for 序号,值 in 字母选字键组{
		hotkey,% "$" 值,off
	}	
	for 序号,值 in 数字选字键组{
		hotkey,% "$" 值,off
	}
	hotkey,^.,off
	hotkey,space,off
	menu,tray,icon,%A_ScriptDir%\图标\图标文件.icl,2		;清空已记录输入
}
setTimer,关闭tooltip,-1000
return

关闭tooltip:
tooltip
return

#Include 注册输入键.ahk

if(instr(A_thisHotKey,"$")){
	按键 :=subStr(A_thisHotKey,2)					;去除热键$符号,获取热键
}else 按键:=A_thisHotKey
if(getkeystate("capslock","t")){
	原义发送(按键)
}else if(输入法开关 && 获取光标位置().类型!="mouse"){
	中文输入(按键)
}else 原义发送(按键)
return

超时进入选字状态:
	选字状态:=1
	gosub,判断发送上屏
return

原义发送(按键){
	global
	if (按键=="backspace"){
		send,{%按键%}
		if(构造词记忆){						
			用户词典表.delete(构造词记忆)					
			用户词典表.delete(substr(构造词记忆,1,-1))
		}
	}else if (按键=="space"||按键=="enter" ||按键=="esc"||按键=="tab"||按键=="delete" ){
		send,{%按键%}						;特殊按键发送要用 {%按键%}，普通按键发送要用% 按键
	}else if(英文括号按键["" . 按键]){				;发送对称括号，方便打括号
		send,% 英文括号按键["" . 按键]
	}else if(getkeystate("capslock","t")){
		StringUpper,按键,按键
		send,% 按键
	}else send,% 按键
}

中文输入(按键){								;输入法核心步骤
	local 选中字,选中词
	字符数:=strLen(待转化字符)
	settimer,超时进入选字状态,off
	if(!已确认文字 && 字符数>=4)					;记录用户构造词,只具有短期记忆
		用户词典字符:=待转化字符
	if(单字模式 && 字符数==1 && instr(字母选字键,按键) ){
		待转化字符 .= 按键, 产生字串(待转化字符), 选字状态:=1
		gosub,判断发送上屏
		return
	}
	if (字符数==0 && !instr(字母选字键,按键) && 按键!="+'"){		;处理非打字状态下的特殊按键，包括符号，排除引号
		if(!启用英文标点 && 中文标点["" . 按键]){		;强制转换按键为字符类型，只有这个古怪的语法起作用-_-||……,
			winget,进程名,processname,A
			if(进程名 && instr(使用英文标点的程序列表,进程名)){
				if(临时启用中文标点){
					send,% 中文标点["" . 按键]	;临时发送中文标点
				}else  	原义发送(按键)
			}else send,% 中文标点["" . 按键]			;正常发送中文标点
		}else 原义发送(按键)
		return
	}else if(instr(数字选字键,按键) ||按键=="space"||按键=="tab"||中文标点["" . 按键]){	;数字及空格等选字键
		if(中文标点["" . 按键]){
			if(instr(下翻页键,按键)||instr(上翻页键,按键) ){			;若标点为句号或逗号，则进行翻页
				if (选字状态) {			
					if(instr(下翻页键,按键) && (数字键到词表[1]||字母键到字表["q"])){
						翻页数+=1
					}else if(instr(上翻页键,按键) && 翻页数!=0){
						翻页数-=1
					}
				}else if(!已确认文字 && strlen(待转化字符)==3){	;逗号句号盲打出字
						gosub,盲打出字
						return
				}
			}else 句末标点 := 中文标点["" . 按键]			;非翻页标点,则进入选字
			选字状态:=1
			gosub,判断发送上屏
			return
		}
		选字状态:=1
		if(按键=="tab"){						;在三个字符的情况下,盲打出字
				if(!已确认文字 && strlen(待转化字符)==3){
					gosub,盲打出字
					return
				}
		}else if(按键=="space") {
				if(!选中词:=用户自造词)			;存在用户自造词情况下，使用用户自造词 
					选中词:=数字键到词表[1]
		}else 选中词:=数字键到词表[按键]
		if(选中词){
			已确认文字.=选中词
			翻页数:=0
			if(strlen(插入字符)>0){
				多余字符数:=strlen(选中词)*2 - strlen(插入字符)
				if(多余字符数>0){
					插入字符:=""
					待转化字符:=substr(待转化字符,多余字符数+1)
				}else 插入字符:=substr(插入字符,strlen(选中词)*2+1)
				if(!插入字符){
					插入状态:=0
					产生字串(待转化字符)
				}else 产生字串(插入字符)
			}else {
				待转化字符:=substr(待转化字符,strlen(选中词)*2+1)
				产生字串(待转化字符)
			}
		}
		gosub,判断发送上屏
		return
	}else if(instr(下翻页键,按键)||instr(上翻页键,按键)){		;翻页	
		if (instr(下翻页键,按键) && (数字键到词表[1]||字母键到字表["q"])){
			翻页数+=1
		}else if(instr(上翻页键,按键) && 翻页数!=0){		;上翻页
			翻页数-=1
		}else return
		选字状态:=1, 产生候选()
	}else if(按键=="+'" && 字符数==0){				;处理引号
		if(启用英文标点){
			原义发送(按键)
		}else{
			winget,进程名,processname,A
			if(进程名 && instr(使用英文标点的程序列表,进程名)){
				if(临时启用中文标点){
					if(引号已发送:=!引号已发送){
						send,”
					}else send,“
				}else 原义发送(按键)
			}else if(引号已发送:=!引号已发送){
				send,”
			}else send,“
		}
		return
	}else if(按键=="esc"){						;做取消操作
		输入置空()
	}else if(按键=="enter"){						;直接按键上屏
		send,% 已确认文字 . 插入字符 . 待转化字符 . 句末标点
		输入置空()
	}else if(按键=="backspace" ||按键=="delete"){			;做删除操作
		gosub,删除操作
	}else if(!选字状态){						;接下来是字母选字键区
		if(插入状态){
			插入字符.=按键, 产生字串(插入字符 . 待转化字符)
		}else	待转化字符 .= 按键, 产生字串(待转化字符)
		产生候选()
		if((strlen(待转化字符)==2||strlen(插入字符)==2) && !单字模式 && 自动进入选字模式时间)
			setTimer,超时进入选字状态,-%自动进入选字模式时间%
	}else if(选字状态){						;输入法的四个状态：输入状态，选字状态，插入中输入状态，插入中选字状态
		选中字:=字母键到字表[按键]				;好晕@_@
		if(选中字){
			已确认文字.=选中字, 翻页数:=0
			if(strlen(插入字符)>0){
				if(strlen(插入字符)==1){
					插入字符:=""
					待转化字符:=substr(待转化字符,2)
				}else 插入字符:=substr(插入字符,3)
				插入字符:=substr(插入字符,3)
				if(!插入字符){
					插入状态:=0, 产生字串(待转化字符)		;插入选字状态结束，继续转化剩余字串
				}else 产生字串(插入字符 . 待转化字符)
			}else{
				待转化字符:=substr(待转化字符,3), 产生字串(待转化字符)
			}
			gosub,判断发送上屏
		}else if(!插入字符){
			选字状态:=0, 待转化字符 .= 按键, 词典字串:=产生字串(待转化字符)
			产生候选()
		}
	}
	return

盲打出字:
	产生字串(substr(待转化字符,1,2)), gb词典词组:=strSplit(gb词典字串,","), 位置:=instr(字母选字键,substr(待转化字符,3,1))
	send,% gb词典词组[位置]
	输入置空()
return

删除操作:
	if(插入状态){	
		用户词典字符:=""
		if(按键=="backspace"){
			if(strlen(插入字符)>0){				;插入状态中删除
				插入字符 := subStr(插入字符,1,-1)
				if (strlen(插入字符)>0){
					产生字串(插入字符), 产生候选()
					return
				}
			}else 已确认文字:=substr(已确认文字,1,-1)
		}else if(按键=="delete")
			待转化字符 := subStr(待转化字符,2)		;删除剩余字符的句首字母	
	}else if (strlen(已确认文字)>0){
		if(按键=="backspace"){					;已有确认文字,开始删除 
			if(strlen(已确认文字)<=2){			;已确认文字较短情况下
				已确认文字:="", 待转化字符:=用户词典字符
			}else if(!数字键到词表[1]){			;拼不出字的情况下
				if(strlen(待转化字符)!=1){
					待转化字符:=substr(待转化字符,1,1)
				}else 待转化字符:=""
			}else 已确认文字:=substr(已确认文字,1,-1), 插入状态:=1
		}else if(按键=="delete"){				;delete键删除	
			待转化字符:=subStr(待转化字符,2)
			插入状态:=1
		}
		用户词典字符 :="", 选字状态:=0
	}else if(按键=="backspace"){					;转化前的删除	
			if(!数字键到词表[1]){
				if(strlen(待转化字符)!=1){
					待转化字符:=substr(待转化字符,1,1)
				}else 待转化字符:=""
			}else 待转化字符:=substr(待转化字符,1,-1)
			选字状态:=0
	}
	if (!待转化字符){
		send,% 已确认文字 . 句末标点
		输入置空()
		return
	}
	产生字串(待转化字符), 产生候选()
	return
}

判断发送上屏:
	if(!待转化字符){
		if(用户词典字符 && strlen(用户词典字符)>=4 && mod(strlen(用户词典字符),2)==0){		;保存用户构造词
			产生字串(用户词典字符),	词:=strsplit(常用词典字串,",")[1]
			if(用户词典表[用户词典字符] && 用户词典表[用户词典字符]!=已确认文字){
				if(已确认文字==词){
					用户词典表.delete(用户词典字符)					;用户构造词保存两份,一份为拼音->词语
					if(strlen(用户词典字符)>=6)					;另一份为sub(拼音,1,-1)->词语,少打一个字母,也可出字
						用户词典表.delete(substr(用户词典字符,1,-1))		;删除时也要同时删除
					构造词记忆:=""
				}else 构造词记忆:=用户词典字符
			}else if(词&&词!=已确认文字){
				构造词记忆:=用户词典字符
			}else 构造词记忆:=""
			if(构造词记忆){
				用户词典表[构造词记忆]:=已确认文字
				if(strlen(构造词记忆)>=6)
					用户词典表[substr(构造词记忆,1,-1)]:=已确认文字
				settimer,保存构造词,-2000
			}
		}
		send,% 已确认文字 . 句末标点
		输入置空()
	}else 产生候选()
return

保存构造词:								;两秒内按删除,会删除用户构造词
	构造词记忆:=""
return

输入置空(){
	global
	gui,destroy
	gui,疯狂输入法选字窗:destroy
	用户词典字符:=用户自造词:=gb词典字串 :=已确认文字:=插入字符 := 待转化字符 := 句末标点 :=""
	插入状态:=选字状态:=翻页数:=0
	字母键到字表 :={}
}

产生字串(原字符){
	global 常用拼音表,gbk单字表,用户词典表,常用词典字串,gb词典字串,用户自造词,双拼编码,表情
	字符:=原字符,用户自造词:=""
	if(表情[原字符]){			;
		用户自造词:="{raw}"  .  表情[原字符]
	}else while(strlen(字符)>=4){
		if(mod(strlen(字符),2)==1){
			if(用户自造词:=用户词典表[字符]){
				break
			}else 字符:=substr(字符,1,-1)
		}else{	;mod(strlen(字符),2)==0		
			 if(用户自造词:=用户词典表[字符]){
			 	break
			 }else 字符:=substr(字符,1,-2)
		}
	}
	字符:=双拼转换(原字符, 双拼编码),常用词典字串:=""
	gb词典字串 := gbk单字表[substr(字符,1,2)]
	while (strlen(字符)>=1){
		if(mod(strlen(字符),2)==0){		
			新字串:=常用拼音表[字符]
			if(新字串 && 常用词典字串)
				常用词典字串 .= ","
			常用词典字串 .= 新字串, 字符:=substr(字符,1,-2)
		}else {	;mod(strlen(字符),2)==1	
			新字串:=常用拼音表[字符]
			if(新字串&&常用词典字串)
				常用词典字串 .= ","
			常用词典字串 .= 新字串,字符:=substr(字符,1,-1)
		}
	}
}

生成音词表(词典路径){							;词典每行格式 拼音\t词,词 
	fileread,已读文件,%词典路径%
	待返回音词表:={}						;哈希数组需要初始化!!!!!!!! 
	loop,parse,已读文件,`n, `r 
	{
		当前行 :=A_LoopField
		loop,parse,当前行,%a_tab%
		{
				if(当前行=="")
					continue
				if(A_index==1)
					拼音 := a_loopfield
				if (A_index==2)
					待返回音词表[拼音] :=a_loopfield
		}
		if(mod(a_index,500) ==0){
			行数:=A_index
			tooltip,正在载入词典%行数%行.......
		}
	}
	setTimer,关闭tooltip,-100
	已读文件:=""
	return 待返回音词表
}

产生候选(){
	local 显示输入字串,显示候选字串,显示用户自造词,常用词典词组
	显示输入字串 .= 已确认文字 . 插入字符
	if(插入状态){
		显示输入字串 .="|  " . 待转化字符 . 句末标点 . ""
	}else 	显示输入字串 .= 待转化字符 . "_"  . 句末标点 . ""
	if(显示用户自造词:=用户自造词){
		StringReplace,显示用户自造词,显示用户自造词,% "{raw}",%  "",all		;
		显示输入字串 .= "`n◉" . 显示用户自造词 . " "
	}else 显示输入字串 .="`n"
	常用词典词组 :=strSplit(常用词典字串,","), gb词典词组:=strSplit(gb词典字串,",")
	较常用字:=""
	for 序号,值 in 常用词典词组{
		if(序号>15){
			break
		}else 较常用字.=值
	}
	for 序号,值 in 数字选字键组{
		字:=数字键到词表[值] :=常用词典词组[序号+翻页数*strlen(数字选字键)]	;数字做键,词做值
		显示输入字串 .= 值 . "." 
		if (!字){
			显示输入字串 .= "　"
		}else 显示输入字串 .= 字 
		if (序号==10){
			显示输入字串 .= ""
		}else 显示输入字串 .=  " "
	}
	if(!选字状态){
		gosub,显示候选框
		return
	}
	for 序号,值 in 字母选字键组
	{
		字母键到字表[值]:=gb词典词组[序号+翻页数*strlen(字母选字键)]		;字母做键,字做值
		字 :=字母键到字表[值]
		if(字 && instr(较常用字,字)){
			显示候选字串 .= "♦" . 值 
		}else 显示候选字串 .= 值 . "."
		if (!字){
			显示候选字串 .= "　"
		}else 显示候选字串 .= 字 
		if (序号==10){
			显示候选字串 .= "`n　" 
		}else if (序号==19){
			显示候选字串 .= "　　`n" 
		} if (序号==26){
			显示候选字串 .= "　　" 
		}else 显示候选字串 .=  " "
	}
	gosub,显示候选框
	return

显示候选框:
	光标位置 :=获取光标位置()
	if(!winexist("疯狂输入法选字窗")){				;初始化输入法窗口
;		gui,destroy						;防止出现BUG,窗口还在
		if(光标位置.x<A_ScreenWidth -初始宽度){
			窗口x :=光标位置.x
		}else	窗口x :=A_ScreenWidth -初始宽度
		if(光标位置.y<A_ScreenHeight-初始高度){
			窗口y :=光标位置.y
		}else	窗口y :=A_ScreenHeight -初始高度
		gui, font,% "s" 字体大小, %字体%
		Gui, Margin ,10,0
		Gui, +AlwaysOnTop +Disabled -SysMenu +Owner -Caption +Border +Theme
		Gui, Add, Text,% "w" 初始宽度 " y2" " h"	单行高度*2, %显示输入字串%
		Gui, Add, pic, % "w" 初始宽度-40 " h1" " x15",%A_ScriptDir%\图标\分割线.bmp
		Gui, Add, Text,% "w" 初始宽度 " center", %显示候选字串%
		Guicontrol,hide,static2
		Gui, Show,x%窗口x% y%窗口y% h%初始高度% w%初始宽度%  NoActivate, 疯狂输入法选字窗
	}else{
		winget,活动窗口id,ID,A	
		if(绑定窗口id!=活动窗口id){
			Gui, 疯狂输入法选字窗:+owner%活动窗口id%		;绑定输入法的窗口到活动窗口,不绑定好像容易出错	
			绑定窗口id :=活动窗口id	
		}
		字符数:=0
		loop % strlen(数字选字键){				;窗口宽度计算
			字符数+=strlen(数字键到词表[A_index-1])
		}
		if(字符数+strlen(用户自造词)>11){
			宽度:=(字符数+3*strlen(数字选字键)+strlen(用户自造词)-10*4)*文字宽度+初始宽度
		}else 宽度:=初始宽度
		窗口高度:=初始高度
		if(选字状态){
			候选窗高度:=单行高度*3
			Guicontrol,show,static2
		}else {
			候选窗高度:=0
			Guicontrol,hide,static2
		}
		窗口高度+=候选窗高度
		guicontrol,move,static1,% "w" 宽度
		guicontrol,move,static3,% "w" 宽度 "h" 候选窗高度
		GuiControl, , static1 ,%显示输入字串%
		GuiControl, , static3 ,%显示候选字串%
		guicontrol,move,static2,% "w" 宽度-40 " h1"
		WinMove, 疯狂输入法选字窗, , , ,%宽度%,% 窗口高度
	}
return
}

^esc::exitapp								;ctrl+esc强制退出输入法

#ifwinactive 输入法gbk版.ahk						;在脚本保存后重启脚本
~^s::reload 		