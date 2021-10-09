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
	 * Ignore the sent message and return a successful response.
	 *
	 * @payload The payload to deliver
	 */
	public struct function send( required cbmailservices.models.Mail payload ){
		return { "error" : false, "errorArray" : [] };
	}

}
