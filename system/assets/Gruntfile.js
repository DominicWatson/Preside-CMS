module.exports = function( grunt ) {

	grunt.loadNpmTasks( 'grunt-contrib-clean' );
	grunt.loadNpmTasks( 'grunt-contrib-cssmin' );
	grunt.loadNpmTasks( 'grunt-contrib-less' );
	grunt.loadNpmTasks( 'grunt-contrib-rename' );
	grunt.loadNpmTasks( 'grunt-contrib-uglify' );
	grunt.loadNpmTasks( 'grunt-contrib-watch' );
	grunt.loadNpmTasks( 'grunt-rev' );

	grunt.registerTask( 'default', [ 'uglify:core', 'uglify:specific', 'less', 'cssmin', 'clean:frequentChangers', 'rev:frequentChangers', 'rename' ] );
	grunt.registerTask( 'all'    , [ 'uglify', 'less', 'cssmin', 'clean:all', 'rev:all', 'rename' ] );

	grunt.initConfig( {
		uglify: {
			options:{
				  sourceMap     : true
				, sourceMapName : function( dest ){
					var parts = dest.split( "/" );
					parts[ parts.length-1 ] = parts[ parts.length-1 ].replace( /\.js$/, ".map" );
					return parts.join( "/" );
				 }
			},
			core: {
				src: [
					  'js/admin/presidecore/preside.uber.select.js'
					, 'js/admin/presidecore/i18n.js'
					, 'js/admin/presidecore/preside.richeditor.js'
					, 'js/admin/presidecore/preside.bootbox.modal.js'
					, 'js/admin/presidecore/preside.asset.picker.js'
					, 'js/admin/presidecore/preside.object.picker.js'
					, 'js/admin/presidecore/preside.imageDimension.picker.js'
					, 'js/admin/presidecore/formFields.js'
					, 'js/admin/presidecore/list.js'
					, 'js/admin/presidecore/preside.autofocus.form.js'
					, 'js/admin/presidecore/preside.clickable.tableRows.js'
					, 'js/admin/presidecore/preside.confirmation.prompts.js'
					, 'js/admin/presidecore/preside.hotkeys.js'
					, 'js/admin/presidecore/preside.loading.sheen.js'
					, 'js/admin/presidecore/preside.url.builder.js'
					, 'js/admin/presidecore/preside.validation.defaults.js'
					, 'js/admin/presidecore/*.js'
					, '!js/admin/presidecore/_*.min.js'
				],
				dest: 'js/admin/presidecore/_presidecore.min.js'
			},
			specific:{
				files: [{
					expand  : true,
					cwd     : "js/admin/specific/",
					src     : ["**/*.js", "!**/*.min.js" ],
					dest    : "js/admin/specific/",
					ext     : ".min.js",
					rename  : function( dest, src ){
						var pathSplit = src.split( '/' );

						pathSplit[ pathSplit.length-1 ] = "_" + pathSplit[ pathSplit.length-2 ] + ".min.js";

						return dest + pathSplit.join( "/" );
					}
				}]
			},
			infrequentChangers: {
				files : [ {
					src  : ["js/admin/coretop/*.js", "!js/admin/coretop/*.min.js" ],
					dest : 'js/admin/coretop/_coretop.min.js'
				}, {
					src:["js/admin/coretop/ie/*.js", "!js/admin/coretop/ie/*.min.js" ],
					dest: 'js/admin/coretop/ie/_ie.min.js'
				},{
					src:["js/admin/devtools/*.js", "!js/admin/devtools/*.min.js" ],
					dest: 'js/admin/devtools/_devtools.min.js'
				}, {
					src:[ "js/admin/flot/jquery.flot.*.js" ],
					dest: 'js/admin/flot/_flot.min.js'
				}, {
					src:["js/admin/frontend/*.js", "!js/admin/frontend/*.min.js" ],
					dest: 'js/admin/frontend/_frontend.min.js'
				},{
					  src  : [
					  	"js/admin/lib/plugins/jquery.dataTables.js", // must come first
					  	"js/admin/lib/plugins/*.js"
					  ]
					, dest : "js/admin/lib/plugins-1.0.002.min.js"
				},{
					  src  : ["js/admin/lib/ace/ace.js", "js/admin/lib/ace/ace-elements.js"]
					, dest : "js/admin/lib/ace-1.0.0.min.js"
				},{
					  src  : "js/admin/lib/bootstrap-3.0.0.js"
					, dest : "js/admin/lib/bootstrap-3.0.0.min.js"
				},{
					  src  : "js/admin/lib/jquery-1.10.2.js"
					, dest : "js/admin/lib/jquery-1.10.2.min.js"
				},{
					  src  : "js/admin/lib/jquery-2.0.3.js"
					, dest : "js/admin/lib/jquery-2.0.3.min.js"
				},{
					  src  : "js/admin/lib/jquery-ui-1.10.3.custom.js"
					, dest : "js/admin/lib/jquery-ui-1.10.3.custom.min.js"
				} ]
			}
		},

		less: {
			options: {
				paths : [ "css/admin/lessglobals", "css/admin/bootstrap", "css/admin/ace" ],
			},
			all : {
				files: [{
					expand  : true,
					cwd     : 'css/admin/',
					src     : ['**/*.less', '!**/lessglobals/*', '!**/ace/**', '!**/bootstrap/**', '!**/core/**' ],
					dest    : 'css/admin/',
					ext     : ".less.css",
					rename  : function( dest, src ){
						var pathSplit = src.split( '/' );

						pathSplit[ pathSplit.length-1 ] = "$" + pathSplit[ pathSplit.length-1 ];

						return dest + pathSplit.join( "/" );
					}
				}]
			},
			core: {
				src  : 'css/admin/core/core.less',
				dest : 'css/admin/core/core.less.css'
			}
		},

		cssmin: {
			all: {
				expand : true,
				cwd    : 'css/admin/',
				src    : [ '**/*.css', '!**/_*.min.css' ],
				ext    : '.min.css',
				dest   : 'css/admin/',
				rename : function( dest, src ){
					var pathSplit = src.split( '/' );

					pathSplit[ pathSplit.length-1 ] = "_" + pathSplit[ pathSplit.length-2 ] + ".min.css";
					return dest + pathSplit.join( "/" );
				}
			}
		},

		clean: {
			frequentChangers : {
				files : [{
					  src    : [ "js/admin/specific/**/_*.min.js", "js/admin/presidecore/_*.min.js" ]
					, filter : function( src ){ return src.match(/[\/\\]_[a-f0-9]{8}\./) !== null; }
				}, {
					  src    : "css/admin/**/_*.min.css"
					, filter : function( src ){ return src.match(/[\/\\]_[a-f0-9]{8}\./) !== null; }
				}]
			},
			all : {
				files : [{
					  src    : "js/admin/**/_*.min.js"
					, filter : function( src ){ return src.match(/[\/\\]_[a-f0-9]{8}\./) !== null; }
				}, {
					  src    : "css/admin/**/_*.min.css"
					, filter : function( src ){ return src.match(/[\/\\]_[a-f0-9]{8}\./) !== null; }
				}]
			}
		},

		rev: {
			options: {
				algorithm : 'md5',
				length    : 8
			},
			frequentChangers: {
				files : [
					  { src : [ "js/admin/specific/**/_*.min.js", "js/admin/presidecore/_*.min.js" ]  }
					, { src : "css/admin/**/_*.min.css" }
				]
			},
			all: {
				files : [
					  { src : "js/admin/**/_*.min.js"  }
					, { src : "css/admin/**/_*.min.css" }
				]
			}
		},

		rename: {
			assets: {
				expand : true,
				cwd    : '',
				src    : '**/*._*.min.{js,css}',
				dest   : '',
				rename : function( dest, src ){
					var pathSplit = src.split( '/' );

					pathSplit[ pathSplit.length-1 ] = "_" + pathSplit[ pathSplit.length-1 ].replace( /\._/, "." );

					return dest + pathSplit.join( "/" );
				}
			}
		},

		watch: {
			frequentChangers: {
				files : [ "css/admin/**/*.less", "css/admin/**/*.css", "js/admin/presidecore/*.js", "js/admin/specific/**/*.js", "!css/admin/**/*.min.css", "!js/admin/**/*.min.js" ],
				tasks : [ "default" ]
			}
		}
	} );
};