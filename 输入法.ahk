﻿ ;疯狂输入法,哈哈哈.....
#singleinstance force
SetTitleMatchMode 2
DetectHiddenWindows, On

CoordMode,caret,screen
menu,tray,icon,.\图标文件.icl,1

全部选字键:=strsplit("qwertyuiopasdfghjkl;zxcvbnm,./")
选字优化表:=strsplit("erdfuijkwoslcvm,x.tyghbnqpa;z/")  	;分配选字的按键顺序,达到更舒适的感觉,更快的选字速度,请自行修改
中文标点 :={",":"，" , ".":"。" ,";":"；" , "/":"、"}

输入法开关:=1	;初始打开中文
中文下启用英文标点:=0
音词表:=生成音词表(".\单字词典.txt")
输入字符 :=""
词典字串 :=""
键到字表 :={}
tip条序号:=1

#include 获取光标位置.ahk

~Lshift::
输入法开关:=!输入法开关
获取光标位置()
if (输入法开关){		;输入法开关提示
	tooltip, 中,光标位置.x+10,光标位置.y+20
	menu,tray,icon,.\图标文件.icl,1
}else{
	tooltip,EN,光标位置.x+10,光标位置.y+20
	menu,tray,icon,.\图标文件.icl,2
	输入置空()	;清空已记录输入
}
tip条序号:=1
setTimer,移除tip条,-1000
return

移除tip条:
tooltip,,,,%tip条序号%
return

#Include 注册输入键.ahk
按键 :=subStr(A_thisHotKey,2)	;去除热键$符号,获取热键
if(输入法开关){
	中文输入(按键)
}else send,{%按键%}
return

;输入法核心步骤
中文输入(按键){
	global
	if (instr(",./;",按键)){	;发送中文标点符号
		if(strLen(输入字符)==0){
			if(中文下启用英文标点){
				send,{%按键%}
			}else send,% 中文标点[按键]
			return
		}
	}
	if(按键=="."){	;做下翻页操作,功能还没做!!!
		;return
	}else if(按键=="backspace"){	;做删除操作
		gosub,删除操作
	}else if(按键=="esc"){	;做取消操作
		输入置空()
		return
	}else if(按键=="space"){		;空格键处理
		if(strLen(输入字符)==0){
		send,{space}
		}else return	;do nothing
	}else 输入字符 .=按键
	if (strLen(输入字符)==0){
		输入置空()
	}else if(strLen(输入字符)==1){
		词典字串 :=""
		显示候选()
		;单个字符,以后加入数字选字,暂留空
	}else if (strLen(输入字符)==2){
		词典字串 := 音词表[输入字符]
		显示候选()
	}else if(strLen(输入字符)==3){		;暂不考虑翻页,等下优化!!!
		if(词典字串==""){
			send,% 输入字符
		}else{
			选中字 :=键到字表[按键]
			send,%选中字%
		}
		输入置空()
	}
return
删除操作:
	if(strLen(输入字符)==0){
		send,{%按键%}
	}else if(strLen(输入字符)>=1){
		输入字符 := subStr(输入字符,1,StrLen(输入字符)-1)
	}
return
}

输入置空(){
	global
	Winkill,疯狂输入法选字框
	输入字符 :=""
	词典字串 :=""
	键到字表 :={}
}

生成音词表(词典路径:=".\单字词典.txt"){
	音词表 :={}	;哈希数组需要初始化!!!!!!!!
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
				音词表[拼音] :=a_loopfield	;提取词典字串
			}
		}
		if(mod(a_index,400) ==0){
			tooltip,已载入词典.......
			setTimer,移除tip条,-300
		}
	}
	return 音词表
}

显示候选(){
	global 输入字符,全部选字键,选字优化表,键到字表,词典字串,光标位置
	显示输入字串 .= 输入字符 
	显示候选字串 .="------------------------------------------------------------------`n"
	if (词典字串==""){
		;gosub,显示候选框
		return
	}
	词组:=strSplit(词典字串,",")
	for 序号,值 in 选字优化表{
		键到字表[值] :=词组[序号]		;字母做键,词做值
	}
	for 序号,值 in 全部选字键
	{
		显示候选字串 .= 值 . " "
		if (!键到字表[值]){
			显示字串 .= " "
		} 
		显示候选字串 .= 键到字表[值] . " "
		if (序号==10){
			显示候选字串 .= "`n "
		}else if(序号==20){
			显示候选字串 .= "`n  "
		}
	}
	gosub,显示候选框
	;tooltip,% 显示字串,光标位置.x,光标位置.y+20,2
	;msgbox,% 键到字表["e"]
	return
显示候选框:
	光标位置 :=获取光标位置()
	winget,正在输入应用id,ID,A
	winkill,疯狂输入法选字框
	SplashImage,, b1 h140 w420 c00 fm14 wm1 fs14 ws400 hide,%显示候选字串%,%显示输入字串%,疯狂输入法选字框,华文细黑
	WinShow,疯狂输入法选字框
	WinMove,疯狂输入法选字框, , 光标位置.x,光标位置.y
	Winactivate,ahk_id %正在输入应用id%
return
}

上屏(按键,待选词组){
	词组 :=strsplit(待选词组,",")
	global 全部选字键
	序号 := instr(全部选字键,按键)
	return 词组[序号]
}

^esc::exitapp

#ifwinactive 输入法.ahk
~^s::reload ;在脚本保存后重启脚本