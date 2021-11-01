/**
 * My BDD Test
 */
component extends="coldbox.system.testing.BaseTestCase" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
		super.beforeAll();
		setup();
		variables.mailservice = getInstance( "MailService@cbmailservices" );
		variables.tmpPath     = expandPath( "/tests/resources/mail" );
		cleanup();
		if ( !directoryExists( variables.tmpPath ) ) {
			directoryCreate( variables.tmpPath );
		}
	}

	function cleanup(){
		if ( directoryExists( variables.tmpPath ) ) {
			directoryDelete( variables.tmpPath, true );
		}
	}

	function getFileMailListing(){
		return directoryList(
			expandPath( variables.tmpPath ),
			false,
			"Name",
			"*.eml"
		);
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "CFMail Protocol", function(){
			beforeEach( function( currentSpec ){
				// Create a mock instance of the protocol.
				variables.protocol = createMock( "cbmailservices.models.protocols.CFMailProtocol" ).init();
			} );

			it( "can send mail", function(){
				var payload = variables.mailservice
					.newMail()
					.config(
						from = "info@ortussolutions.com",
						to   = "info@ortussolutions.com",
						type = "html"
					)
					.setBodyTokens( { name : "Luis Majano", time : dateFormat( now(), "full" ) } )
					.setBody(
						"<h1>Hello @name@, how are you today?</h1>  <p>Today is the <b>@time@</b>.</p> <br/><br/><a href=""http://www.coldbox.org"">ColdBox Rules!</a>"
					)
					.setSubject( "Mail NO Params-Hello Luis" );

				var results = protocol.send( payload );

				debug( results );
				expect( results.error ).toBeFalse( results.messages.toString() );
			} );


			it( "can send mail with params", function(){
				var payload = variables.mailservice
					.newMail()
					.config(
						from    = "info@coldbox.org",
						to      = "automation@coldbox.org",
						subject = "Mail With Params - Hello Luis"
					)
					.setBody( "Hello This is my great unit test" )
					.addMailParam(
						name  = "Disposition-Notification-To",
						value = "info@coldbox.org"
					)
					.addMailParam( name = "Importance", value = "High" );

				var results = protocol.send( payload );
				debug( results );
				expect( results.error ).toBeFalse( results.messages.toString() );
			} );


			it( "can send multi-part no params", function(){
				var	payload = variables.mailservice
					.newMail()
					.config(
						from    = "info@coldbox.org",
						to      = "automation@coldbox.org",
						subject = "Mail MultiPart No Params - Hello Luis"
					)
					.addMailPart(
						type = "text",
						body = "You are reading this message as plain text, because your mail reader does not handle it."
					)
					.addMailPart( type = "html", body = "This is the body of the message." );

				var results = protocol.send( payload );
				debug( results );
				expect( results.error ).toBeFalse( results.messages.toString() );
			} );

			it( "can send multi-part with params", function(){
				var	payload = variables.mailservice
					.newMail()
					.config(
						from    = "info@coldbox.org",
						to      = "automation@coldbox.org",
						subject = "Mail MultiPart With Params - Hello Luis"
					)
					.addMailPart(
						type = "text",
						body = "You are reading this message as plain text, because your mail reader does not handle it."
					)
					.addMailPart( type = "html", body = "This is the body of the message." )
					.addMailParam(
						name  = "Disposition-Notification-To",
						value = "info@coldbox.org"
					);

				var results = protocol.send( payload );
				debug( results );
				expect( results.error ).toBeFalse( results.messages.toString() );
			} );
		} );
	}

}
