<!---@feature admin and customEmailTemplates--->
<cfoutput>
	#outputView( view="/admin/datamanager/_addRecordForm", args={
		  objectName            = "email_template"
		, addRecordAction       = event.buildAdminLink( linkTo='emailCenter.customTemplates.addAction' )
		, cancelAction          = event.buildAdminLink( linkTo='emailCenter.customTemplates' )
		, draftsEnabled         = true
		, canPublish            = false
		, canSaveDraft          = IsTrue( prc.canSaveDraft ?: "" )
		, allowAddAnotherSwitch = true
		, additionalArgs        = prc.additionalFormArgs ?: {}
	} )#
</cfoutput>