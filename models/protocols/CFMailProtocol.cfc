/**
 ********************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 ********************************************************************************
 * @author Robert Rawlings, Luis Majano <lmajano@ortussolutions.com>
 * ----
 * This protocol sends mail via the cfmail tag.
 */
component
	extends="cbmailservices.models.AbstractProtocol"
	singleton
	accessors="true"
{

	/**
	 * Initialize the File protocol
	 *
	 * @properties A map of configuration properties for the protocol
	 */
	CFMailProtocol function init( struct properties = {} ){
		variables.name = "CFMail";
		super.init( argumentCollection = arguments );
		return this;
	}

	/**
	 * Send mails to html files on disk
	 *
	 * The return is a struct with two keys
	 * - `error` - A boolean flag if the message was sent or not
	 * - `messages` - An array of error messages the protocol stored if any
	 *
	 * @payload The paylod object to send the message with
	 * @payload.doc_generic cbmailservices.models.Mail
	 *
	 * @return struct of { "error" : boolean, "messages" : [] }
	 */
	struct function send( required cbmailservices.models.Mail payload ){
		var results = { "error" : true, "messages" : [] };

		// Just mail the darned thing!!
		try {
			// Mail it
			mailIt( arguments.payload );
			// send success
			results.error = false;
		} catch ( Any e ) {
			arrayAppend(
				results.messages,
				"Error sending mail. #e.message# : #e.detail# : #e.stackTrace#"
			);
		}

		// Return the return structure.
		return results;
	}

	/**
	 * Mail a payload according to its contents
	 */
	private function mailIt( required payload ){
		cfmail( attributeCollection = arguments.payload.getConfig() ) {
			// Output Body
			writeOutput( "#arguments.payload.getBody()#" );

			// Process mail params
			arguments.payload
				.getMailParams()
				.each( function( thisParam ){
					if ( structKeyExists( arguments.thisParam, "name" ) ) {
						cfmailparam(
							name                = "#arguments.thisParam.name#",
							attributeCollection = "#arguments.thisParam#"
						);
					} else if ( structKeyExists( arguments.thisParam, "file" ) ) {
						cfmailparam(
							file                = "#arguments.thisParam.file#",
							attributeCollection = "#arguments.thisParam#"
						);
					}
				} );

			// Process mail parts
			arguments.payload
				.getMailParts()
				.each( function( thisPart ){
					cfmailpart( attributeCollection = "#arguments.thisPart#" ) {
						writeOutput( "#arguments.thisPart.body#" );
					}
				} );
		}
	}

}
