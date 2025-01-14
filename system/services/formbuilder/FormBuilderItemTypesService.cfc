/**
 * Provides logic around interacting with configured form builder item types
 *
 * @singleton      true
 * @presideservice true
 * @autodoc        true
 * @feature        formbuilder
 */
component {

// CONSTRUCTOR
	/**
	 * @configuredTypesAndCategories.inject coldbox:setting:formbuilder.itemtypes
	 * @formsService.inject                 formsService
	 */
	public any function init( required struct configuredTypesAndCategories, required any formsService ) {
		_setConfiguredTypesAndCategories( arguments.configuredTypesAndCategories );
		_setFormsService( arguments.formsService );

		return this;
	}

// PUBLIC API
	/**
	 * Returns configuration struct for the given item type
	 *
	 * @autodoc
	 * @itemType.hint the item type whose configuration you wish to retrieve
	 */
	public struct function getItemTypeConfig( required string itemType ) {
		var cachedConfigurations = _getCachedItemTypeConfiguration();

		if ( !StructKeyExists( cachedConfigurations, arguments.itemType ) ) {
			var configured                = _getConfiguredTypesAndCategories();
			var standardFormFieldFormName = "formbuilder.item-types.formfield";
			var found                     = false;

			for( var categoryId in configured ) {
				var types = configured[ categoryId ].types ?: {};

				for( var typeId in types ) {
					if ( typeId == itemType ) {
						var type = types[ typeId ];

						type.id                      = typeId;
						type.title                   = $translateResource( uri="formbuilder.item-types.#typeId#:title", defaultValue=typeId );
						type.iconClass               = $translateResource( uri="formbuilder.item-types.#typeId#:iconclass", defaultValue="fa-square" );
						type.isFormField             = IsBoolean( type.isFormField ?: "" ) ? type.isFormField : true;
						type.isFileUploadField       = IsBoolean( type.isFileUploadField ?: "" ) ? type.isFileUploadField : false;
						type.baseConfigFormName      = "formbuilder.item-types.#typeid#";
						type.configFormExists        = _getFormsService().formExists( type.baseConfigFormName );
						type.adminPlaceholderViewlet = "formbuilder.item-types.#type.id#.adminPlaceholder";
						type.requiresConfiguration   = type.isFormField || type.configFormExists;

						if ( type.requiresConfiguration ) {
							if ( type.configFormExists && type.isFormField ) {
								type.configFormName = _getFormsService().getMergedFormName(
									  formName          = standardFormFieldFormName
									, mergeWithFormName = type.baseConfigFormName
								);
							} else if ( type.isFormField ) {
								type.configFormName = standardFormFieldFormName;
							} else {
								type.configFormName = type.baseConfigFormName;
							}
						} else {
							type.baseConfigFormName = "";
							type.configFormName     = "";
						}

						if ( !$getColdbox().viewletExists( type.adminPlaceholderViewlet ) ) {
							type.adminPlaceholderViewlet = "";
						}

						cachedConfigurations[ arguments.itemType ] = type;
						found = true;
						break;
					}
				}

				if ( found ) {
					break;
				}
			}

			if ( !found ) {
				cachedConfigurations[ arguments.itemType ] = {};
			}

			_setCachedItemTypeConfiguration( cachedConfigurations );
		}

		return cachedConfigurations[ arguments.itemType ];
	}

	/**
	 * Returns an array of item types which are identified as being
	 * file upload types.
	 *
	 * @autodoc
	 */
	public array function getFileUploadItemTypes() {
		var cachedTypes = _getCachedFileUploadItemTypes();

		if ( IsNull( cachedTypes ) ) {
			var configured      = _getConfiguredTypesAndCategories();
			var fileUploadTypes = [];

			for( var categoryId in configured ) {
				var types = configured[ categoryId ].types ?: {};

				for( var typeId in types ) {
					var type = types[ typeId ];

					if ( IsBoolean( type.isFileUploadField ?: "" ) && type.isFileUploadField ) {
						ArrayAppend( fileUploadTypes, typeId );
					}
				}
			}
			_setCachedFileUploadItemTypes( fileUploadTypes );
			return fileUploadTypes;
		}

		return cachedTypes;
	}

	/**
	 * Returns an array of item categories each with child
	 * item types. Categories ordered by defined sort order
	 * and item types ordered by defined sort order
	 *
	 * @autodoc
	 */
	public array function getItemTypesByCategory() {
		var configured = _getConfiguredTypesAndCategories();
		var categories = [];

		for( var categoryId in configured ) {
			var category = {
				  id        = categoryId
				, title     = $translateResource( uri="formbuilder.item-categories:#categoryId#.title", defaultValue=categoryId )
				, types     = []
			};
			var types = configured[ categoryId ].types ?: {};

			for( var typeId in types ) {
				var type = getItemTypeConfig( typeId );

				category.types.append( type );
			}

			category.types.sort( function( a, b ){
				return a.title > b.title ? 1 : -1;
			} );

			categories.append( category );
		}

		categories.sort( function( a, b ){
			var orderA = configured[ a.id ].sortOrder ?: 10000;
			var orderB = configured[ b.id ].sortOrder ?: 10000;

			return orderA > orderB ? 1 : -1;
		} );

		return categories;
	}

	/**
	 * Returns the configuration form name for the given item
	 * type. If the item type is a form field, this form will
	 * be a combination of the core formfield form + any custom
	 * configuration for the item type itself.
	 *
	 * Returns an empty string when not a form field and when
	 * no configuration exists.
	 *
	 * @autodoc
	 * @itemType.hint The item type whose config form name you wish to retrieve
	 *
	 */
	public string function getConfigFormNameForItemType( required string itemType ) {
		var itemTypeConfig = getItemTypeConfig( arguments.itemType );

		return itemTypeConfig.configFormName ?: "";
	}

	public void function clearCachedItemTypeConfig() {
		_setCachedItemTypeConfiguration( {} );
	}

// GETTERS AND SETTERS
	private struct function _getConfiguredTypesAndCategories() {
		return _configuredTypesAndCategories;
	}
	private void function _setConfiguredTypesAndCategories( required struct configuredTypesAndCategories ) {
		_configuredTypesAndCategories = arguments.configuredTypesAndCategories;
	}

	private any function _getFormsService() {
		return _formsService;
	}
	private void function _setFormsService( required any formsService ) {
		_formsService = arguments.formsService;
	}

	private struct function _getCachedItemTypeConfiguration() {
		return _cachedItemTypeConfiguration ?: {};
	}
	private void function _setCachedItemTypeConfiguration( required struct cachedItemTypeConfiguration ) {
		_cachedItemTypeConfiguration = arguments.cachedItemTypeConfiguration;
	}

	private any function _getCachedFileUploadItemTypes() {
		return _cachedFileUploadItemTypes ?: NullValue();
	}
	private void function _setCachedFileUploadItemTypes( required array cachedFileUploadItemTypes ) {
		_cachedFileUploadItemTypes = arguments.cachedFileUploadItemTypes;
	}

}