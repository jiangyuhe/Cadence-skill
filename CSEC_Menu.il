;deUnRegUserTriggers("maskLayout")

procedure(de()
cv=deGetCellView()
)
procedure(l_display_bBox_cb()
winid=getCurrentWindow()	cv=deGetCellView(winid)		list=cv~>bBox
lb=nthelem(1 list)		rt=nthelem(2 list)
printf("The Cell coordinate is %P  %P" lb rt)		
sprintf(coordinate "The Cell coordinate is %P  %P" lb rt)
	hiDisplayAppDBox(
			?name		'DisplayCoordinate
			?dboxBanner	"DisplayCoordinate"	
			?dboxText	coordinate
			?dialogType	hicInformationDialog
			?dialogStyle	'modeless
			?buttonLayout	'Close
			)
)
procedure(l_mv_origin_center_cb()
winid=getCurrentWindow()	cv=deGetCellView(winid)		list=cv~>bBox
lb=nthelem(1 list)		rt=nthelem(2 list)		
center_x=(nthelem(1 lb)+nthelem(1 rt))/2.0	center_y=(nthelem(2 lb)+nthelem(2 rt))/2.0
leMoveCellViewOrigin( cv list(center_x center_y) )
leEIPZoomAbsoluteScale(hiGetCurrentWindow() 0.9)
)
procedure(l_mv_origin_leftb_cb()
winid=getCurrentWindow()	cv=deGetCellView(winid)		list=cv~>bBox
lb=nthelem(1 list)		rt=nthelem(2 list)		
center_x=nthelem(1 lb)				center_y=nthelem(2 lb)
leMoveCellViewOrigin( cv list(center_x center_y) )
leEIPZoomAbsoluteScale(hiGetCurrentWindow() 0.9)
)

procedure(l_generate_is_cb()
winid=getCurrentWindow()	cv=deGetCellView(winid)
lib=cv~>libName		cell=cv~>cellName	view=strcat(cv~>viewName "_CSEC")
bBox=cv~>bBox
lb=nthelem(1 bBox)	rt=nthelem(2 bBox)
lb_x=nthelem(1 lb)	lb_y=nthelem(2 lb)
rt_x=nthelem(1 rt)	rt_y=nthelem(2 rt)	
die_x=rt_x-lb_x		die_y=rt_y-lb_y
die_size=max(die_x die_y)
mode=cv~>mode
if(mode=="r"	then
	hiDisplayAppDBox(
			?name		'warning1_generate_is
			?dboxBanner	"Generate IS for circuit"	
			?dboxText	"The cell is not writable,please open the cell in append/write mode!\n"
			?dialogType	hicInformationDialog
			?dialogStyle	'modeless
			?buttonLayout	'Close
			)
);end if mode=="r"
if(mode=="w"||mode=="a"	then
if(cv~>modifiedButNotSaved==t	then
	hiDisplayAppDBox(
			?name		'warning2_generate_is
			?dboxBanner	"Generate IS for circuit"	
			?dboxText	"The cell is modified but not saved,please confirm whether to save!\n\nIf you want to generate IS,please save the cell and redo the generation!\n"
			?dialogType	hicInformationDialog
			?dialogStyle	'modeless
			?buttonLayout	'Close
			)
); end cv~>modifiedButNotSaved=="t"
if(cv~>modifiedButNotSaved==nil	then
	hiDisplayAppDBox(
			?name		'start_generate_is
			?dboxBanner	"Generate IS for circuit"	
			?dboxText	"Start generate IS.It may take a few minutes.Please wait...\n"
			?dialogType	hicInformationDialog
			?dialogStyle	'modeless
			?buttonLayout	'Close
			)
techname=techGetTechLibName(cv)
techid=techGetTechFile(cv)
if(techname!="WB18"	then	
hiDBoxOK(start_generate_is) 
	hiDisplayAppDBox(
			?name		'warning3_generate_is
			?dboxBanner	"Generate IS for circuit"	
			?dboxText	"The thchLib is not WB18.Generating fails!\n"
			?dialogType	hicInformationDialog
			?dialogStyle	'modeless
			?buttonLayout	'Close
			)	
);end if techid!="WB18"
if(techname=="WB18"	then
d1=ddGetObj(lib cell view)
if(d1 then ddDeleteObj(d1))
dbSave(cv lib cell view)
;save lswfile
lswfile=makeTempFileName("./WB18_tmp.lsw")
if(isFile(lswfile)	then	deleteFile(lswfile))
lswLayerSaveForm->lswFormAction->value = "File"
lswLayerSaveForm->filenameField->value = lswfile
hiFormDone(lswLayerSaveForm)

leSetAllLayerValid( t techid )
leSetAllLayerVisible( t techid )
leSetAllLayerSelectable( t techid )
geSelectAllFig( cv )
geDeleteSelSet()
inst1=dbCreateInstByMasterName(cv lib cell view nil list(0 0) "R0" 1)
dbFlattenInst(inst1 32 t)
leSetLayerSelectable( list("IS" "drawing") nil)
geSelectAllFig( cv )
geDeleteSelSet()
leSetLayerSelectable( list("IS" "drawing") t)
leSetLayerSelectable( list("y1" "drawing") t)
leSetLayerSelectable( list("y2" "drawing") t)
geSelectAllFig( cv )
fig=geGetSelectedSet( cv )
leMergeShapes(fig)
geSelectAllFig( cv )
fig=geGetSelectedSet( cv )
if(listp(fig)	then	fig=fig		else	fig=list(fig))
IS_hole=dbLayerHoles(cv "y1" fig)		;generate IS holes
IS_merge=dbLayerOr(cv  "y2" IS_hole fig)	;merge the IS and IS holes
dbCreateRect(cv list("y0" "drawing") list(lb_x:lb_y rt_x:rt_y))
geSelectAllFig( cv )
leLayerAndNot(cv list("y0" "drawing") list("y2" "drawing") list("IS" "drawing"))
geDeleteSelSet()
inst2=dbCreateInstByMasterName(cv lib cell view nil list(0 0) "R0" 1)
dbFlattenInst(inst2 1 t)
;dbSave(cv)
hiDBoxOK(start_generate_is) 
	hiDisplayAppDBox(
			?name		'end_generate_is
			?dboxBanner	"Generate IS for circuit"	
			?dboxText	"\nGenarating IS successfully!\n"
			?dialogType	hicInformationDialog
			?dialogStyle	'modeless
			?buttonLayout	'Close
			)
;load lswfile
if(isFile(lswfile)	then
lswLayerLoadForm->lswFormAction->value = "File"
lswLayerLoadForm->filenameField->value = lswfile
hiFormDone(lswLayerLoadForm)
)
deleteFile(lswfile)

);end if techid=="WB18"
);end cv~>modifiedButNotSaved=="nil"
);end if mode=="w"||mode=="a"
);end procedure

