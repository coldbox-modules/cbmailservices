/**
 * *******************************************************************************
 * Copyright 2010 Agri Tracking Systems
 * www.agritrackingsystems.com
 * *******************************************************************************
 * ----
 * This protocol sends the mails via the Mailgun API.  The required properties are:
 * - apikey : The mailgun secret api key
 * - domain : The mailgun domain to send the email through
 *
 * An optional property, "baseURL" is required when using an EU region
 * - baseURL : The mailgun region where the Mailgun domain was created
 *
 * @author Scott Steinbeck <ssteinbeck@agritrackingsystems.com>
 */
component
	extends="cbmailservices.models.AbstractProtocol"
	singleton
	accessors="true"
{

	/**
	 * Initialize the Mailgun protocol
	 *
	 * @properties A map of configuration properties for the protocol
	 */
	MailgunProtocol function init( struct properties = {} ){
		variables.name            = "Mailgun";
		variables.DEFAULT_TIMEOUT = 30; // in seconds
		// super size it
		super.init( argumentCollection = arguments );

		// Property Checks
		if ( !propertyExists( "domain" ) ) {
			// No API key was found, so throw an exception.
			throw( message = "Domain is Required", type = "MailgunProtocol.PropertyNotFound" );
		}

		// Property Checks
		if ( !propertyExists( "APIKey" ) ) {
			// No API key was found, so throw an exception.
			throw( message = "ApiKey is Required", type = "MailgunProtocol.PropertyNotFound" );
		}

		// Check for Base URL property
		if ( !propertyExists( "baseURL" ) ) {
			// No baseURL key was found, so use the US default.
			variables.MAILGUN_APIURL  = "https://api.mailgun.net/v3/";
		} else {
			variables.MAILGUN_APIURL = getProperty( "baseURL" );
		}

		return this;
	}

	/**
	 * Send it to mailgun
	 *
	 * The return is a struct with two keys
	 * - `error` - A boolean flag if the message was sent or not
	 * - `messages` - An array of error messages the protocol stored if any
	 *
	 * @see                 https://documentation.mailgun.com/en/latest/api-sending.html
	 * @payload             The paylod object to send the message with
	 * @payload.doc_generic cbmailservices.models.Mail
	 *
	 * @return struct of { "error" : boolean, "messages" : [], "messageID" : "" }
	 */
	struct function send( required cbmailservices.models.Mail payload ){
		var results = { "error" : true, "messages" : [], "messageID" : "" };
		// The mail config data
		var data    = arguments.payload.getConfig();
		var headerKeys = [ "v:", "o:", "h:" ];

		// Special attribute for Reply To
		if ( data.keyExists( "replyto" ) ) {
			data[ "h:Reply-To" ] = data[ "replyto" ];
			data.delete( "replyto" );
		}

		// Special attribute for Testing
		if ( data.keyExists( "test" ) ) {
			data[ "o:testmode" ] = data[ "test" ];
			data.delete( "test" );
		}

		// Process the mail headers
		arguments.payload
			.getMailParams()
			.filter( function( thisParam ){
				return structKeyExists( arguments.thisParam, "name" );
			} )
			.each( function( header ){
				var key = header.name;
				if ( !headerKeys.find( left( key, 2 ) ) ) key = "h:" & key;
				data[ key ] = header.value;
			} );


		data[ "additionalInfo" ].each( function( infoKey, infoValue ){
			data[ infoKey ] = infoValue;
		} );

		data.delete( "additionalInfo" ); // cleanup payload


		data[ "bodyTokens" ].each( function( tokenKey, tokenValue ){
			data[ "v:" & tokenKey ] = tokenValue;
		} );

		data.delete( "bodyTokens" ); // cleanup payload

		// Process the mail attachments and encode them how mailgun likes them
		var attachments = arguments.payload
			.getMailParams()
			.filter( function( thisParam ){
				return structKeyExists( arguments.thisParam, "file" );
			} );


		// Process the body of the email according to Mailgun Rules If it was set directly.
		// https://mailgunapp.com/developer/user-guide/send-email-with-api
		if ( structKeyExists( data, "type" ) and data.type eq "html" ) {
			data[ "html" ] = data.body;
		} else {
			data[ "text" ] = data.body;
		}

		// Process the mail parts in case the body type and content was done via mail parts
		arguments.payload
			.getMailParts()
			.each( function( mailPart ){
				if ( arguments.mailPart.type eq "html" ) {
					data[ "html" ] = arguments.mailpart.body;
				} else if ( arguments.mailpart.type eq "plain" || arguments.mailpart.type eq "text" ) {
					data[ "text" ] = arguments.mailpart.body;
				}
			} );


		// clean up unnecessary keys in payload
		data.delete( "mailParams" );
		data.delete( "mailParts" );

		// send to mailgun
		return sendToMailgun( data, attachments );
	}

	/**
	 * Send a json payload to mailgun
	 *
	 * @jsonPayload The json payload to send
	 */
	private function sendToMailgun( required messageParams, attachments = [] ){
		var results = { "error" : true, "messages" : [], "messageID" : "" };

		try {
			var httpResults = "";
			var apiURL      = variables.MAILGUN_APIURL & getProperty( "domain" ) & "/messages";

			cfhttp(
				method       = "post",
				url          = apiURL,
				charset      = "utf-8",
				result       = "httpResults",
				redirect     = true,
				throwOnError = false,
				timeout      = variables.DEFAULT_TIMEOUT,
				useragent    = "ColdFusion-cbMailServices",
				username     = "api",
				password     = getProperty( "apiKey" )
			) {
				cfhttpparam(
					type  = "header",
					name  = "Accept",
					value = "application/json"
				);
				arguments.messageParams.each( function( paramName, paramValue ){
					cfhttpparam(
						type    = "formfield",
						encoded = "no",
						name    = paramName,
						value   = paramValue
					);
				} );

				arguments.attachments.each( function( attachment ){
					cfhttpparam(
						type    = "file",
						encoded = "no",
						name    = "attachment",
						file    = expandPath( attachment.file )
					);
				} );
			}

			// Inflate HTTP Results
			if( isJSON( httpResults.fileContent.toString() ) ) {
				var mailgunResults = deserializeJSON( httpResults.fileContent.toString() );
			} else {
				results.messages = [ 'Error sending mail. Mailgun returned "#httpResults.fileContent.toString()#".' ];

				return results;
			}

			// Process Mailgun Results
			if ( mailgunResults.message eq "Queued. Thank you." ) {
				results.error     = false;
				results.messageID = mailgunResults[ "id" ]
				if ( arguments.messageParams.keyExists( "o:testmode" ) && arguments.messageParams[ "o:testmode" ] ) {
					results.messages = [ "Test message sent" ];
				}
			}
			// Exceptions
			else {
				results.messages = [
					mailgunResults[ "Message" ],
					mailgunResults
				];
			}
		} catch ( any e ) {
			results.messages = [ "Error sending mail. #e.message# : #e.detail# : #e.stackTrace#" ];
		}

		return results;
	}

}
