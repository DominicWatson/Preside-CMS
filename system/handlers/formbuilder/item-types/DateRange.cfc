component {

	private string function renderInput( event, rc, prc, args={} ) {

		var name = args.name   ?: "";
		event.include( assetId="/css/admin/frontend/" );
		event.include( assetId="/js/frontend/formbuilder/datePicker/" );
		return renderFormControl(
			  argumentCollection = arguments
			, name               = "from"
			, toDate   			 = "to"
			, type               = "DateRangepicker"
			, context            = "formbuilder"
			, fromDateID         = args.id ?: fromDate
			, layout             = ""
			, required           = IsTrue( args.mandatory ?: "" )
		);
	}

	private array function getValidationRules( event, rc, prc, args={} ) {
		var rules = [];
		if ( IsBoolean( args.mandatory ?: "" ) && args.mandatory ) {
			var fields = listToArray("from,to");
	        for( var i=1; i <= fields.len(); i++ ) {
	       		rules.append({ fieldname=fields[i], validator="required" });
	       	}
	    }
	    return rules;
	}

	private any function getItemDataFromRequest( event, rc, prc, args={} ) {
	    var inputName = args.inputName ?: "";
	    var dateFrom  = rc[ "from" ] ?: "";
	    var dateTo    = rc[ "to" ] ?: "";

	    if ( IsDate( dateFrom ) && IsDate( dateTo ) ) {
	    	return SerializeJson( { from=dateFrom, to=dateTo } );
	    }

	    return "";
	}

	private string function renderResponse( event, rc, prc, args={} ) {
		var response = IsJson( args.response ?: "" ) ? DeserializeJson( args.response ) : {};
		var dateFrom = IsDate( response.from ?: "" ) ? DateFormat( response.from, "yyyy-mm-dd" ) : "";
		var dateTo   = IsDate( response.to   ?: "" ) ? DateFormat( response.to  , "yyyy-mm-dd" ) : "";

		return renderView( view="/formbuilder/item-types/daterange/renderResponse", args={ dateFrom=dateFrom, dateTo=dateTo } );
	}

	private array function renderResponseForExport( event, rc, prc, args={} ) {
		var response = IsJson( args.response ?: "" ) ? DeserializeJson( args.response ) : {};
		var dateFrom = IsDate( response.from ?: "" ) ? DateFormat( response.from, "yyyy-mm-dd" ) : "";
		var dateTo   = IsDate( response.to   ?: "" ) ? DateFormat( response.to  , "yyyy-mm-dd" ) : "";

		return [ dateFrom, dateTo ];
	}

	private array function getExportColumns( event, rc, prc, args={} ) {
		var fieldLabel  = args.label ?: "";
		var fromColumn  = translateResource( uri="formbuilder.item-types.daterange:date.from.column.name", data=[ fieldLabel ]);
		var toColumn    = translateResource( uri="formbuilder.item-types.daterange:date.to.column.name"  , data=[ fieldLabel ]);

		return [ fromColumn, toColumn ];
	}
}