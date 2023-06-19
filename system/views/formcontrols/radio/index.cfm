<cfscript>
	inputName      = args.name            ?: "";
	inputId        = args.id              ?: "";
	inputClass     = args.class           ?: "";
	values         = args.values          ?: "";
	defaultValue   = args.defaultValue    ?: "";
	extraClasses   = args.extraClasses    ?: "";
	values         = args.values          ?: "";
	labels         = len( args.labels )   ?  args.labels : args.values;

	if ( IsSimpleValue( values ) ) { values = ListToArray( values ); }
	if ( IsSimpleValue( labels ) ) { labels = ListToArray( labels ); }

	value = event.getValue( name=inputName, defaultValue=defaultValue );
	if ( !IsSimpleValue( value ) ) {
		value = "";
	}

	value = HtmlEditFormat( value );
	valueFound = false;

	htmlAttributes = renderForHTMLAttributes( htmlAttributeNames=( args.htmlAttributeNames ?: "" ), htmlAttributeValues=( args.htmlAttributeValues ?: "" ), htmlAttributePrefix=( args.htmlAttributePrefix ?: "data-" ) );
</cfscript>

<cfoutput>
	<cfloop array="#values#" index="i" item="selectValue">
		<cfset checked    = ListFindNoCase( value, selectValue ) />
		<cfset valueFound = valueFound || checked />
		<cfset elementId  = inputId & "_" & i />

		<div class="radio">
			<label>
				<input type="radio"
				   id="#elementId#"
				   name="#inputName#"
				   value="#HtmlEditFormat( selectValue )#"
				   class="#inputClass# #extraClasses#"
				   tabindex="#getNextTabIndex()#"
				   <cfif checked>checked</cfif>>
				   #HtmlEditFormat( translateResource( labels[i] ?: "", labels[i] ?: "" ) )#
				   #htmlAttributes#
			</label>
		</div>
	</cfloop>
	<label for="#inputName#" class="error"></label>
</cfoutput>
