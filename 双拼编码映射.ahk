;双拼编码:="微软拼音"	;这句已放至主文件中

;映射后的拼音,采用智能ABC编码(我个人的习惯,词典也是采用双拼编码存储,可以减少体积)
;这个代码是将任意双拼编码先查表映射为全拼,再转化为ABC双拼,因词典是按ABC双拼存储的
全拼音:="oa,ol,oj,oh,ok,ba,bl,bj,bh,bk,bq,bf,bg,bi,bw,bz,bx,bc,by,bo,bu,bn,ca,cl,cj,ch,ck,ce,cf,cg,ea,el
	,ej,eh,ek,ee,ef,eg,ei,es,eb,eu,ed,ec,ep,et,em,en,eo,ci,cs,cb,cu,cp,cm,cn,co,da,dl,dj,dh,dk,de,dq
	,df,dg,di,dd,dw,dz,dx,dy,dr,ds,db,du,dp,dm,dn,do,oe,oq,of,og,or,fa,fj,fh,fq,ff,fg,fz,fo,fb,fu,fm,fo,ga
	,gl,gj,gh,gk,ge,gq,gf,gg,gi,gs,gb,gu,gd,gc,gp,gt,gm,gn,go,ha,hl,hj,hh,hk,he,hq,hf,hg,hs,hb,hu,hd
	,hc,hp,ht,hm,hn,ho,ji,jd,jw,jt,jz,jx,jc,jy,js,jr,ju,jp,jm,jn,ka,kl,kj,kh,kk,ke,kq,kf,kg,ks,kb,ku,kd,kc,kp,kt,km
	,km,kn,ko,la,ll,lj,lh,lk,le,lq,lg,li,ld,lw,lt,lz,lx,lc,ly,lr,lo,ls,lb,lu,lp,lm,ln,lo,lv,m,ma,ml,mj,mh,mk,me,mq,mf
	,mg,mi,mw,mz,mx,mc,my,mr,mo,mb,mu,mm,n,na,nl,nj,nh,nk,ne,nq,nf,ng,ni,nw,nt,nz,nx,nc,ny,nr
	,ns,nb,nu,np,nm,nn,no,nv,oo,ob,pa,pl,pj,ph,pk,pq,pf,pg,pi,pw,pz,px,pc,py,po,pb,pu,qi,qd,qw,qt
	,qz,qx,qc,qy,qs,qr,qu,qp,qm,qn,rl,rj,rh,rk,re,rf,rg,ri,rs,rb,ru,rd,rp,rm,rn,ro,sa,sl,sj,sh,sk,se,sf,sg,va,vl,vj
	,vh,vk,ve,vq,vf,vg,vi,vb,vu,vd,vc,vp,vt,vm,vn,vo,si,ss,sb,su,sp,sm,sn,so,ta,tl,tj,th,tk,te,tq,tg,ti,tw,tz,tx
	,ty,ts,tb,tu,tp,tm,tn,to,wa,wl,wj,wh,wq,wf,wg,wo,wu,xi,xd,xw,xt,xz,xx,xc,xy,xs,xr,xu,xp,xm,xn,ya,yj,yh
	,yk,ye,yi,yc,yy,yo,ys,yb,yu,yp,ym,yn,za,zl,zj,zh,zk,ze,zq,zf,zg,aa,al,aj,ah,ak,ae,aq,af,ag,ai,as,ab,au
	,ad,ac,ap,at,am,an,ao,zi,zs,zb,zu,zp,zm,zn,zo"
