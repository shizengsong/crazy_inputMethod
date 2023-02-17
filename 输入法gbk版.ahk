;疯狂输入法,哈哈哈.....
;快捷键说明:
;Lshift:切换中英文输入 f4:切换单字模式 
;翻页按钮: 逗号句号,-号=号
;中文状态下切换中英文标点:ctrl+句号
;翻页键直接进入选字状态，空格选中第一个词并进入选字状态，其他标点符号也可以进入选字状态
;在输入三个字符的情况下,按 逗号或句号或tab键 可以盲打出字(例如dee加句号，将打出“的”字，ler加句号，会打出“了”字)
;选字状态中backspace删除已确认文字,delete删除未确认拼音
;删除键好像有一些bug,在再次删除的时候,会在刚插入时就删除拼音,待修正
#include  %A_ScriptDir%\程序头文件.ahk		;程序头文件,通常不用修改

;请把默认使用英文标点的程序写到这里
使用英文标点的程序列表:="emeditor.exe,scite.exe,notepad.exe,explorer.exe,cmd.exe,worldeditydwe.exe"	
;需要中文输入的程序列表
需要输入法的程序列表:="winword.exe,360chrome.exe,miniplorer.exe" . 使用英文标点的程序列表
表情:={"haha":"O(∩_∩)O","hehe":"^_^ ","oe":"-_-#"				;表情功能,请自行添加(自己定义字符,可自行修改)
	,"hj":"-_-!","of":":-) ","hkde":"-)","yn":"@_@","xixi":"^_^"}			;hj:汗，of:嗯 等均为按照智能abc的双拼编码，请自行修改

启用中文标点:=0									;这个不用改,已经是自动的了,这个只是初始化时的标点

;双拼编码, 设置文件在双拼编码文件夹下,若没有则到双拼编码文件夹中去建(文件后缀为txt,非ini,注意)
;可用的有：智能ABC,微软拼音,拼音加加,紫光拼音,搜狗拼音,自然码,小鹤双拼,请自行修改
;修改下面名称即可
双拼编码:="智能ABC"

#include %A_ScriptDir%\双拼编码映射.ahk							;这个文件不用修改

单字模式:=0									;快捷键为f4
输入法开关:=1									;初始打开中文
;自动进入选字模式时间:=300							;只打两个字符时，自动进入选字的时间，单位为毫秒，越小越灵敏，小心使用，注释掉则不自动进入选字

字体 := "华文细黑"								;字体调整过后，排版可能会有些问题，可尝试在下面调分割符和窗口高度宽度
										;华文细黑比较好看，建议使用

if(字体=="华文细黑"){
	初始高度:=50, 初始宽度:=550,单行高度:=21,字体大小:=14,文字宽度:=9
}else if(字体=="微软雅黑"){
	初始高度:=54, 初始宽度:=430,单行高度:=23,字体大小:=13,文字宽度:=15
}else{
	初始高度:=45, 初始宽度:=480,单行高度:=18,字体大小:=13,文字宽度:=17
}

数字按键:="1234567890"								;所有的数字按键，要减少选字项，可以改这个(不保证不出错)
字母按键:="qwertyuiopasdfghjklzxcvbnm"					;所有的字母按键
大写字母按键 :="+q+w+e+r+t+y+u+i+o+p+a+s+d+f+g+h+j+k+l+z+x+c+v+b+n+m"	;shift+字母按键
gbk单字表 :=生成音词表(A_ScriptDir . "\词典\gbk全字典.txt")			;疯狂输入法特色，包含gbk所有汉字,按计算机编码排序(即gbk2,gbk3,gbk4的顺序放字)
常用拼音表 :=生成音词表(A_ScriptDir . "\词典\小词典.txt")				;一个比较小的词典，载入快。缺点也是比较小，但是还算够用，因为我们还有gbk
单字模式:=0									;每次只打一个字的单字模式，不太常用。f4:切换单字模式 
数字按键组:=strSplit(数字按键)
字母按键组:=strSplit(字母按键)

中文标点 :={",":"，"  ,  ".":"。"  , ";":"；"  ,  "/":"、", "+1":"！" , "+2":"@" 			;此处包含除了引号之外的中文标点
		, "+3":"{#}" ,"+4":"￥" , "+5":"%" , "+6":"……" , "+7":"&" 
		, "+8":"*" , "+9":"（" , "+0":"）" ,  "+,":"《" , "+.":"》" 
		, "+/":"？" , "[":"【" , "]":"】" , "+;":"：","+-":"—","+'":" " }
