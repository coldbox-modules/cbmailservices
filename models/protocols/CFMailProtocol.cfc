/**
 * *******************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * *******************************************************************************
 * ----
 * This protocol sends mail via the cfmail tag.
 *
 * @author Robert Rawlings, Luis Majano <lmajano@ortussolutions.com>
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
	 * @payload             The paylod object to send the message with
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
			arrayAppend( results.messages, "Error sending mail. #e.message# : #e.detail# : #e.stackTrace#" );
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
			for ( var thisParam in arguments.payload.getMailParams() ) {
				if ( structKeyExists( thisParam, "name" ) ) {
					cfmailparam( name = "#thisParam.name#", attributeCollection = "#thisParam#" );
				} else if ( structKeyExists( thisParam, "file" ) ) {
					cfmailparam( file = "#thisParam.file#", attributeCollection = "#thisParam#" );
				}
			}

			// Process mail parts
			for ( var thisPart in arguments.payload.getMailParts() ) {
				cfmailpart( attributeCollection = "#thisPart#" ) {
					writeOutput( "#thisPart.body#" );
				}
			}
		}
	}

}
