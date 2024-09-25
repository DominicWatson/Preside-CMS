<!---@feature admin and rulesEngine--->
<cfset contextId = rc.context ?: "" />

<cfoutput>
	#outputView( view="/admin/datamanager/_addRecordForm", args={
		  objectName            = "rules_engine_condition"
		, addRecordAction       = event.buildAdminLink( linkTo='rulesEngine.addConditionAction' )
		, allowAddAnotherSwitch = true
		, cancelAction          = event.buildAdminLink( linkTo='rulesEngine' )
	} )#
</cfoutput>