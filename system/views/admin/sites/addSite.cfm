<!---@feature admin and sites--->
<cfoutput>
	#outputView( view="/admin/datamanager/_addRecordForm", args={
		  objectName            = "site"
		, addRecordAction       = event.buildAdminLink( linkTo='sites.addSiteAction' )
		, cancelAction          = event.buildAdminLink( linkTo='sites.manage' )
		, allowAddAnotherSwitch = false
	} )#
</cfoutput>