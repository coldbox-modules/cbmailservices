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
		variables.tmpPath     = expandPath( "/tests/tmp" );
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
		return directoryList( variables.tmpPath, false, "Name", "*.html" );
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "File Protocol", function(){
			beforeEach( function( currentSpec ){
				// Create a mock instance of the protocol.
				variables.protocol = createMock( "cbmailservices.models.protocols.FileProtocol" ).init( { filePath : variables.tmpPath, autoExpand : false } );
			} );

			it( "can be inited correctly", function(){
				expect( variables.protocol.propertyExists( "filePath" ) ).toBeTrue();
			} );

			it( "can send mail to files", function(){
				var payload = variables.mailservice
					.newMail()
					.config(
						from = "info@coldbox.org",
						to   = "automation@coldbox.org",
						type = "html"
					);
				var tokens = { name : "Luis Majano", time : dateFormat( now(), "full" ) };
				payload.setBodyTokens( tokens );
				payload.setBody(
					"<h1>Hello @name@, how are you today?</h1>  <p>Today is the <b>@time@</b>.</p> <br/><br/><a href=""http://www.coldbox.org"">ColdBox Rules!</a>"
				);
				payload.setSubject( "Mail NO Params-Hello Luis" );
				var results = protocol.send( payload );

				var fileListing = getFileMailListing();

				debug( fileListing );
				expect( fileListing.len() ).toBeGT( 0 );
			} );

			it( "can send mail with no type specified", function(){
				var payload = getMockBox()
					.createMock( className = "cbmailservices.models.Mail" )
					.init()
					.config(
						from    = "info@coldbox.org",
						to      = "automation@coldbox.org",
						subject = "Mail With Params - Hello Luis"
					);
				payload.setBody( "Hello This is my great unit test" );
				payload.addMailParam( name = "Disposition-Notification-To", value = "info@coldbox.org" );
				payload.addMailParam( name = "Importance", value = "High" );
				var results = protocol.send( payload );
				debug( results );
				var fileListing = getFileMailListing();
				debug( fileListing );
				expect( fileListing.len() ).toBeGT( 1 );
			} );
		} );
	}

}
