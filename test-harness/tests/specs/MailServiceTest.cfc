component extends="coldbox.system.testing.BaseTestCase"{

	// Making sure ColdBox is unloaded, so mocks don't collide.
	this.unloadColdBox = true;
	
	function setup(){
		super.setup();
		ms = prepareMock( getInstance( "MailService@cbmailservices" ) );
	}

	function testNewMail(){
		var mail = ms.newMail();
		expect(	mail ).toBeComponent();
	}

	function testparseTokens(){
		ms.setTokenMarker( "@" );
		var mail 	= ms.newMail();
		var tokens 	= { "name"="Luis Majano", "time"=dateformat(now(),"full" ) };
		
		mail.setBodyTokens( tokens );
		mail.setBody( "Hello @name@, how are you today? Today is the @time@" );

		ms.parseTokens( mail );
		
		//debug( mail.getBody() );
		expect(	mail.getBody() ).toBe( "Hello #tokens.name#, how are you today? Today is the #tokens.time#" );
	}

	function testparseTokensCustom(){
		ms.setTokenMarker( "$" );
		var mail = ms.newMail();
		var tokens = {name="Luis Majano",time=dateformat(now(),"full")};
		
		mail.setBodyTokens(tokens);
		mail.setBody("Hello $name$, how are you today? Today is the $time$");

		ms.parseTokens(mail);

		expect(	mail.getBody() ).toBe( "Hello #tokens.name#, how are you today? Today is the #tokens.time#" );
	}

	function testSend(){
		// mockings
		mockProtocol = createStub().$("send", {error=false,errorArray=[]} );
		prepareMock( ms.getMailSettings() ).$( "getTransit", mockProtocol );

		// 1:Mail with No Params
		mail = ms.newMail().config(from="info@coldbox.org",to="automation@coldbox.org",type="html");
		tokens = {name="Luis Majano",time=dateformat(now(),"full")};
		mail.setBodyTokens(tokens);
		mail.setBody("<h1>Hello @name@, how are you today?</h1>  <p>Today is the <b>@time@</b>.</p> <br/><br/><a href=""http://www.coldbox.org"">ColdBox Rules!</a>");
		mail.setSubject("Mail NO Params-Hello Luis");
		rtn = ms.send(mail);
		assertTrue( mockProtocol.$once("send") );
		//debug(rtn);

		// 2:Mail with params
		mail = ms.newMail().config(from="info@coldbox.org",to="automation@coldbox.org",subject="Mail With Params - Hello Luis");
		mail.setBody("Hello This is my great unit test");
		mail.addMailParam(name="Disposition-Notification-To",value="info@coldbox.org");
		mail.addMailParam(name="Importance",value="High");
		rtn = ms.send(mail);
		assertTrue( mockProtocol.$times(2,"send") );
		//debug(rtn);

		// 3:Mail multi-part no params
		mail = ms.newMail().config(from="info@coldbox.org",to="automation@coldbox.org",subject="Mail MultiPart No Params - Hello Luis");
		mail.addMailPart(type="text",body="You are reading this message as plain text, because your mail reader does not handle it.");
		mail.addMailPart(type="html",body="This is the body of the message.");
		rtn = ms.send(mail);
		assertTrue( mockProtocol.$times(3,"send") );
		//debug(rtn);

		// 4:Mail multi-part with params
		mail = ms.newMail().config(from="info@coldbox.org",to="automation@coldbox.org",subject="Mail MultiPart With Params - Hello Luis");
		mail.addMailPart(type="text",body="You are reading this message as plain text, because your mail reader does not handle it.");
		mail.addMailPart(type="html",body="This is the body of the message.");
		mail.addMailParam(name="Disposition-Notification-To",value="info@coldbox.org");
		rtn = ms.send(mail);
		assertTrue( mockProtocol.$times(4,"send") );
		//debug(rtn);
	}

	function testMailWithSettings(){
		// Mocks
		mockProtocol = createStub().$( "send", {error=false,errorArray=[]} );
		mockSettings = prepareMock( 
			getInstance( 
				name 			= "cbmailservices.models.MailSettingsBean", 
				initArguments	= {
					server = "0.0.0.0", username="test", password="Test", port="25"
				} 
			) 
		)
		.$( "getTransit", mockProtocol);
		
		ms.setMailSettings( mockSettings );

		mail = ms.newMail(from="info@coldbox.org",to="automation@coldbox.org",type="html",body="TestMailWithSettings",subject="TestMailWithSettings");
		ms.send( mail );
		assertTrue( mockProtocol.$once("send") );

		// Test with No settings
		ms.setMailSettings( prepareMock( getInstance( "cbmailservices.models.MailSettingsBean" )  ) );
		mockProtocol = createStub().$( "send", {error=false,errorArray=[]} );
		prepareMock( ms.getMailSettings() ).$("getTransit", mockProtocol );
		mail = ms.newMail(from="info@coldbox.org",to="automation@coldbox.org",type="html",body="TestMailWithSettings",subject="TestMailWithSettings");
		ms.send( mail );
		assertTrue( mockProtocol.$once("send") );
		//debug( mail.getMemento() );
	}

}