procedure(l_generate_ct_cb()
winid=getCurrentWindow()	cv=deGetCellView(winid)	
lib=cv~>libName		cell=cv~>cellName	view=cv~>viewName view1=strcat(cv~>viewName "_CSEC")
d1=ddGetObj(lib cell view1)
if(d1 then ddDeleteObj(d1))
mode=cv~>mode
if(mode=="r"	then
	hiDisplayAppDBox(
			?name		'warning1_generate_is
			?dboxBanner	"Generate IS for circuit"	
			?dboxText	"The cell is not writable,please open the cell in append/write mode\n"
			?dialogType	hicInformationDialog
			?dialogStyle	'modeless
			?buttonLayout	'Close
			)
);end if mode=="r"
if(mode=="w"||mode=="a"	then
if(cv~>modifiedButNotSaved==t	then
	hiDisplayAppDBox(
			?name		'warning2_generate_is
			?dboxBanner	"Generate IS for circuit"	
			?dboxText	"The cell is modified but not saved,please confirm whether save or not!\n\nIf you want to generate CT,please save the cell and redo the generation!\n"
			?dialogType	hicInformationDialog
			?dialogStyle	'modeless
			?buttonLayout	'Close
			)
); end cv~>modifiedButNotSaved=="t"
if(cv~>modifiedButNotSaved==nil	then
	hiDisplayAppDBox(
			?name		'start_generate_is
			?dboxBanner	"Generate CT for circuit"	
			?dboxText	"Start generate CT.It may take a few minutes.Please wait...\n"
			?dialogType	hicInformationDialog
			?dialogStyle	'modeless
			?buttonLayout	'Close
			)
techname=techGetTechLibName(cv)
techid=techGetTechFile(cv)

dbSave(cv lib cell view1)
for(flag 1 10
if(dbValidP(cv)	then	dbClose(cv))
)
winid1=deOpenCellView(lib cell view1 "maskLayout" list(list(0 0) list(1600 900)) "a")
cv1=deGetCellView(winid1)
;save lswfile
lswfile=makeTempFileName("./LSW_tmp")
if(isFile(lswfile)	then	deleteFile(lswfile))
lswLayerSaveForm->lswFormAction->value = "File"
lswLayerSaveForm->filenameField->value = lswfile
hiFormDone(lswLayerSaveForm)

leSetAllLayerValid( t techid )
leSetAllLayerVisible( t techid )
leSetAllLayerSelectable( t techid )
geSelectAllFig( cv1 )
geDeleteSelSet()
inst1=dbCreateInstByMasterName(cv1 lib cell view nil list(0 0) "R0" 1)
dbFlattenInst(inst1 32 t)
leSetLayerSelectable( list("M1" "drawing") nil)
geSelectAllFig( cv1 )
geDeleteSelSet()
leSetLayerSelectable( list("M1" "drawing") t)
geSelectAllFig( cv1 )
fig=geGetSelectedSet( cv1 )
leMergeShapes(fig)
leSetLayerSelectable( list("M1" "drawing") nil)

leLayerSize(cv list("M1" "drawing") -1 list("y0" "drawing"))
geSelectAllFig( cv1 )
fig=geGetSelectedSet( cv1 )
num=length(fig)
for(i 1 num
	I1=nthelem(i fig)
	bBox=I1~>bBox
	rodFillBBoxWithRects(
		?cvId		cv1
		?layer		"CT"
		?fillBBox	bBox
		?width		1
		?length		1
		?gap		"distribute"
		?spaceX		1
		?spaceY		1
		)
)
ivDRC(
	?cell	cv1
	?echo	nil
	?full	t		
;	?hier	
;	?optimize	
;	?inc	
;	?join	
;	?set	
;	?rsf	
;	?area	
	?rulesFromUnix	t
;	?rulesLibName	
	?rulesFilePath	"/home/wanglei/skill/Prog/Menu_test.rul"
)
geSelectAllFig( cv1 )
leLayerAndNot(cv1 list("CT" "drawing") list("marker" "error") list("CT" "drawing"))
geDeleteSelSet()
leSetAllLayerSelectable( nil techid )
leSetLayerSelectable( list("changedLayer" "tool0") t)
geSelectAllFig( cv1 )
geDeleteSelSet()

dbSave(cv1)
for(flag 1 10
if(dbValidP(cv1)	then	dbClose(cv1))
)

winid=deOpenCellView(lib cell view "maskLayout" list(list(0 0) list(500 600)) "a")
cv=deGetCellView(winid)
inst2=dbCreateInstByMasterName(cv lib cell view1 nil list(0 0) "R0" 1)
dbSave(cv)
hiDBoxOK(start_generate_is) 
	hiDisplayAppDBox(
			?name		'end_generate_ct
			?dboxBanner	"Generate CT for circuit"	
			?dboxText	"\nGenarating CT successfully!\n"
			?dialogType	hicInformationDialog
			?dialogStyle	'modeless
			?buttonLayout	'Close
			)
;load lswfile
if(isFile(lswfile)	then
lswLayerLoadForm->lswFormAction->value = "File"
lswLayerLoadForm->filenameField->value = lswfile
hiFormDone(lswLayerLoadForm)
)
deleteFile(lswfile)
);end cv~>modifiedButNotSaved=="nil"
);end if mode=="w"||mode=="a"
);end procedure

