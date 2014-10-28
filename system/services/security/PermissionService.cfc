component output=false singleton=true {

// CONSTRUCTOR
	/**
	 * @loginService.inject       LoginService
	 * @cacheProvider.inject      cachebox:PermissionsCache
	 * @permissionsConfig.inject  coldbox:setting:adminPermissions
	 * @rolesConfig.inject        coldbox:setting:adminRoles
	 * @groupDao.inject           presidecms:object:security_group
	 * @userDao.inject            presidecms:object:security_user
	 * @contextPermDao.inject     presidecms:object:security_context_permission
	 */
	public any function init(
		  required any    loginService
		, required any    cacheProvider
		, required struct permissionsConfig
		, required struct rolesConfig
		, required any    groupDao
		, required any    userDao
		, required any    contextPermDao
	) output=false {
		_setLoginService( arguments.loginService );
		_setCacheProvider( arguments.cacheProvider )
		_setGroupDao( arguments.groupDao );
		_setUserDao( arguments.userDao );
		_setContextPermDao( arguments.contextPermDao );

		_denormalizeAndSaveConfiguredRolesAndPermissions( arguments.permissionsConfig, arguments.rolesConfig );

		return this;
	}

// PUBLIC API METHODS
	public array function listRoles() output=false {
		return _getRoles().keyArray();
	}

	public array function listPermissionKeys( string role="", string group="", string user="", array filter=[] ) output=false {
		if ( Len( Trim( arguments.role ) ) ) {
			return _getRolePermissions( arguments.role );

		} elseif ( Len( Trim( arguments.group ) ) ) {
			return _getGroupPermissions( arguments.group );

		} elseif ( Len( Trim( arguments.user ) ) ) {
			return _getUserPermissions( arguments.user );
		} elseif ( arguments.filter.len() ) {
			return _filterPermissions( arguments.filter );
		}

		return _getPermissions();
	}

	public boolean function hasPermission(
		  required string permissionKey
		,          string context       = ""
		,          array  contextKeys   = []
		,          string userId        = _getLoginService().getLoggedInUserId()
	) output=false {

		if ( arguments.userId == _getLoginService().getLoggedInUserId() && _getLoginService().isSystemUser() ) {
			return true;
		}

		if ( Len( Trim( arguments.context ) ) && arguments.contextKeys.len() ) {
			var contextPerm = _getContextPermission( argumentCollection=arguments );
			if ( !IsNull( contextPerm ) && IsBoolean( contextPerm ) ) {
				return contextPerm;
			}
		}


		return listPermissionKeys( user=arguments.userId ).find( arguments.permissionKey );
	}

	public array function listUserGroups( required string userId ) output=false {
		var groups = _getUserDao().selectManyToManyData(
			  propertyName = "groups"
			, id           = arguments.userId
			, selectFields = [ "security_group" ]
		);

		return ListToArray( ValueList( groups.security_group ) );
	}

	public struct function getContextPermissions(
		  required string  context
		, required array   contextKeys
		, required array   permissionKeys
		,          boolean includeDefaults=false
	) output=false {
		var expandedPermissionKeys = listPermissionKeys( filter=permissionKeys );
		var contextPerms           = {};
		var dbData                 = "";

		for( var key in expandedPermissionKeys ){
			contextPerms[ key ] = {
				  granted = []
				, denied  = []
			};
		}

		if ( arguments.contextKeys.len() ) {
			dbData = _getContextPermDao().selectData(
				  selectFields = [ "granted", "permission_key", "security_group", "security_group.label as group_name" ]
				, filter       = {
					  context        = arguments.context
					, context_key    = arguments.contextKeys
					, permission_key = expandedPermissionKeys.sort( "textnocase" )
				  }
			);

			for( var record in dbData ){
				if ( record.granted ) {
					contextPerms[ record.permission_key ].granted.append( { id=record.security_group, name=record.group_name } );
				} else {
					contextPerms[ record.permission_key ].denied.append( { id=record.security_group, name=record.group_name } );
				}
			}
		}


		if ( arguments.includeDefaults ) {
			for( key in contextPerms ) {
				_getDefaultGroupsForPermission( permissionKey=key ).each( function( group ){
					if ( !contextPerms[ key ].granted.find( group ) ) {
						contextPerms[ key ].granted.append( group );
					}
				} );
			}
		}

		return contextPerms;
	}

	public boolean function syncContextPermissions( required string context, required string contextKey, required string permissionKey, required array grantedToGroups, required array deniedToGroups ) output=false {
		transaction {
			_getContextPermDao().deleteData(
				filter = {
					  context        = arguments.context
					, context_key    = arguments.contextKey
					, permission_key = arguments.permissionKey
				}
			);

			for( var group in arguments.grantedToGroups ){
				_getContextPermDao().insertData(
					data = {
						  context        = arguments.context
						, context_key    = arguments.contextKey
						, permission_key = arguments.permissionKey
						, security_group = group
						, granted        = true
					}
				);
			}

			for( var group in arguments.deniedToGroups ){
				_getContextPermDao().insertData(
					data = {
						  context        = arguments.context
						, context_key    = arguments.contextKey
						, permission_key = arguments.permissionKey
						, security_group = group
						, granted        = false
					}
				);
			}

			_getCacheProvider().clear( "Context perms for context: " & arguments.context );
		}

		return true;
	}

// PRIVATE HELPERS
	private void function _denormalizeAndSaveConfiguredRolesAndPermissions( required struct permissionsConfig, required struct rolesConfig ) output=false {
		_setPermissions( _expandPermissions( arguments.permissionsConfig ) );
		_setRoles( _expandRoles( arguments.rolesConfig ) );
	}

	private array function _getRolePermissions( required string role ) output=false {
		var roles = _getRoles();

		return roles[ arguments.role ] ?: [];
	}

	private array function _getGroupPermissions( required string group ) output=false {
		var roles = _getGroupDao().selectData( id=arguments.group, selectFields=[ "roles" ] );
		var perms = [];

		if ( !roles.recordCount ) {
			return [];
		}
		for( var role in ListToArray( roles.roles ) ){
			_getRolePermissions( role ).each( function( perm ){
				if ( !perms.find( perm ) ) {
					perms.append( perm );
				}
			} );
		}

		return perms;
	}

	private array function _getUserPermissions( required string user ) output=false {
		var perms = [];
		var groups = listUserGroups( arguments.user );

		for( var group in groups ){
			_getGroupPermissions( group ).each( function( perm ){
				if ( !perms.find( perm ) ) {
					perms.append( perm );
				}
			} );
		}

		return perms;
	}

	private array function _filterPermissions( required array filter ) output=false {
		var filtered   = [];
		var exclusions = [];
		var allPerms   = _getPermissions();

		for( var permissionKey in filter ){
			if ( IsSimpleValue( permissionKey ) ) {
				if ( Left( permissionKey, 1 ) == "!" ) {
					exclusions.append( ReReplace( permissionKey, "^!(.*)$", "\1" ) );

				} elseif ( permissionKey contains "*" ) {
					( _expandWildCardPermissionKey( permissionKey ) ).each( function( expandedKey ){
						if ( !filtered.findNoCase( expandedKey ) ) {
							filtered.append( expandedKey );
						}
					} );
				} elseif ( allPerms.findNoCase( permissionKey ) && !filtered.findNoCase( permissionKey ) ) {
					filtered.append( permissionKey );
				}
			}
		}

		for( var exclusion in exclusions ){
			if ( exclusion contains "*" ) {
				( _expandWildCardPermissionKey( exclusion ) ).each( function( expandedKey ){
					filtered.delete( expandedKey );
				} );
			} else {
				filtered.delete( exclusion );
			}
		}

		return filtered;
	}

	private any function _getContextPermission(
		  required string userId
		, required string permissionKey
		, required string context
		, required array  contextKeys
	) {
		var cacheKey           = "Context perms for context: " & arguments.context;
		var cntext             = arguments.context;
		var cachedContextPerms = _getCacheProvider().getOrSet( objectKey=cacheKey, produce=function(){
			var permsToCache = {};
			var permsFromDb  = _getContextPermDao().selectData(
				  selectFields = [ "granted", "context_key", "permission_key", "security_group" ]
				, filter       = { context = cntext }
			);

			for( var perm in permsFromDb ){
				permsToCache[ perm.context_key & "_" & perm.permission_key & "_" & perm.security_group ] = perm.granted;
			}

			return permsToCache;
		} );

		for( var key in arguments.contextKeys ){
			var perm = NullValue();

			for( var group in listUserGroups( arguments.userId ) ){
				cacheKey = key & "_" & arguments.permissionKey & "_" & group;
				if ( StructKeyExists( cachedContextPerms, cacheKey ) ) {
					perm = cachedContextPerms[ cacheKey ];
					if ( perm ) {
						return perm;
					}
				}
			}

			if ( !IsNull( perm ) ) {
				return perm;
			}
		}

		return NullValue();
	}

	private array function _expandPermissions( required struct permissions, string prefix="" ) output=false {
		var expanded = [];

		for( var perm in permissions ){
			var newPrefix = ListAppend( arguments.prefix, perm, "." );

			if ( IsStruct( permissions[ perm ] ) ) {
				var childPerms = _expandPermissions( permissions[ perm ], newPrefix );
				for( var childPerm in childPerms ){
					expanded.append( childPerm );
				}
			} elseif ( IsArray( permissions[ perm ] ) ) {
				for( var key in permissions[ perm ] ) {
					if ( IsSimpleValue( key ) ) {
						expanded.append( ListAppend( newPrefix, key, "." ) );
					}
				}
			}
		}

		return expanded;
	}

	private struct function _expandRoles( required struct roles ) output=false {
		var expandedRoles = StructNew( "linked" );

		for( var roleName in arguments.roles ){
			var role = arguments.roles[ roleName ];
			var exclusions = [];

			expandedRoles[ roleName ] = [];

			if ( IsArray( role ) ) {
				expandedRoles[ roleName ] = listPermissionKeys( filter=role );
			}
		}

		return expandedRoles;
	}

	private array function _expandWildCardPermissionKey( required string permissionKey ) output=false {
		var regex       = Replace( _reEscape( arguments.permissionKey ), "\*", "(.*?)", "all" );
		var permissions = _getPermissions();

		return permissions.filter( function( permKey ){
			return ReFindNoCase( regex, permKey );
		} );
	}

	private string function _reEscape( required string stringToEscape ) output=false {
		var charsToEscape = [ "\", "$","{","}","(",")","<",">","[","]","^",".","*","+","?","##",":","&" ];
		var escaped       = arguments.stringToEscape;

		for( var char in charsToEscape ){
			escaped = Replace( escaped, char, "\" & char, "all" );
		}

		return escaped;
	}

	private array function _getDefaultGroupsForPermission( required string permissionKey ) output=false {
		var roles         = _getRoles();
		var rolesWithPerm = {};
		var groups        = [];

		for( var role in roles ){
			if ( roles[ role ].find( arguments.permissionKey ) ) {
				rolesWithPerm[ role ] = 1;
			}
		}

		if ( StructCount( rolesWithPerm ) ) {
			var allGroups = _getGroupDao().selectData(
				selectFields = [ "id", "label", "roles" ]
			);

			for( var group in allGroups ){
				for ( var role in ListToArray( group.roles ) ) {
					if ( rolesWithPerm.keyExists( role ) ) {
						groups.append( { id=group.id, name=group.label } );
						break;
					}
				}
			}
		}

		return groups;
	}

// GETTERS AND SETTERS
	private struct function _getRoles() output=false {
		return _roles;
	}
	private void function _setRoles( required struct roles ) output=false {
		_roles = arguments.roles;
	}

	private array function _getPermissions() output=false {
		return _permissions;
	}
	private void function _setPermissions( required array permissions ) output=false {
		_permissions = arguments.permissions;
	}

	private any function _getLoginService() output=false {
		return _loginService;
	}
	private void function _setLoginService( required any loginService ) output=false {
		_loginService = arguments.loginService;
	}

	private any function _getCacheProvider() output=false {
		return _cacheProvider;
	}
	private void function _setCacheProvider( required any cacheProvider ) output=false {
		_cacheProvider = arguments.cacheProvider;
	}

	private any function _getGroupDao() output=false {
		return _groupDao;
	}
	private void function _setGroupDao( required any groupDao ) output=false {
		_groupDao = arguments.groupDao;
	}

	private any function _getUserDao() output=false {
		return _userDao;
	}
	private void function _setUserDao( required any userDao ) output=false {
		_userDao = arguments.userDao;
	}

	private any function _getContextPermDao() output=false {
		return _contextPermDao;
	}
	private void function _setContextPermDao( required any contextPermDao ) output=false {
		_contextPermDao = arguments.contextPermDao;
	}
}