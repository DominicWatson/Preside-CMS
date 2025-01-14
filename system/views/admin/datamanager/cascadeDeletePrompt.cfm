<!---@feature admin--->
<cfscript>
	objectName          = rc.object        ?: "";
	id                  = prc.id           ?: "";
	blockers            = prc.blockers     ?: [];
	postActionUrl       = Trim( rc.postActionUrl ?: "" );
	cancelUrl           = Trim( rc.cancelUrl ?: "" );
	objectTitleSingular = translateResource( uri="preside-objects.#objectName#:title.singular", defaultValue=objectName );
	objectTitlePural    = translateResource( uri="preside-objects.#objectName#:title", defaultValue=objectName );

	cancelLink = cancelUrl.len() ? cancelUrl : event.buildAdminLink( objectName=objectName, recordId=id, operation="viewRecord" );
</cfscript>

<cfoutput>
	<p>#translateResource( uri="cms:datamanager.cascadeDelete.intro", data=[ "<strong>#objectTitlePural#</strong>" ] )#</p>

	<div class="row">
		<div class="col-sm-4">
			<div class="well">
				<h4 class="small lighter red header">
					<i class="fa fa-ban-circle"></i> &nbsp;
					#translateResource( uri="cms:datamanager.cascadeDelete.blockingObjects.title" )#
				</h4>
				<ul class="list-unstyled">
					<cfloop array="#blockers#" index="blocker">
						<li>
							<i class="fa fa-database"></i>

							#translateResource( "preside-objects.#blocker.objectName#:title" )#, #translateResource( uri="cms:datamanager.x.related.records", data=[blocker.recordcount] )#
						</li>
					</cfloop>
				</ul>
			</div>
		</div>

		<div class="col-sm-8">
			<div class="well">
				<h4 class="small lighter blue header">
					<i class="fa fa-thumbs-up"></i> &nbsp;
					#translateResource( uri="cms:datamanager.cascadeDelete.options.title" )#
				</h4>

				<a class="inline" href="#cancelLink#">
					<button class="btn btn-primary btn-sm">
						<i class="fa fa-arrow-left"></i>
						#translateResource( uri="cms:datamanager.cascadeDelete.cancel.btn" )#
					</button>
				</a>

				<form class="inline" action="#event.buildAdminLink( objectName=objectName, recordId=id, operation='deleteRecordAction' )#" method="post">
					<input type="hidden" name="forceDelete" value="1" />
					<cfif postActionUrl.len()>
						<input type="hidden" name="postActionUrl" value="#HtmlEditFormat( postActionUrl )#" />
					</cfif>

					<button type="submit" class="btn btn-danger btn-sm confirmation-prompt" title="#translateResource( 'cms:datamanager.cascadeDelete.final.warning' )#">
						<i class="fa fa-trash-o"></i>
						#translateResource( uri="cms:datamanager.cascadeDelete.force.btn" )#
					</button>
				</form>
			</div>
		</div>
	</div>
</cfoutput>