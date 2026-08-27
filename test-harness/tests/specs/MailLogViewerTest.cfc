component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        super.beforeAll();
        setup();
        variables.fileMailer = getInstance( "MailService@cbmailservices" ).getMailer( "files" );
        variables.logPath = createObject( "java", "java.io.File" )
            .init( variables.fileMailer.transit.getProperty( "filePath" ) )
            .getCanonicalPath();
        variables.fixture = variables.logPath & "/mail.viewer-test.html";
        variables.legacyFixture = variables.logPath & "/mail.viewer-legacy-test.html";
    }

    function afterAll() {
        if ( fileExists( variables.fixture ) ) {
            fileDelete( variables.fixture );
        }
        if ( fileExists( variables.legacyFixture ) ) {
            fileDelete( variables.legacyFixture );
        }
    }

    function run() {
        describe( "Development mail log viewer", function() {
            beforeEach( function() {
                fileWrite(
                    variables.fixture,
                    "<div hidden data-cbmailservices-log data-from=""sender@example.com"" data-to=""recipient@example.com"" data-subject=""Verify your email"" data-sent=""2026-08-27T14:00:00-06:00""></div><hr/>Mail Body<hr/><h1>Verify your email</h1>"
                );
                fileWrite(
                    variables.legacyFixture,
                    "<tr><th>from</th><td><span><span>String:</span><span>old-sender&##x40;example.com</span></span></td></tr><tr><th>to</th><td><span><span>String:</span><span>old-recipient&##x40;example.com</span></span></td></tr><tr><th>subject</th><td><span><span>String:</span><span>Existing log</span></span></td></tr>Mail Body<hr/><p>Already on disk</p>"
                );
            } );

            it( "discovers configured File protocol directories and messages", function() {
                var result = getInstance( "MailLogService@cbmailservices" ).listMessages();
                var message = result.messages.filter( ( item ) => item.fileName == "mail.viewer-test.html" ).first();

                expect( result.sources ).notToBeEmpty();
                expect( result.sources[ 1 ].path ).toBe( variables.logPath );
                expect( message.from ).toBe( "sender@example.com" );
                expect( message.to ).toBe( "recipient@example.com" );
                expect( message.subject ).toBe( "Verify your email" );
            } );

            it( "returns the rendered body and complete source for a selected message", function() {
                var service = getInstance( "MailLogService@cbmailservices" );
                var summary = service
                    .listMessages()
                    .messages
                    .filter( ( item ) => item.fileName == "mail.viewer-test.html" )
                    .first();
                var message = service.findMessage( summary.id );

                expect( trim( message.preview ) ).toBe( "<h1>Verify your email</h1>" );
                expect( message.source ).toInclude( "data-cbmailservices-log" );
            } );

            it( "parses existing File protocol logs without viewer metadata", function() {
                var service = getInstance( "MailLogService@cbmailservices" );
                var summary = service
                    .listMessages()
                    .messages
                    .filter( ( item ) => item.fileName == "mail.viewer-legacy-test.html" )
                    .first();
                var message = service.findMessage( summary.id );

                expect( message.from ).toBe( "old-sender@example.com" );
                expect( message.to ).toBe( "old-recipient@example.com" );
                expect( message.subject ).toBe( "Existing log" );
                expect( trim( message.preview ) ).toBe( "<p>Already on disk</p>" );
            } );

            it( "registers the viewer route in development", function() {
                var event = execute( route = "/cbmailservices/log", renderResults = true );

                expect( event.getStatusCode() ).toBe( 200 );
                expect( event.getRenderedContent() ).toInclude( "cbMailServices Log" );
            } );

            it( "returns browser-ready JSON field casing", function() {
                var event = execute( route = "/cbmailservices/log/messages", renderResults = true );

                expect( event.getStatusCode() ).toBe( 200 );
                expect( event.getRenderedContent() ).toInclude( """messages""" );
                expect( event.getRenderedContent() ).toInclude( """sources""" );
                expect( event.getRenderedContent() ).toInclude( """fileName""" );
            } );

            it( "refuses the viewer outside development", function() {
                var controller = getController();
                var originalEnvironment = controller.getSetting( "environment" );

                try {
                    controller.setSetting( "environment", "production" );
                    var event = execute( route = "/cbmailservices/log", renderResults = true );

                    expect( event.getStatusCode() ).toBe( 404 );
                    expect( event.getRenderedContent() ).notToInclude( "cbMailServices Log" );
                } finally {
                    controller.setSetting( "environment", originalEnvironment );
                }
            } );

            it( "returns a 404 for an unknown message id", function() {
                var event = execute( route = "/cbmailservices/log/message/unknown", renderResults = true );

                expect( event.getStatusCode() ).toBe( 404 );
                expect( event.getRenderedContent() ).toInclude( "Mail log not found." );
            } );
        } );
    }

}