双拼到全拼表_声母:={}, 双拼到全拼表_韵母:={}, 双拼到全拼表_零声母双字符:={} 
全拼到双拼表_声母:={}, 全拼到双拼表_韵母:={}, 全拼到双拼表_零声母双字符:={} 
生成双拼到全拼表("双拼编码\" . 双拼编码 . ".txt")
生成全拼到双拼表("双拼编码\智能ABC.txt")
双拼转换(全字符, 双拼编码){					
	if(双拼编码=="智能ABC" || !双拼编码)
		return 全字符
	最终字符:=""
	临时字符:=全字符
	if(mod(strlen(临时字符),2)==1){
		尾符:=双拼转换单声母(substr(临时字符,0))
		临时字符:=substr(临时字符,1,-1)
	}else 	尾符:=""
	while (strlen(临时字符)>=2){
		最终字符 .= 双拼转换双字符(substr(临时字符,1,2))
		临时字符 := substr(临时字符,3)
	}
	最终字符.=尾符
	return 最终字符
}

双拼转换单声母(单声母){
	global 双拼到全拼表_声母, 全拼到双拼表_声母
	if(声母全拼:=双拼到全拼表_声母[单声母]){
		return 最终声母:=全拼到双拼表_声母[声母全拼]
	}else 	return 单声母
}
双拼转换双字符(双字符){
	global	全拼音,双拼到全拼表_零声母双字符, 双拼到全拼表_声母, 双拼到全拼表_韵母
		,全拼到双拼表_零声母双字符, 全拼到双拼表_声母, 全拼到双拼表_韵母
	if (全拼:=双拼到全拼表_零声母双字符[双字符]){
		return 全拼到双拼表_零声母双字符[全拼]
	}else{
		声母:=substr(双字符,1,1),韵母:=substr(双字符,2,1)			;韵母可能有多个
		if(声母全拼:=双拼到全拼表_声母[声母]){
			最终声母:=全拼到双拼表_声母[声母全拼]
		}else 最终声母:=声母
		韵母全拼:=双拼到全拼表_韵母[韵母]
		if(!韵母全拼){				;韵母为a,o,e,i,u,v
			return (最终声母 . 韵母)
		}else if(instr(韵母全拼,",")){					;若双拼映射的韵母不止一个
			韵母组:=strsplit(韵母全拼,",")
			for 序号,值 in 韵母组{
				最终韵母:=全拼到双拼表_韵母[值]
				最终拼音:=最终声母 . 最终韵母
				if(instr(全拼音,最终拼音))				;若存在此ABC双拼,只转化一个,不做多个映射
					return 最终拼音
			}
			return 最终拼音						;查不到拼音也返回
		}else {								;只有一个映射韵母的情况
			最终韵母:=全拼到双拼表_韵母[韵母全拼]
			return (最终声母 . 最终韵母)
		}
	}
}

生成全拼到双拼表(文件路径){
	global 全拼到双拼表_声母, 全拼到双拼表_韵母, 全拼到双拼表_零声母双字符
	区域:=""
	Loop, read,% 文件路径
	{
		if(A_LoopReadLine=="[声母]"){
			区域:="声母", continue
		}else if(A_LoopReadLine=="[韵母]"){
			区域:="韵母", continue
		}else if(A_LoopReadLine=="[零声母音节的韵母]"){
			区域:="零声母音节的韵母", continue
		}else if(A_LoopReadLine!=""){
			拼音字串:=strsplit(A_LoopReadLine,"=")
			全拼:=拼音字串[1],双拼:=拼音字串[2]
			if(区域=="声母"){
				全拼到双拼表_声母[全拼]:=双拼
			}else if(区域=="韵母"){
				if(全拼到双拼表_声母[全拼]){
					全拼到双拼表_韵母[全拼] .= "," . 双拼
				}else	全拼到双拼表_韵母[全拼] := 双拼
			}else if(区域=="零声母音节的韵母"){
				全拼到双拼表_零声母双字符[全拼] := 双拼
			}
		}
	}
}

生成双拼到全拼表(文件路径){
	global 双拼到全拼表_声母, 双拼到全拼表_韵母, 双拼到全拼表_零声母双字符
	区域:=""
	Loop, read,% 文件路径
	{
		if(A_LoopReadLine=="[声母]"){
			区域:="声母", continue
		}else if(A_LoopReadLine=="[韵母]"){
			区域:="韵母", continue
		}else if(A_LoopReadLine=="[零声母音节的韵母]"){
			区域:="零声母音节的韵母", continue
		}else if(A_LoopReadLine!=""){
			拼音字串:=strsplit(A_LoopReadLine,"=")
			全拼:=拼音字串[1],双拼:=拼音字串[2]
			if(区域=="声母"){
				双拼到全拼表_声母[双拼]:=全拼
			}else if(区域=="韵母"){
				if(双拼到全拼表_韵母[双拼]){
					双拼到全拼表_韵母[双拼] .= "," . 全拼
				}else	双拼到全拼表_韵母[双拼] := 全拼
			}else if(区域=="零声母音节的韵母"){
				双拼到全拼表_零声母双字符[双拼] := 全拼
			}
		}
	}
}