英文括号按键:={"+9":"(){left}", "+,":"<>{left}",  "[":"[]{left}"				;简化括号的发送问题，发送对称括号
		,  "+[":"{{}{}}{left}", "+'":"""""{left}"}

功能键:=["esc","backspace","space","enter","tab","delete","-","="]

gosub,注册按键

引号已发送:=1									;双引号问题
汉语结构单字:="自从到往在由向于至趁当按靠照用据拿比因为被给让叫归把将管对跟和给替同和跟与及或而并的得地着了过连们所吗么吧呢啊着嘛呗啦嘞喽都全单共光尽净仅就又只才可倒却不没别刚正将老总很极最太更"						;汉语里面常用的结构性的单字，为构造词时排除所用

待保存词语:=已确认文字:=刚确认文字:=刚转化字符:= 插入字符:= 构造词记忆:=用户自造词拼音:=已转化字符:=待转化字符 := 原字符:= 句末标点 :=gb词典字串 :=常用词典字串:=""
用户词典表:={}, 字母键到字表 :={}, 数字键到词表 :={}
上翻页键 := "-[,", 下翻页键 := "=]."
前选字为单字:=字母翻页数:=数字翻页数:=选字状态:=0

winget,上个进程名,ProcessName,A

setTimer,根据进程切换输入法和标点,300

#IF
^.::										;ctrl+句号切换中英文标点
	if(启用中文标点:=!启用中文标点 ){
		tooltip,中文标点,%A_caretx% ,% A_carety-25
	}else tooltip,英文标点,%A_caretx% ,% A_carety-25
	settimer,关闭tooltip,-1000
return

^space::
输入法开关:=!输入法开关
gosub,切换输入法
return

~Lshift::
keywait,shift,T0.2								;用此句修正和其他的按键的冲突
if(A_thishotkey!="~Lshift"||errorlevel)
	return
输入法开关:=!输入法开关
切换输入法:
光标位置:=获取光标位置()
if (输入法开关){							;切换中英文
	mousegetpos,x,y
	Hotkey, IfWinActive
	gosub,注册按键
	hotkey,^.,on
	if(自动切换){
		自动切换:=0
	}else{
		tooltip,中文,% x ,% y-25
		setTimer,关闭tooltip,-500
	}
	menu,tray,icon,%A_ScriptDir%\图标\图标文件.icl,1
}else{
	send,% 已确认文字 . 插入字符 . 原字符 . 句末标点
	输入置空()
	mousegetpos,x,y
	if(自动切换){
		自动切换:=0
	}else{
		tooltip,EN,% x ,% y-25
		setTimer,关闭tooltip,-500
	}
	setTimer,关闭tooltip,-500
	Hotkey, IfWinActive
	gosub,注销按键
	hotkey,^.,off
	menu,tray,icon,%A_ScriptDir%\图标\图标文件.icl,2			;清空已记录输入
}
return

关闭tooltip:
tooltip
return

接管按键:
if(instr(A_thisHotKey,"$")){
	按键 :=subStr(A_thisHotKey,2)						;去除热键$符号,获取热键
}else 按键:=A_thisHotKey
if(getkeystate("capslock","t")){
	原义发送(按键)
}else if(输入法开关 && 获取光标位置().类型!="mouse"){
	中文输入(按键)
}else 原义发送(按键)
return

原义发送(按键){
	global
	if (按键=="backspace"){
		send,{%按键%}
		if(构造词记忆){						
			用户词典表.delete(构造词记忆)					
			if(strlen(构造词记忆)>=6 && mod(strlen(构造词记忆),2)==0)
				用户词典表.delete(substr(构造词记忆,1,-1))
		}
	}else if (按键=="space"||按键=="enter" ||按键=="esc"||按键=="tab"||按键=="delete" ){
		send,{%按键%}							;特殊按键发送要用 {%按键%}，普通按键发送要用% 按键
	}else if(英文括号按键["" . 按键]){						;发送对称括号，方便打括号
		send,% 英文括号按键["" . 按键]
	}else if(getkeystate("capslock","t")){					;检测大写字母开关
		StringUpper,按键,按键
		send,% 按键
	}else send,% 按键
}

中文输入(按键){									;输入法核心步骤	
	local 选中字,选中词
	if (instr(按键 ,"+") && instr(大写字母按键,按键)){
		按键:=substr(按键,2)
		StringUpper,按键,按键
	}
	字符数:=strLen(待转化字符),选中词:=选中字:=""
	if(单字模式 && 字符数==1 && instr(字母按键,按键) ){
		原字符.=按键,待转化字符 .= 按键, 产生字串(待转化字符), 选字状态:=1
		gosub,判断发送上屏
		return
	}
	if (字符数==0 && !instr(字母按键,按键)){					;处理非打字状态下的特殊按键，包括符号
		if(启用中文标点 && 中文标点["" . 按键]){				;强制转换按键为字符类型，只有这个古怪的语法起作用-_-||……,
			发送中文标点(按键)					;正常发送中文标点
		}else 原义发送(按键)
		return
	}else if(instr(数字按键,按键) ||按键=="space"||按键=="tab"||中文标点["" . 按键]){	;数字及空格等选字键
		if(中文标点["" . 按键]){
			if (instr(下翻页键,按键)){
				gosub,下翻页
			}else if(instr(上翻页键,按键) ){
				gosub,上翻页
			}else 句末标点 := 中文标点["" . 按键]	
;			if(instr(下翻页键,按键)||instr(上翻页键,按键) ){		;若标点为句号或逗号，则进行翻页
;				if (选字状态) {			
;					if(instr(下翻页键,按键) && (数字键到词表[1]||字母键到字表["q"])){
;						数字翻页数++,字母翻页数++
;					}else if(instr(上翻页键,按键)){
;							if (数字翻页数!=0){
;								
;							}
;						}
;						翻页数--
;				}else if()
;			}else 句末标点 := 中文标点["" . 按键]			;非翻页标点,则进入选字
			选字状态:=1
			gosub,判断发送上屏
			return
		}
		选字状态:=1
		if(按键=="tab"){							;在三个字符的情况下,盲打出字
				if(!已确认文字 && strlen(待转化字符)==3){
					gosub,盲打出字
					return
				}
		}else if(按键=="space") {
				if(!选中词:=用户自造词)				;存在用户自造词情况下，使用用户自造词 
					选中词:=数字键到词表[1]
		}else 选中词:=数字键到词表[按键]
		if(选中词){
			已确认文字.=刚确认文字:=选中词
			字母翻页数:=数字翻页数:=0
			if(strlen(插入字符)>0){
				多余字符数:=strlen(选中词)*2 - strlen(插入字符)
				if(多余字符数>0){
					已转化字符.=插入字符 . substr(待转化字符,1,多余字符数)
					插入字符:="",原字符:=substr(原字符,多余字符数+1),待转化字符:=substr(待转化字符,多余字符数+1)
				}else 已转化字符.=substr(插入字符,1,strlen(选中词)*2),插入字符:=substr(插入字符,strlen(选中词)*2+1),
				if(!插入字符){						;结束插入状态 
					插入状态:=0,产生字串(待转化字符)
				}else 产生字串(插入字符 . 待转化字符)
			}else {
				if(strlen(选中词)==1){					;制作用户词语记忆功能
					if(instr(汉语结构单字,选中词)){
						if(前选词为单字 && strlen(用户自造词拼音)>=4){	;如果为列表中字,则中断构造词记录
							保存用户构造词(用户自造词拼音 . substr(待转化字符,1,2),待保存词语 . 选中词)
						}
						前选词为单字:=0
					}else {
						if(前选词为单字){			;继续记录
							用户自造词拼音.=substr(待转化字符,1,2),待保存词语.=选中词
						}else 用户自造词拼音:=substr(待转化字符,1,2),待保存词语:=选中词	;开始记录
						前选词为单字:=1
					}
				}else{							;选中为词语
					if(选中词!=数字键到词表[1]){			;非首选项提前
						字串:=substr(待转化字符,1,strlen(选中词)*2)
						保存用户构造词(字串,选中词)
					}
					if(前选词为单字 && strlen(用户自造词拼音)>=4)	;单字构成词的保存
						保存用户构造词(用户自造词拼音,待保存词语)
					前选词为单字:=0
				}
				已转化字符.=刚转化字符:=substr(待转化字符,1,strlen(选中词)*2)
				待转化字符:=substr(待转化字符,strlen(选中词)*2+1),原字符:=substr(原字符,strlen(选中词)*2+1)
				产生字串(待转化字符)
			}
		}
		gosub,判断发送上屏
		return
	}else if(instr(下翻页键,按键)){				;翻页	
		gosub,下翻页
;		if (instr(下翻页键,按键) && (数字键到词表[1]||字母键到字表["q"])){
;			翻页数+=1
;		}else if(instr(上翻页键,按键) && 翻页数!=0){				;上翻页
;			翻页数-=1
;		}else return
		选字状态:=1, 产生候选()
	}else if(instr(上翻页键,按键)){
		gosub,上翻页
		选字状态:=1, 产生候选()
	}else if(按键=="esc"){								;做取消操作
		输入置空()
	}else if(按键=="enter"){								;直接按键上屏
		send,% 已确认文字 . 插入字符 . 原字符 . 句末标点
		输入置空()
	}else if(按键=="backspace" ||按键=="delete"){					;做删除操作
		gosub,删除操作
	}else if(!选字状态){								;输入状态
		if(插入状态){
			插入字符.=按键, 产生字串(插入字符 . 待转化字符)			;插入中输入状态
		}else{									;正常输入状态
			
			原字符.=按键
			待转化字符 .= 按键
			if (strlen(待转化字符)>=2 && A_TimeIdle <20)
				需延时:=true
			if (!需延时){
				产生字串(待转化字符)
			}else 延迟产生字串(待转化字符)
		}
		if (!需延时){
			产生候选()
		}else 延迟产生候选()
		需延时:=false
	}else if(选字状态){								;输入法字母键的四个状态：输入状态，选字状态，插入中输入状态，插入中选字状态
		选中字:=字母键到字表[按键]						;好晕@_@
		if(选中字){
			已确认文字.=刚确认文字:=选中字, 字母翻页数:=数字翻页数:=0
			if(strlen(插入字符)>0){						;插入中选字状态	
				if(strlen(插入字符)==1){
					已转化字符.=插入字符 . substr(待转化字符,1,1)
					插入字符:="",待转化字符:=substr(待转化字符,2),原字符:=substr(原字符,2)
				}else 已转化字符.=substr(插入字符,1,2),插入字符:=substr(插入字符,3)
				if(!插入字符){
					插入状态:=0, 产生字串(待转化字符)		;插入选字状态结束，继续转化剩余字串
				}else 产生字串(插入字符 . 待转化字符)
			}else {								;正常字母选字状态
				if(instr(汉语结构单字,选中字)){
					if(前选词为单字 && strlen(用户自造词拼音)>=4)	;如果为列表中字,则中断构造词记录
						保存用户构造词(用户自造词拼音 . substr(待转化字符,1,2),待保存词语 . 选中字 )
					前选词为单字:=0
				}else {
					if(前选词为单字){				;继续记录
						用户自造词拼音.=substr(待转化字符,1,2),待保存词语.=选中字
					}else 用户自造词拼音:=substr(待转化字符,1,2),待保存词语:=选中字	;开始记录
					前选词为单字:=1
				}
				已转化字符.=刚转化字符:=substr(待转化字符,1,2)
				待转化字符:=substr(待转化字符,3),原字符:=substr(原字符,3)
				产生字串(待转化字符)
			}
			gosub,判断发送上屏
		}
	}
	return

盲打出字:
	产生字串(substr(待转化字符,1,2)), gb词典词组:=strSplit(gb词典字串,",")
	位置:=instr(字母按键,substr(待转化字符,3,1))
	send,% gb词典词组[位置]
	输入置空()
return

删除操作:
	前选字为单字:=0
	if(插入状态){	
		用户自造词拼音:=""
		if(按键=="backspace"){
			if(strlen(插入字符)>0){					;插入状态中删除
				插入字符 := subStr(插入字符,1,-1),选字状态:=0
				if (strlen(插入字符)>0){
					产生字串(插入字符 . 待转化字符), 产生候选()
					return
				}
			}else if(strlen(已确认文字)>0){				
				已确认文字:=substr(已确认文字,1,-1),已转化字符:=substr(已转化字符,1,-2)
			}else 插入状态:=0,待转化字符:=substr(待转化字符,1,-1),原字符:=substr(原字符,1,-1)	;无字可删除时
		}else if(按键=="delete")
			待转化字符 := subStr(待转化字符,2),原字符:=subStr(原字符,2)			;删除剩余字符的句首字母	
	}else if (strlen(已确认文字)>0 && (按键=="backspace")){						;下面均非插入状态下
		if(!数字键到词表[1]){				;拼不出字的情况下 
			if(strlen(待转化字符)!=1){
				待转化字符:=substr(待转化字符,1,-1),原字符:=substr(原字符,1,-1)
			}else 待转化字符:="",原字符:=""
			用户自造词拼音 :="", 选字状态:=0
		}else {
			插入字符:=刚转化字符
			已确认文字:=substr(已确认文字,1,0-strlen(刚确认文字)), 已转化字符:=substr(已转化字符,1,0-strlen(刚转化字符))
			插入状态:=1
			用户自造词拼音 :=""	;, 选字状态:=0
			产生字串(插入字符 . 待转化字符), 产生候选()
			return
		}
	}else if(按键=="backspace" && strlen(已确认文字)==0){						;转化前的删除	
			if(!数字键到词表[1]){
				if(strlen(待转化字符)!=1){
					待转化字符:=substr(待转化字符,1,-1),原字符:=substr(原字符,1,-1)
				}else 原字符:=待转化字符:="",
			}else 待转化字符:=substr(待转化字符,1,-1),原字符:=substr(原字符,1,-1)
			选字状态:=0
	}else if(按键=="delete"){
		if (strlen(已确认文字)>0){
			待转化字符:=subStr(待转化字符,2),原字符:=substr(原字符,2)
		}
		插入状态:=1
		用户自造词拼音 :="", 选字状态:=0
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
		if(前选词为单字 && strlen(用户自造词拼音)>=4)
			保存用户构造词(用户自造词拼音,待保存词语)
		if(已确认文字 && 已转化字符)
			保存用户构造词(已转化字符,已确认文字)
		send,% 已确认文字 . 句末标点
		输入置空()
	}else 产生候选()
return

保存构造词:									;两秒内按删除,会删除用户构造词
	构造词记忆:=""
return

保存用户构造词(输入字符,词语){
	global 用户词典表,构造词记忆
	构造词记忆:=输入字符
	if (构造词记忆 && (!用户词典表[构造词记忆] ||用户词典表[构造词记忆]!=词语)){
		用户词典表[构造词记忆]:=词语
		if(mod(strlen(构造词记忆),2)==0 && strlen(构造词记忆)>=6)
			用户词典表[substr(构造词记忆,1,-1)]:=词语
	}
	settimer,保存构造词,-2000  
}

输入置空(){
	global
	gui,destroy
	gui,疯狂输入法选字窗:destroy
	刚确认文字:=刚转化字符:=已转化字符:=待保存词语:=用户自造词拼音:=用户自造词:=gb词典字串 :=已确认文字:=插入字符 := 原字符:=待转化字符 := 句末标点 :=""
	前选字为单字:=插入状态:=选字状态:=数字翻页数:=字母翻页数:=0
	字母键到字表 :={}
}
发送中文标点(按键){
	global 引号已发送,中文标点
	if(按键=="+'"){				;处理引号
		if(引号已发送:=!引号已发送){
			send,”
		}else send,“
	}else send,% 中文标点["" . 按键]		;临时发送中文标点
}
延迟产生字串(字串){
	global 临时字串
	临时字串:=字串
	settimer,延迟产生字串,-10
}
延迟产生字串:
	产生字串(临时字串)
return

产生字串(原字符){
	global 常用拼音表,gbk单字表,用户词典表,常用词典字串,gb词典字串,用户自造词,双拼编码,表情
	字符:=原字符,用户自造词:=""
	if(表情[原字符]){
		用户自造词:="{raw}"  .  表情[原字符]
	}else while(strlen(字符)>=4){
		if(用户自造词:=用户词典表[字符])
			break
		if(mod(strlen(字符),2)==1){
			字符:=substr(字符,1,-1)
		}else 字符:=substr(字符,1,-2)
	}
	字符:=双拼转换(原字符, 双拼编码),常用词典字串:=""
	gb词典字串 := gbk单字表[substr(字符,1,2)]
	while (strlen(字符)>=1){		
		新字串:=常用拼音表[字符]
		if(新字串 && 常用词典字串)
			常用词典字串 .= ","
		常用词典字串 .= 新字串
		if(mod(strlen(字符),2)==0){
			字符:=substr(字符,1,-2)
		}else 字符:=substr(字符,1,-1)
	}
}

生成音词表(词典路径){								;词典每行格式 拼音\t词,词 
	fileread,已读文件,%词典路径%
	待返回音词表:={}							;哈希数组需要初始化!!!!!!!! 
	loop,parse,已读文件,`n, `r 
	{
		当前行 :=
		字串组:=strsplit(A_LoopField,a_tab)
		if(拼音:=字串组[1])
			待返回音词表[拼音]:=字串组[2]
		if(mod(a_index,500) ==0)
			tooltip,正在载入词典%A_index%行.......
	}
	setTimer,关闭tooltip,-100
	已读文件:=""
	return 待返回音词表
}

延迟产生候选(){
	settimer,延迟产生候选,-20
}
延迟产生候选:
	产生候选()
return
产生候选(){
	local 显示输入字串,显示候选字串,显示用户自造词,常用词典词组
	显示输入字串:=较常用字:=显示候选字串:=""
	显示输入字串 .= 已确认文字 . 插入字符
	if(插入状态){
		显示输入字串 .="|" . 原字符 . 句末标点 . ""
	}else 	显示输入字串 .= 原字符 . "_"  . 句末标点 . ""
	if(显示用户自造词:=用户自造词){
		StringReplace,显示用户自造词,显示用户自造词,% "{raw}",%  "",all		
		显示输入字串 .= "`n◉" . 显示用户自造词 . " "
	}else 显示输入字串 .="`n"
	常用词典词组 :=strSplit(常用词典字串,","), gb词典词组:=strSplit(gb词典字串,",")
	for 序号,值 in 常用词典词组{
		if(序号>15){
			break
		}else 较常用字.=值
	}
	for 序号,值 in 数字按键组{
		字:=数字键到词表[值] :=常用词典词组[序号+数字翻页数*strlen(数字按键)]	;数字做键,词做值
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
	for 序号,值 in 字母按键组
	{
		字母键到字表[值]:=gb词典词组[序号+字母翻页数*strlen(字母按键)]		;字母做键,字做值
		字 :=字母键到字表[值]
		显示候选字串 .= 值 . "."
		if (!字){
			显示候选字串 .= "　"
		}else 显示候选字串 .= 字 
		if (序号==10){
			显示候选字串 .= "`n　" 
		}else if (序号==19){
			显示候选字串 .= "　　`n" 
		}else if (序号==26){
			显示候选字串 .= "　　" 
		}else 显示候选字串 .=  " "
	}
	gosub,显示候选框
return

显示候选框:
	光标位置 :=获取光标位置()
	if(!winexist("疯狂输入法选字窗")){					;初始化输入法窗口
		if(光标位置.x<A_ScreenWidth -初始宽度){
			窗口x :=光标位置.x
		}else	窗口x :=A_ScreenWidth -初始宽度
		if(光标位置.y<A_ScreenHeight-初始高度){
			窗口y :=光标位置.y
		}else	窗口y :=A_ScreenHeight -初始高度
		gui, font,% "s" 字体大小, %字体%
		Gui, Margin ,10,0
		Gui, +AlwaysOnTop +Disabled -SysMenu +Owner -Caption +Border +Theme
		Gui, Add, Text,% "w" 初始宽度 " y2" " h" 单行高度*2, %显示输入字串%
		Gui, Add, pic, % "w" 初始宽度-40 " h1" " x15",%A_ScriptDir%\图标\分割线.bmp
		Gui, Add, Text,% "w" 初始宽度 " center", %显示候选字串%
		Guicontrol,hide,static2
		Gui, Show,x%窗口x% y%窗口y% h%初始高度% w%初始宽度%  NoActivate, 疯狂输入法选字窗
		winset,alwaysontop,on,疯狂输入法选字窗
	}else{
		winshow,疯狂输入法选字窗
		;tooltip,输入法
		winget,活动窗口id,ID,A	
		if(绑定窗口id!=活动窗口id){
			Gui, 疯狂输入法选字窗:+owner%活动窗口id%		;绑定输入法的窗口到活动窗口,不绑定好像容易出错		
			绑定窗口id :=活动窗口id	
		}
		字符数:=0
		loop % strlen(数字按键){					;窗口宽度计算
			字符数+=strlen(数字键到词表[A_index-1])
		}
		if(字符数+strlen(用户自造词)>11){				;宽度显示尚需调整,有时有错误
			宽度:=(字符数+3*strlen(数字按键)+strlen(用户自造词)-10*4)*文字宽度+初始宽度
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
		;winset,alwaysontop,on,疯狂输入法选字窗	
	}
return
}
上翻页:
	if(数字翻页数!=0)
		数字翻页数--
	if(选字状态 && 字母翻页数!=0)
		字母翻页数--
return

下翻页:
	if(数字键到词表[1])
		数字翻页数++
	if(选字状态 && 字母键到字表["q"])
		字母翻页数++
return

根据进程切换输入法和标点:
	winget,进程名,ProcessName,A
	if(进程名 != 上个进程名){
		if (进程名 && instr(需要输入法的程序列表,进程名)){
			if (instr(使用英文标点的程序列表,进程名)){
				启用中文标点:=0
			}else
				启用中文标点:=1
			if(!输入法开关){
				输入法开关:=1
				自动切换:=1
				gosub,切换输入法
			}
		}else {
			启用中文标点:=1
			if(输入法开关){
				输入法开关:=0
				自动切换:=1
				gosub,切换输入法
			}
		}
		上个进程名:=进程名
	}
return

注册按键:
hotkey,if									;少了这句,差点要死
for 序号,值 in 数字按键组
	hotkey,% "$" 值,接管按键,on
for 序号,值 in 字母按键组{
	hotkey,% "$" 值,接管按键,on
	hotkey,% "$+" 值,接管按键,on
}
for 序号,值 in 功能键
	hotkey,% "$" 值,接管按键,on
for 键 in 中文标点
	hotkey,% "$" 键,接管按键,on
for 键 in 英文括号按键
	hotkey,% "$" 键,接管按键,on
return

注销按键:
hotkey,if
for 序号,值 in 数字按键组
	hotkey,% "$" 值,接管按键,off
for 序号,值 in 字母按键组{
	hotkey,% "$" 值,接管按键,off
	hotkey,% "$+" 值,接管按键,off
}
for 序号,值 in 功能键
	hotkey,% "$" 值,接管按键,off
for 键 in 中文标点
	hotkey,% "$" 键,接管按键,off
for 键 in 英文括号按键						;英文输入法下,括号仍启用
	hotkey,% "$" 键,接管按键,off
for 键 in 英文括号按键						;英文输入法下,括号仍启用
	hotkey,% "$" 键,接管按键,on
return

^esc::exitapp									;ctrl+esc强制退出输入法

; 获取光标位置（坐标相对于屏幕）,河许人提供
; From Acc.ahk by Sean, jethrow, malcev, FeiYue

获取光标位置(){					;Byref 光标X="", Byref 光标Y=""
	static init
	CoordMode, Caret, Screen
	光标X:=A_CaretX, 光标Y:=A_CaretY
	if (!光标X or !光标Y){
		Try {
			if (!init)
				init:=DllCall("LoadLibrary","Str","oleacc","Ptr")
				VarSetCapacity(IID,16), idObject:=OBJID_CARET:=0xFFFFFFF8
				, NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0, IID, "Int64")
				, NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81, IID, 8, "Int64")
				if DllCall("oleacc\AccessibleObjectFromWindow"
				, "Ptr",WinExist("A"), "UInt",idObject, "Ptr",&IID, "Ptr*",pacc)=0
			{
				Acc:=ComObject(9,pacc,1), ObjAddRef(pacc)
				, Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0)
				, ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId:=0)
				, 光标X:=NumGet(x,0,"int"), 光标Y:=NumGet(y,0,"int")
			}
		}
		if(光标X=0 && 光标Y=0){
			光标类型:="Mouse"
		}else 光标类型:="Acc"
	}else 光标类型:="Caret"
	return {x:光标X, y:光标Y,类型:光标类型}
}
	