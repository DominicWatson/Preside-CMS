/**
 * @presideService true
 * @singleton      true
 *
 */
component {

	/**
	 * @controller.inject coldbox
	 *
	 */
	public any function init() {
		_initSticker();

		return this;
	}

	public any function addBundle()      { return _getSticker().addBundle     ( argumentCollection=arguments ); }
	public any function load()           { return _getSticker().load          ( argumentCollection=arguments ); }
	public any function ready()          { return _getSticker().ready         ( argumentCollection=arguments ); }
	public any function getAssetUrl()    { return _getSticker().getAssetUrl   ( argumentCollection=arguments ); }
	public any function include()        { return _getSticker().include       ( argumentCollection=arguments ); }
	public any function includeData()    { return _getSticker().includeData   ( argumentCollection=arguments ); }
	public any function renderIncludes() { return _getSticker().renderIncludes( argumentCollection=arguments ); }

// PRIVATE HELPERS
	private void function _initSticker() {
		var sticker           = new sticker.Sticker();
		var settings          = $getColdbox().getSettingStructure();
		var sysAssetsPath     = "/preside/system/assets/"
		var extensionsRootUrl = "/preside/system/assets/extension/";
		var siteAssetsPath    = settings.static.siteAssetsPath ?: "/assets";
		var siteAssetsUrl     = settings.static.siteAssetsUrl  ?: "/assets";
		_setRootUrl();
		var rootUrl = Len( settings.static.rootUrl ) ? settings.static.rootUrl : _getRootUrl();

		sticker.addBundle( rootDirectory=sysAssetsPath , rootUrl=sysAssetsPath          , config=settings )
		       .addBundle( rootDirectory=siteAssetsPath, rootUrl=rootUrl & siteAssetsUrl, config=settings );

		for( var ext in settings.activeExtensions ) {
			var stickerDirectory  = ( ext.directory ?: "" ) & "/assets";
			var stickerBundleFile = stickerDirectory & "/StickerBundle.cfc";

			if ( FileExists( stickerBundleFile ) ) {
				sticker.addBundle( rootDirectory=stickerDirectory, rootUrl=extensionsRootUrl & ListLast( ext.directory, "\/" ) & "/assets" );
			}
		}

		sticker.load();

		_setSticker( sticker );
	}

// GETTERS AND SETTERS
	private any function _getSticker() {
		return _sticker;
	}
	private void function _setSticker( required any sticker ) {
		_sticker = arguments.sticker;
	}

	private any function _getRootUrl() {
		return _rootUrl;
	}
	private string function _setRootUrl() {
		var appSettings = getApplicationSettings();

		rootUrl = request._presideMappings.appBasePath;
		if ( Len(rootUrl) ) {

			if ( right(rootUrl, 1) == "/" ) {
				rootUrl = left( rootUrl, len(rootUrl) - 1 );
			}

			if ( left(rootUrl, 1) != "/" ) {
				rootUrl ="/" & rootUrl;
			}

		}

		_rootUrl = rootUrl;
	}

}