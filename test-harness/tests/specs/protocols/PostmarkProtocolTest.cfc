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
		if ( getController().getColdBoxSetting( "version" ).listFirst( "." ) > 6 ) {
			variables.apikey = getEnv().getSystemSetting( "POSTMARK_API_KEY", "POSTMARK_API_TEST" );
		} else {
			variables.apikey = getUtil().getSystemSetting( "POSTMARK_API_KEY", "POSTMARK_API_TEST" );
		}
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Postmark Protocol", function(){
			beforeEach( function( currentSpec ){
				// Create a mock instance of the protocol.
				variables.protocol = createMock( "cbmailservices.models.protocols.PostmarkProtocol" ).init( { apiKey : variables.apikey } );
			} );

			it( "can be inited correctly", function(){
				expect( variables.protocol.propertyExists( "apiKey" ) ).toBeTrue();
			} );

			it( "can send mail to postmark", function(){
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

				expect( results.error ).toBeFalse( results.toString() );
				expect( results.messageID ).notToBeEmpty();
			} );
		} );
	}

}
