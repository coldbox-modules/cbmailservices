<cfcomponent name="configBeanTest" extends="coldbox.system.testing.BaseTestCase">

	<cfset this.loadColdBox = false>

	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			mail = createObject("component","cbmailservices.models.Mail").init();
		</cfscript>
	</cffunction>

	<!--- Begin specific tests --->
	<cffunction name="testConfig" access="public" returnType="void">
		<cfscript>
			mail.config(from="lmajano@mail.com");

			assertEquals( "lmajano@mail.com", mail.getFrom() );
		</cfscript>
	</cffunction>

	<cffunction name="testBodyTokens" access="public" returnType="void">
		<cfscript>
			assertTrue( structisEmpty(mail.getBodyTokens()) );
		</cfscript>
	</cffunction>

	<cffunction name="testMailParts" access="public" returnType="void">
		<cfscript>
			assertFalse( arrayLen(mail.getMailParts()) );

			mail.addmailPart(type="mypart",body="this is my body");

			assertTrue( arrayLen(mail.getMailParts()) );

		</cfscript>
	</cffunction>

	<cffunction name="testMailParams" access="public" returnType="void">
		<cfscript>
			assertFalse( arrayLen(mail.getMailParams()) );

			mail.addMailParam(contentid="123",type="file",file="c:\test.tmp");

			assertTrue( arrayLen(mail.getMailParams()) );

		</cfscript>
	</cffunction>

	<cffunction name="testValidate" access="public" returnType="void">
		<cfscript>

			assertFalse( mail.validate() );

			mail.config(subject="Hello",from='lmajano@mail.com',to="lmajano@mail.com",body="Hello");

			assertTrue( mail.validate() );

		</cfscript>
	</cffunction>

	<cffunction name="testSetHTML" access="public" returnType="void">
		<cfscript>

			mail.config(subject="Hello",from='lmajano@mail.com',to="lmajano@mail.com",body="Hello");
			mail.setHTML('What up Dude');

			//debug( mail.getMailParts() );
			assertTrue( arrayLen(mail.getMailParts()) );
			parts = mail.getMailParts();
			assertEquals( 'text/html', parts[1].type );

		</cfscript>
	</cffunction>

	<cffunction name="testSetText" access="public" returnType="void">
		<cfscript>

			mail.config(subject="Hello",from='lmajano@mail.com',to="lmajano@mail.com",body="Hello");
			mail.setText('What up Dude');

			//debug( mail.getMailParts() );
			assertTrue( arrayLen(mail.getMailParts()) );
			parts = mail.getMailParts();
			assertEquals( 'text/plain', parts[1].type );

		</cfscript>
	</cffunction>

	<cffunction name="testSetReceipts" access="public" returnType="void">
		<cfscript>

			mail.config(subject="Hello",from='lmajano@mail.com',to="lmajano@mail.com",body="Hello");
			mail.setSendReceipt('lmajano@coldbox.org').setReadReceipt('lmajano@coldbox.org');

			//debug( mail.getMailParts() );
			assertTrue( arrayLen(mail.getMailParams()) );
			params = mail.getMailParams();
			assertEquals( 'Return-Receipt-To', params[1].name );
			assertEquals( 'Read-Receipt-To', params[2].name );

		</cfscript>
	</cffunction>

	<cffunction name="testAddAttachements" access="public" returnType="void">
		<cfscript>

			mail.config(subject="Hello",from='lmajano@mail.com',to="lmajano@mail.com",body="Hello");
			files = ['file1','file2'];
			mail.addAttachments(files, true);

			debug( mail.getMailParams() );
			assertTrue( arrayLen(mail.getMailParams()) );
			params = mail.getMailParams();
			debug( params );
			assertEquals( files[1], params[1].file );
			assertEquals( true, params[1].remove );
			assertEquals( files[2], params[2].file );
			assertEquals( true, params[2].remove );


		</cfscript>
	</cffunction>

	<cffunction name="testAdditionalInfoConfig" access="public" returnType="void">
		<cfscript>
			mail.config(additionalInfo= { "categories":"Spam" } );

			assertEquals( { "categories":"Spam" }, mail.getAdditionalInfo( ) );
		</cfscript>
	</cffunction>

	<cffunction name="testAdditionalInfoSetter" access="public" returnType="void">
		<cfscript>
			mail.setAdditionalInfo( { "categories":"Spam2" } );

			assertEquals( { "categories":"Spam2" }, mail.getAdditionalInfo( ) );
		</cfscript>
	</cffunction>

	<cffunction name="testAdditionalInfoItemSetter" access="public" returnType="void">
		<cfscript>
			mail.setAdditionalInfoItem( "categories", "Spam3" );

			assertEquals( { "categories":"Spam3" }, mail.getAdditionalInfo( ) );
		</cfscript>
	</cffunction>

	<cffunction name="testAdditionalInfoItemGetter" access="public" returnType="void">
		<cfscript>
			mail.setAdditionalInfoItem( "categories", "Spam4" );

			assertEquals( { "categories":"Spam4" }, mail.getAdditionalInfo( ) );
			assertEquals( "Spam4", mail.getAdditionalInfoItem( "categories" ) );
		</cfscript>
	</cffunction>

</cfcomponent>

