/**
 ********************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 ********************************************************************************
 * @author Luis Majano <lmajano@ortussolutions.com>
 * ----
 * The mail service queue scheduler
 */
component {
	property name="runQueueTask" inject="box:setting:runQueueTask@cbmailservices";
	function configure(){

		task( "MailQueue" )
			.call( function(){
				getInstance( "MailService@cbmailServices" ).processQueue();
			})
			.everyMinute()
			.withNoOverlaps()
			.when( function(){ return runQueueTask; } )
			.onFailure( function( task, exception ){
				log.error( "Error running mail services queue processing: #exception.message & exception.detail#", exception.stacktrace );
			} )
			.onSuccess( function( task, results ){
				log.debug( "Mail queue finished processing successfully: #task.getStats().toString()#" );
			} );
	}

	/**
	 * Called before the scheduler is going to be shutdown
	 */
	function onShutdown(){
		log.info( "Mail services queue scheduler is shutting down." );
	}

	/**
	 * Called after the scheduler has registered all schedules
	 */
	function onStartup(){
		log.info( "Mail services queue scheduler has started" );
	}

}
