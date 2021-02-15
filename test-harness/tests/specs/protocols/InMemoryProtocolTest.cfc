component extends="coldbox.system.testing.BaseTestCase" {
    
    this.loadColdBox = false;

    public void function setup() {
        // Create a mock instance of the protocol.
        variables.protocol = getMockBox().createMock( className = "cbmailservices.models.protocols.InMemoryProtocol" ).init( {} );
    }

    public void function testSend() {
        // 1:Mail with No Params
        var payloadA = getMockBox().createMock( className = "cbmailservices.models.Mail" ).init()
            .config( from = "info@coldbox.org", to = "automation@coldbox.org", type = "html" );
        payloadA.setBodyTokens( { "name": "Luis Majano", "time": dateformat( now(), "full" ) } );
        payloadA.setBody( "<h1>Hello @name@, how are you today?</h1>  <p>Today is the <b>@time@</b>.</p> <br/><br/><a href=""http://www.coldbox.org"">ColdBox Rules!</a>" );
        payloadA.setSubject( "Mail NO Params-Hello Luis" );
        variables.protocol.send( payloadA );


        // 2:Mail with params
        var payloadB = getMockBox().createMock( className = "cbmailservices.models.Mail" ).init()
            .config( from = "info@coldbox.org", to = "automation@coldbox.org", subject = "Mail With Params - Hello Luis" );
        payloadB.setBody( "Hello This is my great unit test" );
        payloadB.addMailParam( name = "Disposition-Notification-To", value = "info@coldbox.org" );
        payloadB.addMailParam( name = "Importance", value = "High" );
        variables.protocol.send( payloadB );

        // 3:Mail multi-part no params
        var payloadC = getMockBox().createMock( className = "cbmailservices.models.Mail" ).init()
            .config( from = "info@coldbox.org", to = "automation@coldbox.org", subject = "Mail MultiPart No Params - Hello Luis" );
        payloadC.addMailPart( type = "text", body = "You are reading this message as plain text, because your mail reader does not handle it." );
        payloadC.addMailPart( type = "html", body = "This is the body of the message." );
        variables.protocol.send( payloadC );

        // 4:Mail multi-part with params
        var payloadD = getMockBox().createMock( className = "cbmailservices.models.Mail" ).init()
            .config( from = "info@coldbox.org", to = "automation@coldbox.org", subject = "Mail MultiPart With Params - Hello Luis" );
        payloadD.addMailPart( type = "text", body = "You are reading this message as plain text, because your mail reader does not handle it.");
        payloadD.addMailPart( type = "html", body = "This is the body of the message.");
        payloadD.addMailParam( name = "Disposition-Notification-To", value = "info@coldbox.org" );
        variables.protocol.send( payloadD );

        var messages = variables.protocol.getMail();
        expect( messages ).toBeArray();
        expect( messages ).toHaveLength( 4 );
        expect( messages[ 1 ] ).toBe( payloadA.getMemento() );
        expect( messages[ 2 ] ).toBe( payloadB.getMemento() );
        expect( messages[ 3 ] ).toBe( payloadC.getMemento() );
        expect( messages[ 4 ] ).toBe( payloadD.getMemento() );
    }

    public void function testHasMessage() {
        variables.protocol.reset();
        var sentPayload = getMockBox().createMock( className = "cbmailservices.models.Mail" ).init()
            .config( from = "info@coldbox.org", to = "sent@coldbox.org", type = "html" );
        sentPayload.setBodyTokens( { "name": "Luis Majano", "time": dateformat( now(), "full" ) } );
        sentPayload.setBody( "<h1>Hello @name@, how are you today?</h1>  <p>Today is the <b>@time@</b>.</p> <br/><br/><a href=""http://www.coldbox.org"">ColdBox Rules!</a>" );
        sentPayload.setSubject( "Mail SENT" );
        variables.protocol.send( sentPayload );

        var unsentPayload = getMockBox().createMock( className = "cbmailservices.models.Mail" ).init()
            .config( from = "info@coldbox.org", to = "unsent@coldbox.org", type = "html" );
        unsentPayload.setBodyTokens( { "name": "Luis Majano", "time": dateformat( now(), "full" ) } );
        unsentPayload.setBody( "<h1>Hello @name@, how are you today?</h1>  <p>Today is the <b>@time@</b>.</p> <br/><br/><a href=""http://www.coldbox.org"">ColdBox Rules!</a>" );
        unsentPayload.setSubject( "Mail NOT SENT" );

        expect( variables.protocol.hasMessage( function( mail ) {
            return mail.from == sentPayload.getMemento().from &&
                mail.to == sentPayload.getMemento().to;
        } ) ).toBeTrue( "hasMessage should return true for message that was sent." );
        
        expect( variables.protocol.hasMessage( function( mail ) {
            return mail.from == unsentPayload.getMemento().from &&
                mail.to == unsentPayload.getMemento().to;
        } ) ).toBeFalse( "hasMessage should return true for message that was not sent." );
    }

}