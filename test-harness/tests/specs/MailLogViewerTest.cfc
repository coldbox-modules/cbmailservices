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
        variables.secondaryLogPath = getTempDirectory() & "cbmailservices-mail-log-secondary";
        if ( !directoryExists( variables.secondaryLogPath ) ) {
            directoryCreate( variables.secondaryLogPath );
        }
        variables.secondaryLogPath = createObject( "java", "java.io.File" )
            .init( variables.secondaryLogPath )
            .getCanonicalPath();
        getInstance( "MailService@cbmailservices" ).registerMailer(
            name = "secondary-files",
            class = "File",
            properties = { filePath: variables.secondaryLogPath, autoExpand: false }
        );
        variables.secondaryFixture = variables.secondaryLogPath & "/mail.viewer-secondary-test.html";
    }

    function afterAll() {
        getInstance( "MailService@cbmailservices" ).getMailers().delete( "secondary-files" );
        if ( fileExists( variables.fixture ) ) {
            fileDelete( variables.fixture );
        }
        if ( fileExists( variables.legacyFixture ) ) {
            fileDelete( variables.legacyFixture );
        }
        if ( fileExists( variables.secondaryFixture ) ) {
            fileDelete( variables.secondaryFixture );
        }
        if ( directoryExists( variables.secondaryLogPath ) ) {
            directoryDelete( variables.secondaryLogPath );
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
                fileWrite(
                    variables.secondaryFixture,
                    "<div hidden data-cbmailservices-log data-from=""sender@example.com"" data-to=""recipient@example.com"" data-subject=""Secondary mailer"" data-sent=""2026-08-27T14:01:00-06:00""></div><hr/>Mail Body<hr/><h1>Secondary mailer</h1>"
                );
            } );

            it( "discovers configured File protocol directories and messages", function() {
                var result = getInstance( "MailLogService@cbmailservices" ).listMessages();
                var source = result.sources.filter( ( item ) => item.mailer == "files" ).first();
                var message = result.messages.filter( ( item ) => item.fileName == "mail.viewer-test.html" ).first();

                expect( result.sources ).notToBeEmpty();
                expect( source.path ).toBe( variables.logPath );
                expect( message.from ).toBe( "sender@example.com" );
                expect( message.to ).toBe( "recipient@example.com" );
                expect( message.subject ).toBe( "Verify your email" );
            } );

            it( "discovers every configured File protocol mailer", function() {
                var result = getInstance( "MailLogService@cbmailservices" ).listMessages();
                var sourcesByMailer = result.sources.reduce( ( sources, source ) => {
                    sources[ source.mailer ] = source.path;
                    return sources;
                }, {} );

                expect( sourcesByMailer ).toHaveKey( "files" );
                expect( sourcesByMailer ).toHaveKey( "secondary-files" );
                expect( sourcesByMailer[ "files" ] ).toBe( variables.logPath );
                expect( sourcesByMailer[ "secondary-files" ] ).toBe( variables.secondaryLogPath );
                expect( result.messages.filter( ( message ) => message.mailer == "secondary-files" ) ).notToBeEmpty();
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

            it( "deletes one message without touching other logs", function() {
                var service = getInstance( "MailLogService@cbmailservices" );
                var summary = service
                    .listMessages()
                    .messages
                    .filter( ( item ) => item.fileName == "mail.viewer-test.html" )
                    .first();

                expect( service.deleteMessage( summary.id ) ).toBeTrue();
                expect( fileExists( variables.fixture ) ).toBeFalse();
                expect( fileExists( variables.legacyFixture ) ).toBeTrue();
                expect( service.deleteMessage( summary.id ) ).toBeFalse();
            } );

            it( "deletes a selected set of messages", function() {
                var service = getInstance( "MailLogService@cbmailservices" );
                var ids = service
                    .listMessages()
                    .messages
                    .filter( ( item ) => item.fileName == "mail.viewer-test.html" )
                    .map( ( item ) => item.id );
                var result = service.deleteMessages( ids );

                expect( result.count ).toBe( 1 );
                expect( result.deleted ).toBe( ids );
                expect( fileExists( variables.fixture ) ).toBeFalse();
                expect( fileExists( variables.legacyFixture ) ).toBeTrue();
            } );

            it( "deletes all configured File protocol logs", function() {
                var service = getInstance( "MailLogService@cbmailservices" );
                var result = service.deleteAllMessages();

                expect( result.count >= 2 ).toBeTrue();
                expect( service.listMessages().messages ).toBeEmpty();
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
                var renderedContent = event.getRenderedContent();

                expect( event.getStatusCode() ).toBe( 200 );
                expect( renderedContent ).toInclude( "cbMailServices Log" );
                expect( renderedContent ).toInclude( "theme-toggle" );
                expect( renderedContent ).toInclude( "prefers-color-scheme: dark" );
                expect( renderedContent ).toInclude( "cbmailservices-log-theme" );
                expect( renderedContent ).toInclude( "delete-selected" );
                expect( renderedContent ).toInclude( "delete-all" );
                expect( renderedContent ).toInclude( "delete-message" );
                expect( renderedContent ).toInclude( "preparePreviewHTML" );
                expect( renderedContent ).toInclude( "querySelectorAll( ""a[href], area[href]"" )" );
                expect( renderedContent ).toInclude( "setAttribute( ""target"", ""_blank"" )" );
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
