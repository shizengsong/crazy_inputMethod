 ;疯狂输入法,哈哈哈.....
#singleinstance force
SetTitleMatchMode 2
DetectHiddenWindows, On
SetWinDelay, 0

CoordMode,caret,screen
menu,tray,icon,.\图标文件.icl,1

显示字体 := "华文细黑"
输入法开关:=1								;初始打开中文
中文下启用英文标点:=1
gbk单字表 :=生成音词表(".\gbk全字典.txt")				;疯狂输入法特色,包含gbk所有汉字,按计算机编码排序(即gbk2,gbk3,gbk4的顺序放字)
词频拼音表 :=生成音词表(".\正常词典.txt")					;拼音词典,来自影子输入法的

字母选字键:=strsplit("qwertyuiopasdfghjklzxcvbnm")			;所有的选字键,勿改
数字选字键:=strsplit("1234567890")					;所有的选字键,亦勿改
中文标点 :={",":"，"  ,  ".":"。"  , ";":"；"  ,  "/":"、" , "+1":"！" , "+2":"@" 
		, "+3":"#" ,"+4":"￥" , "+5":"%" , "+6":"……" , "+7":"&" 
		, "+8":"*" , "+9":"（" , "+0":"）" ,  "+,":"《" , "+.":"》" 
		, "+/":"？" , "[":"【" , "]":"】" , "+;":"：" }			;此处包含除了引号之外的中文标点
引号已发送:=1								;解决双引号问题
已确认文字:= 待转化字符 :=gb词典字串 :=常用词典字串:=""
字母键到字表 :={}
数字键到字表 :={}
上翻页键 := "-[,"
下翻页键 := "=]."
翻页数:=0
需重建窗口:=1
tip条序号:=1

#include 获取光标位置.ahk						;调用的函数文件放在这一块

^.::中文下启用英文标点:=!中文下启用英文标点

~Lshift::
keywait,shift,t0.15							;修正和其他的按键冲突
if errorlevel
	return
输入法开关:=!输入法开关
获取光标位置()
if (输入法开关){								;输入法开关提示
	tooltip, 中,光标位置.x+10,光标位置.y+20
	menu,tray,icon,.\图标文件.icl,1
}else{
	if(strlen(待转化字符)>1){						;改进shift键,使切换时字符上屏
		send,%待转化字符%
	}
	输入置空()
	tooltip,EN,光标位置.x+10,光标位置.y+20
	menu,tray,icon,.\图标文件.icl,2					;清空已记录输入
}
tip条序号:=1
setTimer,移除tip条,-1000
return

移除tip条:
tooltip,,,,%tip条序号%
return

#Include 注册输入键.ahk
按键 :=subStr(A_thisHotKey,2)						;去除热键$符号,获取热键
if(输入法开关){
	中文输入(按键)
}else if (按键=="space"||按键=="backspace"||按键=="enter" ||按键=="esc"){
	send,{%按键%}
}else send,% 按键							;有的按键发送要用 % 按键  ,有的要用 {%按键%}	没有规律……
return

