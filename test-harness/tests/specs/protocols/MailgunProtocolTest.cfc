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
		if( getController().getColdBoxSetting( "version" ).listFirst( "." ) > 6 ){
			variables.apikey      = getEnv().getSystemSetting( "MAILGUN_API_KEY", "MAILGUN_API_KEY" );
			variables.domain      = getEnv().getSystemSetting( "MAILGUN_DOMAIN", "MAILGUN_DOMAIN" );
			variables.baseURL     = getEnv().getSystemSetting( "MAILGUN_BASEURL", "MAILGUN_BASEURL" );
		} else{
			variables.apikey      = getUtil().getSystemSetting( "MAILGUN_API_KEY", "MAILGUN_API_KEY" );
			variables.domain      = getUtil().getSystemSetting( "MAILGUN_DOMAIN", "MAILGUN_DOMAIN" );
			variables.baseURL     = getUtil().getSystemSetting( "MAILGUN_BASEURL", "MAILGUN_BASEURL" );
		}
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Mailgun Protocol", function(){
			beforeEach( function( currentSpec ){
				// Create a mock instance of the protocol.
				variables.protocol = createMock( "cbmailservices.models.protocols.MailgunProtocol" ).init( {
					apiKey  : variables.apikey,
					domain  : variables.domain,
					baseURL : variables.baseURL
				} );
			} );

			it( "can be inited correctly", function(){
				expect( variables.protocol.propertyExists( "apiKey" ) ).toBeTrue();
				expect( variables.protocol.propertyExists( "domain" ) ).toBeTrue();
				expect( variables.protocol.propertyExists( "baseURL" ) ).toBeTrue();
			} );

			it( "data is formatted for sending to mailgun", function(){
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

				var payloadData = payload.getConfig();

				expect( payloadData.to ).notToBeEmpty();
				expect( payloadData.from ).notToBeEmpty();
				expect( payloadData.type ).notToBeEmpty();
				expect( payloadData.body ).notToBeEmpty();
			} );
		} );
	}

}
