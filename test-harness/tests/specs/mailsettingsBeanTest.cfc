/**
 * My BDD Test
 */
component extends="coldbox.system.testing.BaseTestCase" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
	}

	/**
	 * executes after all suites+specs in the run() method
	 */
	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "Mail Settings Bean", function(){
			beforeEach( function( currentSpec ){
				setup();

				mailConfig = {
					server   : "mail.mail.com",
					username : "mail",
					password : "pass",
					port     : "110",
					protocol : { class : "CFMail", properties : {} },
					from     : "info@coldbox.org"
				};

				mailSettings = getInstance( "MailSettingsBean@cbmailservices" ).configure(
					argumentCollection = mailConfig
				);
			} );


			it( "can build out with defaults", function(){
				expect( mailSettings.getTransit() ).toBeComponent();
			} );

			it( "can get values", function(){
				expect( mailSettings.getValue( "from" ) ).toBe( mailConfig.from );
				expect( mailSettings.getValue( "bogus", "nothing" ) ).toBe( "nothing" );
				expect( function(){
					mailSettings.getValue( "bogusloco" );
				} ).toThrow();
			} );

			it( "can build out custom protocols by path", function(){
				mailSettings.registerProtocol(
					class: "cbmailservices.models.protocols.CFMailProtocol"
				);
				expect( mailSettings.getTransit() ).toBeComponent();
			} );

			it( "can throw an exception with an uknown protocol", function(){
				expect( function(){
					mailSettings.registerProtocol(
						class: "cbmailservices.models.protocols.SomeUnknownProtocol"
					)
				} ).toThrow();
			} );

			it( "can build out the FileProtocol", function(){
				mailSettings.registerProtocol(
					class     : "File",
					properties: { filePath : "/tests/resources/mail", autoExpand : true }
				);
				expect( mailSettings.getTransit() ).toBeComponent();
			} );

			it( "can build out the InMemoryProtocol", function(){
				mailSettings.registerProtocol( class: "InMemory" );
				expect( mailSettings.getTransit() ).toBeComponent();
			} );

			it( "can build out the NullProtocol", function(){
				mailSettings.registerProtocol( class: "InMemory" );
				expect( mailSettings.getTransit() ).toBeComponent();
			} );

			it( "can build out the PostMarkProtocol", function(){
				mailSettings.registerProtocol( class: "Postmark", properties: { apiKey : "123" } );
				expect( mailSettings.getTransit() ).toBeComponent();
			} );
		} );
	}

}
