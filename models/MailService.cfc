/**
 ********************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 ********************************************************************************
 * @author Luis Majano <lmajano@ortussolutions.com>
 * ----
 * The ColdBox Mail Service is used to send emails in a fluent and human fashion.
 */
component accessors="true" singleton threadsafe {

	// DI
	property name="inteceptorService" inject="coldbox:interceptorService";
	property name="settings" inject="coldbox:moduleSettings:cbmailservices";
	property name="wirebox" inject="wirebox";
	property name="log" inject="logbox:logger:{this}";

	/**
	 * The token marker used for token replacements, default is `@`
	 */
	property name="tokenMarker";

	/**
	 * A mail settings bean configuration object that mimics all settings needed for sending mail
	 */
	property name="mailSettings";

	/**
	 * Constructor
	 */
	MailService function init(){
		variables.tokenMarker  = "@";
		variables.mailSettings = "";
		return this;
	}

	/**
	 * Prepare the mail services for operation
	 */
	function onDIComplete(){
		// Mail Token Symbol
		variables.tokenMarker  = variables.settings.tokenMarker;
		// Mail Settings Bean
		variables.mailSettings = variables.wirebox
			.getInstance( "MailSettingsBean@cbmailservices" )
			// Seed the mail settings with the global app settings
			.configure( argumentCollection = variables.settings );
	}

	/**
	 * Get a new Mail payload object, just use config() on it to prepare it or pass in all the arguments via this method
	 * All arguments passed to this method will be bound into the returning Mail object.
	 */
	Mail function newMail(){
		var mail = variables.wirebox.getInstance(
			name          = "Mail@cbmailservices",
			initArguments = arguments
		);

		// If mail payload does not have a server and one is defined in the mail settings, use that
		if (
			NOT mail.propertyExists( "server" ) AND len(
				variables.mailSettings.getValue( "server" )
			)
		) {
			mail.setServer( variables.mailSettings.getValue( "server" ) );
		}
		// Same with username, password, port, useSSL and useTLS
		if (
			NOT mail.propertyExists( "username" ) AND len(
				variables.mailSettings.getValue( "username" )
			)
		) {
			mail.setUsername( variables.mailSettings.getValue( "username" ) );
		}
		if (
			NOT mail.propertyExists( "password" ) AND len(
				variables.mailSettings.getValue( "password" )
			)
		) {
			mail.setPassword( variables.mailSettings.getValue( "password" ) );
		}
		if (
			NOT mail.propertyExists( "port" ) AND len( variables.mailSettings.getValue( "port" ) ) and variables.mailSettings.getValue(
				"port"
			) NEQ 0
		) {
			mail.setPort( variables.mailSettings.getValue( "port" ) );
		}
		if (
			NOT mail.propertyExists( "useSSL" ) AND len(
				variables.mailSettings.getValue( "useSSL", "" )
			)
		) {
			mail.setUseSSL( variables.mailSettings.getValue( "useSSL" ) );
		}
		if (
			NOT mail.propertyExists( "useTLS" ) AND len(
				variables.mailSettings.getValue( "useTLS", "" )
			)
		) {
			mail.setUseTLS( variables.mailSettings.getValue( "useTLS" ) );
		}
		// set default mail attributes if the variables.MailSettings bean has values
		if ( NOT len( mail.getTo() ) AND len( variables.mailSettings.getValue( "to", "" ) ) ) {
			mail.setTo( variables.mailSettings.getValue( "to" ) );
		}
		if ( NOT len( mail.getFrom() ) AND len( variables.mailSettings.getValue( "from", "" ) ) ) {
			mail.setFrom( variables.mailSettings.getValue( "from" ) );
		}
		if (
			( NOT mail.propertyExists( "bcc" ) OR NOT len( mail.getBcc() ) ) AND len(
				variables.mailSettings.getValue( "bcc", "" )
			)
		) {
			mail.setBcc( variables.mailSettings.getValue( "bcc" ) );
		}
		if (
			( NOT mail.propertyExists( "replyto" ) OR NOT len( mail.getReplyTo() ) ) AND len(
				variables.mailSettings.getValue( "replyto", "" )
			)
		) {
			mail.setReplyTo( variables.mailSettings.getValue( "replyto" ) );
		}
		if (
			( NOT mail.propertyExists( "type" ) OR NOT len( mail.getType() ) ) AND len(
				variables.mailSettings.getValue( "type", "" )
			)
		) {
			mail.setType( variables.mailSettings.getValue( "type" ) );
		}

		return mail;
	}

	/**
	 * Send an email payload. Returns a struct: [error:boolean, messages:array]
	 *
	 * @mail The mail payload to send.
	 *
	 * @return { error:boolean, messages:array }
	 */
	struct function send( required Mail mail ){
		var rtnStruct = { "error" : true, "messages" : [] }

		// Validate Basic Mail Fields and error out
		if ( NOT arguments.mail.validate() ) {
			arrayAppend(
				rtnStruct.messages,
				"Please check the basic mail fields of To, From and Body as they are empty. To: #arguments.mail.getTo()#, From: #arguments.mail.getFrom()#, Body Len = #arguments.mail.getBody().length()#."
			);
			log.error( "Mail object does not validate.", arguments.mail.getConfig() );
			return rtnStruct;
		}

		// Parse Body Tokens
		parseTokens( arguments.mail );

		// Just mail the darned thing!!
		try {
			// announce interception point before mail send
			variables.inteceptorService.processState( "preMailSend", { mail : arguments.mail } );

			// We mail it using the protocol which is defined in the mail settings.
			rtnStruct = variables.mailSettings.getTransit().send( arguments.mail );

			// announce interception point after mail send
			variables.inteceptorService.processState(
				"postMailSend",
				{ mail : arguments.mail, result : rtnStruct }
			);
		} catch ( Any e ) {
			writeDump( var = e );
			abort;
			arrayAppend(
				rtnStruct.messages,
				"Error sending mail. #e.message# : #e.detail# : #e.stackTrace#"
			);
			log.error( "Error sending mail. #e.message# : #e.detail# : #e.stackTrace#", e );
		}

		return rtnStruct;
	}

	/**
	 * Parse the tokens and do body replacements.
	 *
	 * @mail The mail payload to use for parsing and usage.
	 */
	function parseTokens( required mail ){
		var tokens      = arguments.mail.getBodyTokens();
		var body        = arguments.mail.getBody();
		var mailParts   = arguments.mail.getMailParts();
		var tokenMarker = getTokenMarker();
		var key         = "";

		// Check mail parts for content
		if ( arrayLen( mailparts ) ) {
			// Loop over mail parts
			for ( var mailPart = 1; mailPart lte arrayLen( mailParts ); mailPart++ ) {
				body = mailParts[ mailPart ].body;
				for ( key in tokens ) {
					body = replaceNoCase(
						body,
						"#tokenMarker##key##tokenMarker#",
						tokens[ key ],
						"all"
					);
				}
				mailParts[ mailPart ].body = body;
			}
		}

		// Do token replacement on the body text
		for ( var key in tokens ) {
			body = replaceNoCase(
				body,
				"#tokenMarker##key##tokenMarker#",
				tokens[ key ],
				"all"
			);
		}

		// replace back the body
		arguments.mail.setBody( body );
	}

}
