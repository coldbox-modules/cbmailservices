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
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Null Protocol", function(){
			beforeEach( function( currentSpec ){
				// Create a mock instance of the protocol.
				variables.protocol = createMock( "cbmailservices.models.protocols.NullProtocol" ).init( {} );
			} );

			it( "can send mail to nowhere", function(){
				// 1:Mail with No Params
				var mail = variables.mailservice
					.newMail()
					.config(
						from = "info@coldbox.org",
						to   = "automation@coldbox.org",
						type = "html"
					)
					.setBodyTokens( {
						"name" : "Luis Majano",
						"time" : dateFormat( now(), "full" )
					} )
					.setBody(
						"<h1>Hello @name@, how are you today?</h1>  <p>Today is the <b>@time@</b>.</p> <br/><br/><a href=""http://www.coldbox.org"">ColdBox Rules!</a>"
					)
					.setSubject( "Mail NO Params-Hello Luis" );

				variables.protocol.send( mail );
			} );
		} );
	}

}