printf("//            CSEC Menu \n")

procedure(CSEC_Menu_prog(args)

l_display_bBox=hiCreateMenuItem(
			?name 'display_bBox
			?itemText "Display the Cell coordinate"
			?callback "l_display_bBox_cb()"
			)
l_mv_origin_center=hiCreateMenuItem(
			?name 'mv_origin_center
			?itemText "Move the origin to center"
			?callback "l_mv_origin_center_cb()"
			)
l_mv_origin_leftb=hiCreateMenuItem(
			?name 'mv_origin_leftb
			?itemText "Move the origin to leftbottom"
			?callback "l_mv_origin_leftb_cb()"
			)
l_generate_is=hiCreateMenuItem(
			?name 'generate_is
			?itemText "Generate IS for circuit"
			?callback "l_generate_is_cb()"
			)
l_generate_ct=hiCreateMenuItem(
			?name 'generate_ct
			?itemText "Generate CT for circuit"
			?callback "l_generate_ct_cb()"
			)
hiCreatePulldownMenu(
			'CSEC_Menu
			"CSEC Menu"
;			list(l_display_bBox l_mv_origin_center l_mv_origin_leftb l_generate_is l_generate_ct)
;			list(l_display_bBox l_mv_origin_center l_mv_origin_leftb l_generate_is)
			list(l_display_bBox l_mv_origin_center l_mv_origin_leftb)
			)
hiInsertBannerMenu(
			getCurrentWindow()
			CSEC_Menu
;			hiGetNumMenus(getCurrentWindow())+2
			12
			)
);end procedure
if(member('CSEC_Menu_prog deGetAppInfo("maskLayout")->userPostInstallTrigList)		then
_deUnRegUserTrigger("maskLayout" nil nil 'CSEC_Menu_prog)
)
deRegUserTriggers( 
	"maskLayout"
	nil
	nil
	'CSEC_Menu_prog	
)
