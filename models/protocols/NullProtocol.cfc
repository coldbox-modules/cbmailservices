/**
 * *******************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * *******************************************************************************
 * ----
 * A protocol that doesn't do anything. Useful for mocking. Please note that nothing
 * is stored.
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component
	extends="cbmailservices.models.AbstractProtocol"
	singleton
	accessors="true"
{

	/**
	 * Constructor
	 *
	 * @properties
	 */
	function init( struct properties = {} ){
		variables.name = "Null";
		return super.init( argumentCollection = arguments );
	}

	/**
	 * Send nothing :) NADA!
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
	public struct function send( required cbmailservices.models.Mail payload ){
		return { "error" : false, "messages" : [] };
	}

}
