/**
 * @feature presideForms and rulesEngine
 */
component {

	public string function index( event, rc, prc, args={} ) {
		var context             = args.ruleContext ?: "webrequest";
		var multiple            = IsTrue( args.multiple ?: "" );
		var prefetchCacheBuster = CreateUUId();

		args.object        = "rules_engine_condition";
		args.labelrenderer = "rules_engine_condition";
		args.remoteUrl = event.buildAdminLink(
			  linkTo      = "rulesengine.getConditionsForAjaxSelectControl"
			, querystring = "context=#context#&q=%QUERY"
		);
		args.prefetchUrl = event.buildAdminLink(
			  linkTo      = "rulesengine.getConditionsForAjaxSelectControl"
			, querystring = "maxRows=100&prefetchCacheBuster=#prefetchCacheBuster#&context=#context#"
		);

		args.quickAdd  = IsTrue( args.quickAdd  ?: "" ) && hasCmsPermission( "rulesengine.add"  );
		args.quickEdit = IsTrue( args.quickEdit ?: "" ) && hasCmsPermission( "rulesengine.edit" );
		if ( args.quickAdd ) {
			args.quickAddUrl = event.buildAdminLink(
				  linkTo      = "rulesEngine.quickAddConditionForm"
				, querystring = "context=#context#&multiple=#multiple#&contextData=" & UrlEncodedFormat( SerializeJson( args.rulesEngineContextData ?: {} ) )
			);
		}
		if ( args.quickEdit ) {
			args.quickEditUrl = event.buildAdminLink(
				  linkTo      = "rulesEngine.quickEditConditionForm"
				, querystring = "context=#context#&multiple=#multiple#&id="
			);
		}

		return renderViewlet( event="formcontrols.objectPicker.index", args=args );
	}
}