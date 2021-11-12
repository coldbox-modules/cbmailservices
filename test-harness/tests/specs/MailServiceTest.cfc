component extends="coldbox.system.testing.BaseTestCase" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
		structDelete( application, "cbController" );
		super.beforeAll();
		super.setup();
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		describe( "Mail Services Suite", function(){
			beforeEach( function( currentSpec ){
				mailService = prepareMock( getInstance( "MailService@cbmailservices" ) );
			} );

			it( "can be built with app defaults", function(){
				expect( mailService.getTokenMarker() ).toBe( "@" );
				expect( mailService.getDefaultSetting( "to" ) ).toBe( "info@ortussolutions.com" );
				expect( mailService.getDefaultSetting( "from" ) ).toBe( "info@ortussolutions.com" );
				expect( mailService.getDefaultSetting( "cc" ) ).toBe( "lmajano@ortussolutions.com" );
				expect( mailService.getMailers() ).toHaveLength( 3 );
				expect( mailService.getDefaultMailer().class ).toInclude( "InMemory" );
				expect( mailService.getMailer( "files" ).class ).toInclude( "File" );
				expect( mailService.getMailer( "memory" ).class ).toInclude( "InMemory" );
				expect( mailService.getMailer( "cfmail" ).class ).toInclude( "CFMail" );
				expect( mailService.getRegisteredMailers() ).toBeArray().notToBeEmpty();
			} );

			it( "can build out custom protocols by path", function(){
				mailService.registerMailer(
					name = "MailTestProtocol",
					class: "cbmailservices.models.protocols.CFMailProtocol"
				);
				expect( mailService.getMailer( "MailTestProtocol" ).transit ).toBeComponent();
			} );

			it( "can throw an exception with an uknown protocol", function(){
				expect( function(){
					mailService.registerMailer(
						name = "MailTestProtocol",
						class: "cbmailservices.models.protocols.SomeUnknownProtocol"
					);
				} ).toThrow();
			} );

			it( "can create a new mail object", function(){
				expect( mailService.newMail() ).toBeComponent();
				expect( mailService.newMail().getMailer() ).toBe( "memory" );
			} );

			it( "can parse tokens", function(){
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

			describe( "Send mail with multiple params and attachments", function(){
				afterEach( function( currentSpec ){
					mailService.getDefaultMailer().transit.reset();
				} );

				it( "can send mail with a rendered view", function(){
					var mail = mailService
						.newMail(
							from       = "info@coldbox.org",
							to         = "automation@coldbox.org",
							type       = "html",
							subject    = "Here is a rendered view",
							bodyTokens = {
								name : "Luis Majano",
								time : dateFormat( now(), "full" )
							}
						)
						.setView( view: "emails/newUser" )
						.send();

					debug( mail.getBody() );
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
					mailService
						.send( mail )
						.onSuccess( function( results, mail ){
							debug( mailService.getDefaultMailer().transit.getMail() );
							expect( mailService.getDefaultMailer().transit.getMail() ).notToBeEmpty();
							expect( mailService.getDefaultMailer().transit.getMail()[ 1 ].cc ).toBe(
								"lmajano@ortussolutions.com"
							);
							expect( mail.hasErrors() ).toBeFalse(
								mail.getResultMessages().toString()
							);
						} )
						.onError( function( results, mail ){
							fail( "The mailing failed! #results.toString()#" );
						} );
				} );

				it( "can send mail asynchronusly", function(){
					// Adobe sucks, always null pointer and no reason why
					if ( !server.keyExists( "lucee" ) ) {
						return;
					}
					mailService
						.newMail()
						.configure( subject = "Mail With Params - Hello Luis" )
						.setBody( "Hello This is my great unit test" )
						.sendAsync()
						.then( function( mail ){
							return mail;
						} )
						.get()
						.onSuccess( function( results, mail ){
							debug( mailService.getDefaultMailer().transit.getMail() );
							expect( mailService.getDefaultMailer().transit.getMail() ).notToBeEmpty();
							expect( mail.hasErrors() ).toBeFalse(
								mail.getResultMessages().toString()
							);
						} )
						.onError( function( results, mail ){
							fail( "The mailing failed! #results.toString()#" );
						} );
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
						.send()
						.onSuccess( function( results, mail ){
							debug( mailService.getDefaultMailer().transit.getMail() );
							expect( mailService.getDefaultMailer().transit.getMail() ).notToBeEmpty();
							expect( mail.hasErrors() ).toBeFalse(
								mail.getResultMessages().toString()
							);
						} )
						.onError( function( results, mail ){
							fail( "The mailing failed! #results.toString()#" );
						} );
				} );

				it( "can send mail with multi-part no params", function(){
					var mail = mailService
						.newMail()
						.configure(
							from    = "info@coldbox.org",
							to      = "automation@coldbox.org",
							subject = "Mail MultiPart No Params - Hello Luis"
						)
						.addMailPart(
							type = "text",
							body = "You are reading this message as plain text, because your mail reader does not handle it."
						)
						.addMailPart( type = "html", body = "This is the body of the message." )
						.send()
						.onSuccess( function( results, mail ){
							debug( mailService.getDefaultMailer().transit.getMail() );
							expect( mailService.getDefaultMailer().transit.getMail() ).notToBeEmpty();
							expect( mail.hasErrors() ).toBeFalse(
								mail.getResultMessages().toString()
							);
						} )
						.onError( function( results, mail ){
							fail( "The mailing failed! #results.toString()#" );
						} );
				} );

				it( "can send mail with multi-part with params", function(){
					var mail = mailService
						.newMail()
						.configure(
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
						)
						.send()
						.onSuccess( function( results, mail ){
							debug( mailService.getDefaultMailer().transit.getMail() );
							expect( mailService.getDefaultMailer().transit.getMail() ).notToBeEmpty();
							expect( mail.hasErrors() ).toBeFalse(
								mail.getResultMessages().toString()
							);
						} )
						.onError( function( results, mail ){
							fail( "The mailing failed! #results.toString()#" );
						} );
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
						.send()
						.onSuccess( function( results, mail ){
							debug( mailService.getDefaultMailer().transit.getMail() );
							expect( mailService.getDefaultMailer().transit.getMail() ).notToBeEmpty();
							expect( mail.hasErrors() ).toBeFalse(
								mail.getResultMessages().toString()
							);
						} )
						.onError( function( results, mail ){
							fail( "The mailing failed! #results.toString()#" );
						} );
				} );
			} );
		} );
	}

}
