; 获取光标位置（坐标相对于屏幕）,河许人提供
; From Acc.ahk by Sean, jethrow, malcev, FeiYue

获取光标位置(Byref 光标X="", Byref 光标Y=""){
	static init
	CoordMode, Caret, Screen
	光标X:=A_CaretX, 光标Y:=A_CaretY
	if (!光标X or !光标Y)
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
return {x:光标X, y:光标Y}
}