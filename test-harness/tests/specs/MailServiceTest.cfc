component extends="coldbox.system.testing.BaseTestCase" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
		super.beforeAll();
		super.setup();
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		describe( "Mail Services Suite", function(){
			beforeEach( function( currentSpec ){
				mailService = prepareMock( getInstance( "MailService@cbmailservices" ) );
				mailService.getMailSettings().registerProtocol( "InMemory" );
			} );

			afterEach( function( currentSpec ){
				// clear mail
				mailService
					.getMailSettings()
					.getTransit()
					.setMail( [] );
			} );

			it( "can create a new mail object", function(){
				expect( mailService.newMail() ).toBeComponent();
			} );

			it( "can parse tokens", function(){
				mailService.setTokenMarker( "@" );
				var mail   = mailService.newMail();
				var tokens = {
					"name" : "Luis Majano",
					"time" : dateFormat( now(), "full" )
				};

				mail.setBodyTokens( tokens );
				mail.setBody( "Hello @name@, how are you today? Today is the @time@" );

				mailService.parseTokens( mail );

				// debug( mail.getBody() );
				expect( mail.getBody() ).toBe(
					"Hello #tokens.name#, how are you today? Today is the #tokens.time#"
				);
			} );

			it( "can parse custom tokens", function(){
				mailService.setTokenMarker( "$" );
				var mail   = mailService.newMail();
				var tokens = { name : "Luis Majano", time : dateFormat( now(), "full" ) };

				mail.setBodyTokens( tokens );
				mail.setBody( "Hello $name$, how are you today? Today is the $time$" );

				mailService.parseTokens( mail );

				expect( mail.getBody() ).toBe(
					"Hello #tokens.name#, how are you today? Today is the #tokens.time#"
				);
			} );

			it( "can send mail with no params", function(){
				var mail = mailService
					.newMail()
					.configure(
						from = "info@coldbox.org",
						to   = "automation@coldbox.org",
						type = "html"
					);
				var tokens = { name : "Luis Majano", time : dateFormat( now(), "full" ) };
				mail.setBodyTokens( tokens );
				mail.setBody(
					"<h1>Hello @name@, how are you today?</h1>  <p>Today is the <b>@time@</b>.</p> <br/><br/><a href=""http://www.coldbox.org"">ColdBox Rules!</a>"
				);
				mail.setSubject( "Mail NO Params-Hello Luis" );
				var results = mailService.send( mail );
				expect(
					mailService
						.getMailSettings()
						.getTransit()
						.getMail()
				).notToBeEmpty();
				expect( results.error ).toBeFalse();
			} );


			it( "can send mail with params", function(){
				var results = mailService
					.newMail()
					.configure(
						from    = "info@coldbox.org",
						to      = "automation@coldbox.org",
						subject = "Mail With Params - Hello Luis"
					)
					.setBody( "Hello This is my great unit test" )
					.addMailParam(
						name  = "Disposition-Notification-To",
						value = "info@coldbox.org"
					)
					.addMailParam( name = "Importance", value = "High" )
					.send();

				expect(
					mailService
						.getMailSettings()
						.getTransit()
						.getMail()
				).notToBeEmpty();
				expect( results.error ).toBeFalse();
			} );


			it( "can send mail with multi-part no params", function(){
				var mail = mailService
					.newMail()
					.configure(
						from    = "info@coldbox.org",
						to      = "automation@coldbox.org",
						subject = "Mail MultiPart No Params - Hello Luis"
					);
				mail.addMailPart(
					type = "text",
					body = "You are reading this message as plain text, because your mail reader does not handle it."
				);
				mail.addMailPart( type = "html", body = "This is the body of the message." );
				var results = mailService.send( mail );
				expect(
					mailService
						.getMailSettings()
						.getTransit()
						.getMail()
				).notToBeEmpty();
				expect( results.error ).toBeFalse();
			} );

			it( "can send mail with multi-part with params", function(){
				var mail = mailService
					.newMail()
					.configure(
						from    = "info@coldbox.org",
						to      = "automation@coldbox.org",
						subject = "Mail MultiPart With Params - Hello Luis"
					);
				mail.addMailPart(
					type = "text",
					body = "You are reading this message as plain text, because your mail reader does not handle it."
				);
				mail.addMailPart( type = "html", body = "This is the body of the message." );
				mail.addMailParam(
					name  = "Disposition-Notification-To",
					value = "info@coldbox.org"
				);
				var results = mailService.send( mail );
				expect(
					mailService
						.getMailSettings()
						.getTransit()
						.getMail()
				).notToBeEmpty();
				expect( results.error ).toBeFalse();
			} );

			it( "can send mail with custom settings", function(){
				var results = mailService
					.newMail(
						from    = "info@coldbox.org",
						to      = "automation@coldbox.org",
						type    = "html",
						body    = "TestMailWithSettings",
						subject = "TestMailWithSettings"
					)
					.send();

				expect(
					mailService
						.getMailSettings()
						.getTransit()
						.getMail()
				).notToBeEmpty();
				expect( results.error ).toBeFalse();
			} );
		} );
	}

}
