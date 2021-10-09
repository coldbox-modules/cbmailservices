/**
 * My Event Handler Hint
 */
component {

	// Index
	any function index( event, rc, prc ){
		prc.mailservices = getInstance( "MailService@cbmailservices" );
		event.setView( "main/index" );
	}

}
