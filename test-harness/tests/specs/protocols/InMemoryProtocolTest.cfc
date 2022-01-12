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
				variables.protocol = createMock( "cbmailservices.models.protocols.InMemoryProtocol" ).init( {} );
			} );

			it( "can send mail to the in memory db", function(){
				var payload = variables.mailservice
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

				variables.protocol.send( payload );

				var messages = variables.protocol.getMail();
				expect( messages ).toBeArray();
				expect( messages ).toHaveLength( 1 );
				expect( messages[ 1 ] ).toBe( payload.getConfig() );
			} );

			it( "can send messages and use the hasMessage to validate sending ", function(){
				variables.protocol.reset();

				var sentPayload = variables.mailService
					.newMail()
					.config(
						from = "info@coldbox.org",
						to   = "sent@coldbox.org",
						type = "html"
					);
				sentPayload.setBodyTokens( {
					"name" : "Luis Majano",
					"time" : dateFormat( now(), "full" )
				} );
				sentPayload.setBody(
					"<h1>Hello @name@, how are you today?</h1>  <p>Today is the <b>@time@</b>.</p> <br/><br/><a href=""http://www.coldbox.org"">ColdBox Rules!</a>"
				);
				sentPayload.setSubject( "Mail SENT" );
				variables.protocol.send( sentPayload );

				var unsentPayload = variables.mailService
					.newMail()
					.config(
						from = "info@coldbox.org",
						to   = "unsent@coldbox.org",
						type = "html"
					);
				unsentPayload.setBodyTokens( {
					"name" : "Luis Majano",
					"time" : dateFormat( now(), "full" )
				} );
				unsentPayload.setBody(
					"<h1>Hello @name@, how are you today?</h1>  <p>Today is the <b>@time@</b>.</p> <br/><br/><a href=""http://www.coldbox.org"">ColdBox Rules!</a>"
				);
				unsentPayload.setSubject( "Mail NOT SENT" );

				expect(
					variables.protocol.hasMessage( function( mail ){
						return mail.from == sentPayload.getMemento().from &&
						mail.to == sentPayload.getMemento().to;
					} )
				).toBeTrue( "hasMessage should return true for message that was sent." );

				expect(
					variables.protocol.hasMessage( function( mail ){
						return mail.from == unsentPayload.getMemento().from &&
						mail.to == unsentPayload.getMemento().to;
					} )
				).toBeFalse( "hasMessage should return true for message that was not sent." );
			} );
		} );
	}

}
