component output=false {

	property name="websiteLoginService"  inject="websiteLoginService";

// core events
	public void function index( event, rc, prc ) output=false {
		if ( websiteLoginService.isLoggedIn() ) {
			setNextEvent( url=_getDefaultPostLoginUrl( argumentCollection=arguments ) );
		}
	}

	public void function attemptLogin( event, rc, prc ) output=false {
		if ( websiteLoginService.isLoggedIn() ) {
			setNextEvent( url=_getDefaultPostLoginUrl( argumentCollection=arguments ) );
		}
		var loginId         = rc.loginId  ?: "";
		var password        = rc.password ?: "";
		var postLoginUrl    = Len( Trim( rc.postLoginUrl ?: "" ) ) ? rc.postLoginUrl : _getDefaultPostLoginUrl( argumentCollection=arguments );
		var rememberMe      = _getRememberMeAllowed() && IsBoolean( rc.rememberMe ?: "" ) && rc.rememberMe;
		var loggedIn        = websiteLoginService.login(
			  loginId              = loginId
			, password             = password
			, rememberLogin        = rememberMe
			, rememberExpiryInDays = _getRememberMeExpiry()
		);

		if ( loggedIn ) {
			setNextEvent( url=postLoginUrl );
		}

		setNextEvent( url=event.buildLink( linkTo="login" ), persistStruct={
			  loginId      = loginId
			, password     = password
			, postLoginUrl = postLoginUrl
			, rememberMe   = rememberMe
			, message      = "LOGIN_FAILED"
		} );
	}

	public void function logout( event, rc, prc ) output=false {
		websiteLoginService.logout();

		setNextEvent( url=( Len( Trim( cgi.http_referer ) ) ? cgi.http_referer : _getDefaultPostLogoutUrl( argumentCollection=arguments ) ) );
	}

	public void function forgottenPassword( event, rc, prc ) output=false {
		if ( websiteLoginService.isLoggedIn() ) {
			setNextEvent( url=_getDefaultPostLoginUrl( argumentCollection=arguments ) );
		}

		event.setView( "/login/forgottenPassword" );
	}

	public void function sendResetInstructions( event, rc, prc ) output=false {
		if ( websiteLoginService.sendPasswordResetInstructions( rc.loginId ?: "" ) ) {
			setNextEvent( url=event.buildLink( linkTo="login.forgottenPassword" ), persistStruct={
				message = "PASSWORD_RESET_INSTRUCTIONS_SENT"
			} );
		}

		setNextEvent( url=event.buildLink( linkTo="login.forgottenPassword" ), persistStruct={
			message = "LOGINID_NOT_FOUND"
		} );
	}

	public void function resetPassword( event, rc, prc ) output=false {
		if ( websiteLoginService.isLoggedIn() ) {
			setNextEvent( url=_getDefaultPostLoginUrl( argumentCollection=arguments ) );
		}

		if ( !websiteLoginService.validateResetPasswordToken( rc.token ?: "" ) ) {
			setNextEvent( url=event.buildLink( linkTo="login.forgottenPassword" ), persistStruct={
				message = "INVALID_RESET_TOKEN"
			} );
		}

		event.setView( "/login/resetPassword" );
	}

	public void function resetPasswordAction( event, rc, prc ) output=false {
		var pw           = rc.password             ?: "";
		var confirmation = rc.passwordConfirmation ?: "";
		var token        = rc.token                ?: "";

		if ( !websiteLoginService.validateResetPasswordToken( rc.token ?: "" ) ) {
			setNextEvent( url=event.buildLink( linkTo="login.forgottenPassword" ), persistStruct={
				message = "INVALID_RESET_TOKEN"
			} );
		}

		if ( !Len( Trim( pw ) ) ) {
			setNextEvent( url=event.buildLink( linkTo="login.resetPassword" ), persistStruct={
				  message = "EMPTY_PASSWORD"
				, token   = token
			} );
		}

		if ( pw != confirmation ) {
			setNextEvent( url=event.buildLink( linkTo="login.resetPassword" ), persistStruct={
				  message = "PASSWORDS_DO_NOT_MATCH"
				, token   = token
			} );
		}

		if ( websiteLoginService.resetPassword( token=token, password=pw ) ) {
			setNextEvent( url=event.buildLink( linkTo="login" ), persistStruct={
				message = "PASSWORD_RESET"
			} );
		}

		setNextEvent( url=event.buildLink( linkTo="login.resetPassword" ), persistStruct={
			  message = "UNKNOWN_ERROR"
			, token   = token
		} );

	}

// viewlets
	private string function loginPage( event, rc, prc, args={} ) output=false {
		args.allowRememberMe = _getRememberMeAllowed();
		args.postLoginUrl    = args.postLoginUrl ?: ( rc.postLoginUrl ?: _getDefaultPostLoginUrl( argumentCollection=arguments ) );
		args.loginId         = args.loginId      ?: ( rc.loginId      ?: "" );
		args.rememberMe      = args.rememberMe   ?: ( rc.rememberMe   ?: "" );
		args.message         = args.message      ?: ( rc.message      ?: "" );

		return renderView( view="/login/loginPage", args=args );
	}

// private helpers
	private string function _getDefaultPostLoginUrl( event, rc, prc ) output=false {
		var defaultPage = getSystemSetting( "website_users", "default_post_login_page", "" );

		if ( Len( Trim( defaultPage ) ) ) {
			return event.buildLink( page=defaultPage );
		}
		return "/";
	}

	private string function _getDefaultPostLogoutUrl( event, rc, prc ) output=false {
		var defaultPage = getSystemSetting( "website_users", "default_post_logout_page", "" );

		if ( Len( Trim( defaultPage ) ) ) {
			return event.buildLink( page=defaultPage );
		}
		return "/";
	}

	private boolean function _getRememberMeAllowed() output=false {
		var allowed = getSystemSetting( "website_users", "allow_remember_me", true );
		return IsBoolean( allowed ) && allowed;
	}

	private boolean function _getRememberMeExpiry() output=false {
		return getSystemSetting( "website_users", "remember_me_expiry", 90 );
	}

}