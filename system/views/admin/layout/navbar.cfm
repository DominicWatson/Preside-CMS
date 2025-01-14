<!---@feature admin--->
<cfscript>
	systemMenu        = renderView( "/admin/layout/systemMenu" );
	userMenu          = renderView( "/admin/layout/userMenu" );
	applicationNav    = renderViewlet( event="admin.layout.applicationNav" );
	sitePicker        = renderViewlet( "admin.sites.sitePicker" );
	notificationsMenu = renderViewlet( "admin.notifications.notificationNavPromo" );
	systemAlertsMenu  = renderViewlet( "admin.systemAlerts.systemAlertsMenuItem" );
	helpAndSupport    = renderView( "/admin/layout/helpAndSupportMenu" );
</cfscript>

<cfoutput>
	<div class="navbar navbar-default" id="navbar">
		<script type="text/javascript">
			try{ace.settings.check( 'navbar', 'fixed' );}catch(e){}
		</script>

		<div class="navbar-container" id="navbar-container">
			#applicationNav#
			#sitePicker#

			<div class="navbar-header pull-right" role="navigation">
				<ul class="nav ace-nav">
					#systemAlertsMenu#

					<li>#notificationsMenu#</li>
					<li>#userMenu#</li>

					<cfif Len( Trim( systemMenu ) )>
						<li>#systemMenu#</li>
					</cfif>

					<li>#helpAndSupport#</li>
				</ul>
			</div>
		</div>
	</div>
</cfoutput>