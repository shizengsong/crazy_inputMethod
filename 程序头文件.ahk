#noenv
#singleInstance force
#persistent

程序路径:=substr(A_ScriptFullPath,1,-4) . ".exe"
图标路径:=substr(A_ScriptFullPath,1,-4) . ".ico"
程序名称:=substr(A_ScriptName,1,-4) . ".exe"

;不能忍,自己做个编辑菜单
Menu,tray, NoStandard
Menu,tray,Add,(&D)软件说明
Menu,tray,Add,(&E)编辑脚本
Menu,tray,Add,(&S)开机启动
Menu,tray,Add,(&R)程序重启
Menu,tray,Add,(&P)程序暂停
Menu,tray,Add,(&I)显示执行信息
Menu,tray,Add,(&X)退出程序
开机启动路径 =%A_Startup%\%程序名称%.lnk

IfExist, %开机启动路径%
	Menu,tray,Check,(&S)开机启动
else
	Menu,tray,UnCheck,(&S)开机启动

goto,开始运行

(&E)编辑脚本:
run,c:\windows\notepad.exe %A_ScriptFullPath%		;编辑器位置自己填
return

(&D)软件说明:
MsgBox,%软件说明%
Return

(&S)开机启动:
IfExist, %开机启动路径%
{
	FileDelete,%开机启动路径%
	Menu,tray,UnCheck,(&S)开机启动
}Else{
	FileCreateShortcut,%程序路径%,%开机启动路径%,%A_ScriptDir%\,,没有说明哈哈,
	Menu,tray,Check,(&S)开机启动
}
Return

(&P)程序暂停:
pause
return

(&R)程序重启:
reload
return

(&I)显示执行信息:
ListLines 
return

(&X)退出程序:
ExitApp

开始运行:

SetTitleMatchMode 2
SetWinDelay, 0
Sendmode input
CoordMode,caret,screen
menu,tray,icon,%A_ScriptDir%\图标\图标文件.icl,1				;拖盘图标,提取自影子输入法

软件说明:= "疯狂输入法特点:`n`n1.可以根据程序,自动切换中英文输入状态`n`n2.可以根据程序,自动切换中文输入状态下的标点`n`n3.使用26个键作为辅助码,单字的排序是按照汉字gbk编码的顺序.顺序永不变`n`n4.对颠倒的拼音可以进行智能修改`n`n5.对括号,引号自动补全.对编程人员很友好`n(默认的双拼编码为智能ABC,你可以在代码里修改,有详细说明,改下就行,已内置了常用的双拼编码)`n`n6.您可以很容易修改程序,随便怎么改,没用过ahk的人可以体验一下ahk的强大"