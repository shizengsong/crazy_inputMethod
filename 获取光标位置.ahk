; ��ȡ���λ�ã������������Ļ��,�������ṩ
; From Acc.ahk by Sean, jethrow, malcev, FeiYue

��ȡ���λ��(Byref ���X="", Byref ���Y=""){
	static init
	CoordMode, Caret, Screen
	���X:=A_CaretX, ���Y:=A_CaretY
	if (!���X or !���Y)
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
			, ���X:=NumGet(x,0,"int"), ���Y:=NumGet(y,0,"int")
			}
		}
return {x:���X, y:���Y}
}