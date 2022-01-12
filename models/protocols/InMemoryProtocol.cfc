/**
 * *******************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * *******************************************************************************
 * ----
 * This protocol stores the mail in the `mail` property file.
 *
 * @author Eric Peterson <eric@ortussolutions.com>, Luis Majano <lmajano@ortussolutions.com>
 */
component
	extends="cbmailservices.models.AbstractProtocol"
	singleton
	accessors="true"
{

	/**
	 * This is the mail log for all sent mail
	 */
	property name="mail" type="array";

	/**
	 * Initialize the InMemory protocol
	 *
	 * @properties A map of configuration properties for the protocol
	 */
	InMemoryProtocol function init( struct properties = {} ){
		variables.name = "InMemory";
		super.init( argumentCollection = arguments );
		variables.mail = [];
		return this;
	}

	/**
	 * Store them locally in our maillog property
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
		variables.mail.append( arguments.payload.getConfig() );
		return { "error" : false, "messages" : [] };
	}

	/**
	 * Check if a given message has been sent by passing in a callback.
	 * Each message will be checked against the callback.
	 * If one message passes the callback, this method will return true.
	 *
	 * @callback A callback function to check against each mail item.
	 */
	boolean function hasMessage( required function callback ){
		return arrayFilter( variables.mail, arguments.callback ).len() > 0;
	}

	/**
	 * Resets the in-memory array.
	 */
	InMemoryProtocol function reset(){
		variables.mail = [];
		return this;
	}

}
