<!---@feature admin and formbuilder--->
<cfscript>
	theForm    = prc.form ?: QueryNew( '' );
	formId     = theForm.id;
	canDelete  = prc.canDelete = hasCmsPermission( "formbuilder.deleteSubmissions" );
	v2Form     = isTrue( theForm.uses_global_questions ?: "" );
	gridFields = [ "datecreated", "form_instance", "submitted_data" ];
	if ( isFeatureEnabled( "websiteUsers" ) ) {
		ArrayPrepend( gridFields, "submitted_by" );
	}
</cfscript>

<cfoutput>
	#renderViewlet( event="admin.formbuilder.statusControls", args=QueryRowToStruct( theForm ) )#
	#renderViewlet( event="admin.formbuilder.removalAlert", args=QueryRowToStruct( theForm ) )#

	<div class="tabbable">
		#renderViewlet( event="admin.formbuilder.managementTabs", args={ activeTab="submissions" } )#

		<div class="tab-content">
			<div class="tab-pane active">
				#renderView( view="/admin/datamanager/_objectDataTable", args={
					  objectName        = "formbuilder_formsubmission"
					, id                = "formbuilder_formsubmission-" & formId
					, useMultiActions   = canDelete
					, multiActionUrl    = event.buildAdminLink( linkTo='formbuilder.deleteSubmissionsAction', querystring="formId=#formId#" )
					, datasourceUrl     = event.buildAdminLink( linkTo='formbuilder.listSubmissionsForAjaxDataTable', querystring="formId=#formId#" )
					, gridFields        = gridFields
					, allowSearch       = true
					, filterContextData = { formId=formId }
					, excludeFilterExpressionTags = v2Form ? "formbuilderV1Form" : "formbuilderV2Form"
				} )#
			</div>
		</div>
	</div>
</cfoutput>