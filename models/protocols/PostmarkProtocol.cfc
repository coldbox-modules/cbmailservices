/**
 * *******************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * *******************************************************************************
 * ----
 * This protocol sends the mails via the Postmark API.  The required properties are:
 * - apike : The postmark api key
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component
	extends="cbmailservices.models.AbstractProtocol"
	singleton
	accessors="true"
{

	/**
	 * Initialize the InMemory protocol
	 *
	 * @properties A map of configuration properties for the protocol
	 */
	PostmarkProtocol function init( struct properties = {} ){
		variables.name            = "Postmark";
		variables.POSTMARK_APIURL = "https://api.postmarkapp.com/email";
		variables.DEFAULT_TIMEOUT = 30; // in seconds

		// super size it
		super.init( argumentCollection = arguments );

		// Property Checks
		if ( NOT propertyExists( "APIKey" ) ) {
			// No API key was found, so throw an exception.
			throw( message = "ApiKey is Required", type = "PostmarkProtocol.PropertyNotFound" );
		}

		return this;
	}

	/**
	 * Send it to postmark
	 *
	 * The return is a struct with two keys
	 * - `error` - A boolean flag if the message was sent or not
	 * - `messages` - An array of error messages the protocol stored if any
	 *
	 * @see                 https://postmarkapp.com/developer/user-guide/send-email-with-api
	 * @payload             The paylod object to send the message with
	 * @payload.doc_generic cbmailservices.models.Mail
	 *
	 * @return struct of { "error" : boolean, "messages" : [], "messageID" : "" }
	 */
	struct function send( required cbmailservices.models.Mail payload ){
		var results = { "error" : true, "messages" : [], "messageID" : "" };
		// The mail config data
		var data    = arguments.payload.getConfig();

		// Process the mail headers
		data[ "Headers" ] = arguments.payload
			.getMailParams()
			.filter( function( thisParam ){
				return structKeyExists( arguments.thisParam, "name" );
			} );

		// Process the mail attachments and encode them how postmark likes them
		data[ "Attachments" ] = arguments.payload
			.getMailParams()
			.filter( function( thisParam ){
				return structKeyExists( arguments.thisParam, "file" );
			} )
			.map( function( thisParam ){
				return encodeAttachment( arguments.thisParam );
			} );

		// Process the body of the email according to PostMark Rules If it was set directly.
		// https://postmarkapp.com/developer/user-guide/send-email-with-api
		if ( structKeyExists( data, "type" ) and data.type eq "html" ) {
			data[ "HtmlBody" ] = data.body;
		} else {
			data[ "TextBody" ] = data.body;
		}

		// Process the mail parts in case the body type and content was done via mail parts
		arguments.payload
			.getMailParts()
			.each( function( mailPart ){
				if ( arguments.mailPart.type eq "html" ) {
					data[ "HtmlBody" ] = arguments.mailpart.body;
				} else if ( arguments.mailpart.type eq "plain" || arguments.mailpart.type eq "text" ) {
					data[ "TextBody" ] = arguments.mailpart.body;
				}
			} );

		// send to postmark
		return sendToPostmark( serializeJSON( data ) );
	}

	/**
	 * Send a json payload to postmark
	 *
	 * @jsonPayload The json payload to send
	 */
	private function sendToPostmark( required jsonPayload ){
		var results = { "error" : true, "messages" : [], "messageID" : "" };

		try {
			var httpResults = "";

			cfhttp(
				method       = "post",
				url          = variables.POSTMARK_APIURL,
				charset      = "utf-8",
				result       = "httpResults",
				redirect     = true,
				throwOnError = true,
				timeout      = variables.DEFAULT_TIMEOUT,
				useragent    = "ColdFusion-cbMailServices"
			) {
				cfhttpparam(
					type  = "header",
					name  = "Accept",
					value = "application/json"
				);
				cfhttpparam(
					type  = "header",
					name  = "Content-type",
					value = "application/json"
				);
				cfhttpparam(
					type  = "header",
					name  = "X-Postmark-Server-Token",
					value = "#getProperty( "apiKey" )#"
				);
				cfhttpparam(
					type    = "body",
					encoded = "no",
					value   = arguments.jsonPayload
				);
			}

			// Inflate HTTP Results
			var postmarkResults = deserializeJSON( httpResults.fileContent.toString() );
			// Process Postmark Results
			if ( postmarkResults.message eq "OK" ) {
				results.error     = false;
				results.messageID = postmarkResults[ "MessageID" ]
			}
			// Test Messages
			else if ( findNoCase( "Test job", postmarkResults.message ) and postmarkResults.errorCode eq 0 ) {
				results.error     = false;
				results.messageID = postmarkResults[ "MessageID" ]
				results.messages  = [ "Test job accepted" ];
			}
			// Exceptions
			else {
				results.messages = [
					"#postmarkResults[ "ErrorCode" ]# - #postmarkResults[ "Message" ]#",
					postmarkResults
				];
			}
		} catch ( any e ) {
			results.messages = [ "Error sending mail. #e.message# : #e.detail# : #e.stackTrace#" ];
		}

		return results;
	}

	/**
	 * Encode an attachment like PostMark likes it
	 *
	 * @mailParam The structure representing the mail parameters
	 */
	private struct function encodeAttachment( required struct mailParam ){
		return {
			"Name"        : getFileFromPath( arguments.mailParam.file ),
			"Content"     : toBase64( fileReadBinary( arguments.mailParam.file ) ),
			"ContentType" : isNull( arguments.mailparam.fileType ) ? getFileMimeType( arguments.mailParam.file ) : arguments.mailParam.fileType
		};
	}

	/**
	 * Get the file mime type from the filepath
	 *
	 * @filePath The target file path
	 */
	private function getFileMimeType( required filePath ){
		return fileGetMimeType( arguments.filePath );
	}

}
