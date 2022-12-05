component extends="coldbox.system.testing.BaseTestCase" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	/**
	 * executes before all suites+specs in the run() method
	 */
	function beforeAll(){
		super.setup();
	}

	/**
	 * executes after all suites+specs in the run() method
	 */
	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		describe( "Mail payload", function(){
			beforeEach( function( currentSpec ){
				mail = getInstance( "Mail@cbmailServices" );
			} );

			it( "can be configured", function(){
				mail.configure( from = "lmajano@gmail.com" );
				expect( mail.getFrom() ).toBe( "lmajano@gmail.com" );
			} );

			it( "can work with body tokens", function(){
				expect( mail.getBodyTokens() ).toBeEmpty();
				mail.configure( bodyTokens = { name : "luis" } );
				expect( mail.getBodyTokens() ).notToBeEmpty();
			} );

			it( "can work with mail parts", function(){
				expect( mail.getMailParts() ).toBeEmpty();
				mail.addMailpart( type = "mypart", body = "this is my body" );
				expect( mail.getMailParts() ).notToBeEmpty();
			} );

			it( "can work with mail params", function(){
				expect( mail.getMailParams() ).toBeEmpty();
				mail.addMailParam(
					contentId = "123",
					type      = "file",
					file      = "c:\test.temp"
				);
				expect( mail.getMailParams() ).notToBeEmpty();
			} );

			it( "can validate a mail payload", function(){
				expect( mail.validate() ).toBeFalse();
				mail.configure(
					subject = "Hello",
					from    = "lmajano@mail.com",
					to      = "lmajano@mail.com",
					body    = "Hello"
				);
				expect( mail.validate() ).toBeTrue();
			} );

			it( "validateOrFail will throw for invalid mail", function() {

				expect(function() {
					mail.configure(
						from    = "info@coldbox.org",
						to      = "automation@coldbox.org"
						// OMIT subject... "Oops! DID I DO THAT???"
					)
					.validateOrFail()
				}).toThrow( "InvalidMailException" );
			});

			it( "validateOrFail won't throw for valid emails", function() {
				expect( function() {
					mail.configure(
						subject = "Hello",
						from    = "lmajano@mail.com",
						to      = "lmajano@mail.com",
						body    = "Hello"
					).validateOrFail();
				}).notToThrow( "InvalidMailException" );
			});

			it( "can set html types", function(){
				mail.configure(
						subject = "Hello",
						from    = "lmajano@mail.com",
						to      = "lmajano@mail.com",
						body    = "Hello"
					)
					.setHTML( "What up Dude" );

				debug( mail.getMailParts() );

				expect( mail.getMailParts() ).notToBeEmpty();
				var parts = mail.getMailParts();
				expect( parts[ 1 ].type ).toInclude( "text/html" );
			} );

			it( "can set text types", function(){
				mail.configure(
						subject = "Hello",
						from    = "lmajano@mail.com",
						to      = "lmajano@mail.com",
						body    = "Hello"
					)
					.setText( "What up Dude" );

				debug( mail.getMailParts() );

				expect( mail.getMailParts() ).notToBeEmpty();
				var parts = mail.getMailParts();
				expect( parts[ 1 ].type ).toInclude( "text/plain" );
			} );

			it( "can set send/read receipts", function(){
				mail.configure(
						subject = "Hello",
						from    = "lmajano@mail.com",
						to      = "lmajano@mail.com",
						body    = "Hello"
					)
					.setSendReceipt( "lmajano@coldbox.org" )
					.setReadReceipt( "test@coldbox.org" );

				debug( mail.getMailParams() );
				expect( mail.getMailParams() ).notToBeEmpty();
				var params = mail.getMailParams();
				expect( params[ 1 ].name ).toInclude( "return-receipt-to" );
				expect( params[ 2 ].name ).toInclude( "read-receipt-to" );
			} );

			it( "can add attachments", function(){
				mail.configure(
					subject = "Hello",
					from    = "lmajano@mail.com",
					to      = "lmajano@mail.com",
					body    = "Hello"
				);
				var files = [ "file1", "file2" ];
				mail.addAttachments( files, true );

				debug( mail.getMailParams() );
				assertTrue( arrayLen( mail.getMailParams() ) );

				var params = mail.getMailParams();
				debug( params );
				assertEquals( files[ 1 ], params[ 1 ].file );
				assertEquals( true, params[ 1 ].remove );
				assertEquals( files[ 2 ], params[ 2 ].file );
				assertEquals( true, params[ 2 ].remove );
			} );

			it( "can work with additional info via the configure method", function(){
				mail.configure( additionalInfo = { "categories" : "Spam" } );
				assertEquals( { "categories" : "Spam" }, mail.getAdditionalInfo() );
			} );

			it( "can work with additional info via the setter method", function(){
				mail.setAdditionalInfo( { "categories" : "Spam2" } );
				assertEquals( { "categories" : "Spam2" }, mail.getAdditionalInfo() );
			} );

			it( "can work with additional info via item setter method", function(){
				mail.setAdditionalInfoItem( "categories", "Spam3" );
				assertEquals( { "categories" : "Spam3" }, mail.getAdditionalInfo() );
				assertEquals( "Spam3", mail.getAdditionalInfoItem( "categories" ) );
			} );
		} );
	}

}