;输入法核心步骤
中文输入(按键){
	global
	字符数:=strLen(待转化字符)
	if (instr("1234567890",按键)){					;数字选字键，放在标点
		if(字符数==0){
			send,% 按键
			return
		}else{
			if(选中字:=数字键到字表[按键]){
				send,%选中字%
				输入置空()
			}
			return
		}
	}else if(instr(下翻页键,按键)){					;下翻页，先处理翻页键，不然跟标点符号有冲突
		;msgbox,% 下翻页键
		if(字符数==0){
			if(!中文下启用英文标点 && 中文标点[按键]){
				send,% 中文标点[按键]
			}else send,% 按键
		}else{
			翻页数+=1
			显示候选()
		}
		return
	}else if(instr(上翻页键,按键)){					;上翻页
		if(字符数==0){
			if(!中文下启用英文标点 && 中文标点[按键]){
				send,% 中文标点[按键]
			}else send,% 按键
		}else if(翻页数!=0){
			翻页数-=1
			显示候选()
		}else return
		return
	}else if (instr(",./;+1+2+3+4+5+6+7+8+9+0+,+.+/+;" ,按键)){	;发送中文标点符号《》【 】？
		if(字符数==0){ 
			if(中文下启用英文标点){
				send,% 按键
			}else send,% 中文标点["" . 按键]			;强制转换按键为字符类型，只有这个古怪的语法起作用-_-||……,
			return						;官方说明是autohotkey对象键值不支持数字转化 为字符型
		}else if(instr(",.;/",按键)){
;			if(字母键到字表[按键]){				;废除作为选字键
;				send,% 字母键到字表[按键]
;				输入置空()
;			}
			return	;else do nothing
		}
	}else if(按键=="+'"){						;处理引号
		if(字符数==0){
			if(中文下启用英文标点){
				send,% 按键
			}else if(引号已发送:=!引号已发送){		;强制转换按键为字符类型，只有这个古怪的语法起作用-_-||……{
				send,”
			}else send,“
			return
		}else return
	}else if(按键=="backspace"){					;做删除操作
		gosub,删除操作
	}else if(按键=="esc"){						;做取消操作
		输入置空()
		return
	}else if(按键=="enter"){						;直接按键上屏
		if(strLen(待转化字符)==0){
			send,{%按键%}
 		}else{
			send,%待转化字符%
			输入置空()
		}
		return
	}else if(按键=="space"){						;空格键处理
		if(strLen(待转化字符)==0){
			send,{%按键%}
		}else if(选中字:=数字键到字表[1]){			;默认空格键为第一个字上屏
			send,%选中字%
			输入置空()
		}
		return
	}else 待转化字符 .=按键
	字符数:=strLen(待转化字符)					;重新计算字符数
	if (字符数==0){							;有可能进行了删除操作,因此还要检测是否置空
		输入置空()
	}else if(字符数==1){
		常用词典字串 := 词频拼音表[待转化字符]
		gb词典字串 :=""
		显示候选()
	}else if (字符数==2){
		常用词典字串 := 词频拼音表[待转化字符]			;后面加入其他词典再改进
		gb词典字串 := gbk单字表[待转化字符]
		显示候选()
	}else if(字符数==3){		
		if(gb词典字串=="" || 字母键到字表[按键]==""){
			send,% 待转化字符
		}else{
			选中字 :=字母键到字表[按键]
			send,%选中字%
		}
		输入置空()
	}
	return
删除操作:
	if(strLen(待转化字符)==0){
		send,{%按键%}
	}else if(strLen(待转化字符)>=1){
		待转化字符 := subStr(待转化字符,1,StrLen(待转化字符)-1)
	}else if(strLen(待转化字符)>=2){
		待转化字符 := subStr(待转化字符,1,StrLen(待转化字符)-2)
	}
return
}

输入置空(){
	global
	Winkill,疯狂输入法选字框
	需重建窗口:=1
;	winget,活动窗口id,ID,A
;	if(活动窗口id!=被绑定窗口id)
;		Winactivate,ahk_id %被绑定窗口id%  
	待转化字符 :=""
	gb词典字串 :=""
	字母键到字表 :={}
	翻页数:=0
}

生成音词表(词典路径){							;词典每行格式 拼音\t词组 
	待返回音词表 :={}						;哈希数组需要初始化!!!!!!!!
	loop,read,%词典路径%
	{
		;msgbox,% A_LoopReadLine
		loop,parse,A_LoopReadLine,%a_tab%
		{
			if(A_LoopReadLine==""){
				break
			}
			if (A_index==1){
				拼音 := a_loopfield
			}
			if (A_index==2){
				待返回音词表[拼音] :=a_loopfield	;提取gb词典字串
			}
		}
		if(mod(a_index,400) ==0){
			tooltip,已载入词典.......
			setTimer,移除tip条,-300
		}
	}
	return 待返回音词表
}

显示候选(){
	local 显示输入字串,显示候选字串,词频词组
	显示输入字串 .= 待转化字符 

	词频词组 :=strSplit(常用词典字串,",")
	for 序号,值 in 数字选字键{
		字:=数字键到字表[值] :=词频词组[序号+翻页数*10]	;数字做键,词做值
		显示候选字串 .= 值 . "." 
		if (!字){
			显示候选字串 .= "　"
		}else 显示候选字串 .= 字 
		if (序号==10){
			显示候选字串 .= "`n "
		}else 显示候选字串 .=  " "
	}
	显示候选字串 .="--------------------------------------------------------------------`n"

;构造字母选字项	

	gb词典词组:=strSplit(gb词典字串,",")
	for 序号,值 in 字母选字键
	{
		字 :=字母键到字表[值]:=gb词典词组[序号+翻页数*26]
		显示候选字串 .= 值 . ""
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
	;tooltip,% 显示字串,光标位置.x,光标位置.y+20,2 
	;msgbox,% 字母键到字表["e"]
	gosub,显示候选框
	return

显示候选框:
	光标位置 :=获取光标位置()
	winget,活动窗口id,ID,A	
	if(绑定窗口id!=活动窗口id){
		Gui, 疯狂输入法选字框:+owner%活动窗口id%		;关键命令,太有用了!!!!!! 
		绑定窗口id :=活动窗口id	
	}
	if(需重建窗口){ 						
		窗口x :=光标位置.x,窗口y :=光标位置.y
		SplashImage,,x%窗口x% y%窗口y% b1 h145 w460 c10 fm14 fs14 wm400 ws400,%显示候选字串%,%显示输入字串%,疯狂输入法选字框,%显示字体%
		需重建窗口:=0
	}else{ 
		ControlSetText , static1, %显示输入字串%, 疯狂输入法选字框
		ControlSetText , static2, %显示候选字串%, 疯狂输入法选字框
	}

return
}

^esc::exitapp

#ifwinactive 输入法gbk版.ahk
~^s::reload 								;在脚本保存后重启脚本  