<!---@feature admin--->
<cfscript>
	prc.pageIcon  = "group";
	prc.pageTitle = translateResource( "cms:usermanager.addGroup.page.title" );
</cfscript>

<cfoutput>
	#outputView( view="/admin/datamanager/_addRecordForm", args={
		  objectName            = "security_group"
		, addRecordAction       = event.buildAdminLink( linkTo='usermanager.addGroupAction' )
		, allowAddAnotherSwitch = true
		, cancelAction          = event.buildAdminLink( linkTo='usermanager.groups' )
	} )#
</cfoutput>