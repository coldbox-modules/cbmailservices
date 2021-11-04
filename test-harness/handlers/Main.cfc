/**
 * My Event Handler Hint
 */
component {

	// Index
	any function index( event, rc, prc ){
		prc.mailservices = getInstance( "MailService@cbmailservices" );

		// Test Mail Out
		prc.mailresults = newMail( subject: "Hello From ColdBox Land!" )
			.setBodyTokens( { name : "Luis Majano", time : dateFormat( now(), "full" ) } )
			.setBody(
				"<h1>Hello @name@, how are you today?</h1>  <p>Today is the <b>@time@</b>.</p> <br/><br/><a href=""http://www.coldbox.org"">ColdBox Rules!</a>"
			)
			.send()
			.getResults();

		event.setView( "main/index" );
	}

}
