( function( $ ){
	var $progressContainer = $( "#ad-hoc-task-progress-container" )
	  , statusUpdateUrl    = cfrequest.adhocTaskStatusUpdateUrl || "";

	if ( !$progressContainer.length || !statusUpdateUrl.length ) {
		return;
	}

	var $timeArea    = $( '#task-log-timetaken' )
	  , $progressBar = $progressContainer.find( ".progress:first" )
	  , $cancelBtn   = $( '#task-cancel-button' )
	  , $resultBtn   = $( '#view-result-button' )
	  , $logArea     = $( '#taskmanager-log' )
	  , $taskLog     = $( '#task-log' )
	  , $summaryArea = $( '#taskmanager-summary-area' )
	  , $summary     = $( '#taskmanager-summary' )
	  , hasLogArea   = $logArea.length
	  , logArea      = hasLogArea ? $logArea.get(0) : null
	  , lineCount    = cfrequest.adhocTaskLineCount || ""
	  , fetchRate    = 1000
	  , fetchUpdate, processUpdate, intervalId, scrollToBottom, setProgress;

	scrollToBottom = function(){
		if ( hasLogArea ) {
			$logArea.animate( {scrollTop: logArea.scrollHeight - logArea.clientHeight}, 400 );
		}
	};

	fetchUpdate = function(){
		$.get( statusUpdateUrl, { fetchAfterLines : lineCount }, processUpdate );
	};

	setProgress = function( progress ){
		$progressBar.attr( "data-percent", progress + "%" );
		$progressBar.find( ".progress-bar:first" ).css( "width", progress + "%" );
	};

	processUpdate = function( data ) {
		var isRunning           = data.status == "running"
		  , isPending           = data.status == "pending"
		  , wasScrolledToBottom = hasLogArea ? ( logArea.scrollHeight - logArea.clientHeight <= logArea.scrollTop + 1 ) : false;

		$timeArea.html( data.timeTaken );

		if ( $.trim( data.log ).length ) {
			$logArea.html( $logArea.html() + String.fromCharCode( 10 ) + data.log );
			lineCount = data.logLineCount;

			if ( wasScrolledToBottom ) {
				scrollToBottom();
			}
		}

		setProgress( data.progress );

		if ( !isRunning && !isPending ) {
			clearInterval( intervalId );
			$timeArea.parent().removeClass( "running blue" );
			$timeArea.parent().addClass( "complete" );

			if ( data.status == "succeeded" ) {
				$timeArea.parent().addClass( "green" );
			} else {
				$timeArea.parent().addClass( "red" );
			}

			if ( data.status == "succeeded" ){
				if ( data.resultUrl.length ) {
					window.location = data.resultUrl;
				}

				if ( data.summary.length ) {
					$summary.html( data.summary );
					$summaryArea.removeClass( "hide") ;
					$taskLog.removeClass( "in" ).addClass( "collapse" );
				}
			}

			if ( $cancelBtn.length ) {
				$cancelBtn.prop( "disabled", true );
				$cancelBtn.addClass( "btn-disabled disabled" );
			}

			$progressBar.removeClass( "active" );
			$progressBar.removeClass( "progress-striped" );
		} else if ( isRunning ) {
			$timeArea.parent().addClass( "running blue" ).removeClass( "orange red green" );
		}
	};

	intervalId = setInterval( fetchUpdate, fetchRate );
	if ( hasLogArea ) {
		setTimeout( scrollToBottom, 2000 );
	}

} )( presideJQuery );