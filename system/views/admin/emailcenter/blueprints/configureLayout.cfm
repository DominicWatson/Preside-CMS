<!---@feature admin and emailCenter--->
<cfscript>
	configForm = prc.configForm ?: "";
</cfscript>
<cfoutput>
	<cfsavecontent variable="body">
		<p class="alert alert-info">
			<i class="fa fa-fw fa-info-circle"></i>
			#translateResource( "cms:emailcenter.systemTemplates.configureLayout.override.explanation" )#
		</p>

		#configForm#
	</cfsavecontent>

	#renderViewlet( event="admin.emailcenter.blueprints._blueprintTabs", args={ body=body, tab="layout" } )#
</cfoutput>