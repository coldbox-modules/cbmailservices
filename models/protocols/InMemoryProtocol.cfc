component extends="cbmailservices.models.AbstractProtocol" singleton accessors="true" {

	property name="mail" type="array";

	/**
	 * Initialize the InMemory protocol
	 *
	 * @properties A map of configuration properties for the protocol
	 */
	public InMemoryProtocol function init( struct properties = {} ) {
		super.init( argumentCollection = arguments );
		variables.mail = [];
		return this;
	}

	/**
	 * Log the message as sent.
	 *
	 * @payload The payload to deliver
	 */
	public struct function send( required cbmailservices.models.Mail payload ) {
		variables.mail.append( arguments.payload.getMemento() );
		return { "error": false, "errorArray": [] };
	}

    /**
     * Check if a given message has been sent by passing in a callback.
     * Each message will be checked against the callback.
     * If one message passes the callback, this method will return true.
     * 
     * @callback A callback function to check against each mail item.
     */
	public boolean function hasMessage( required function callback ) {
		return arrayFilter( variables.mail, arguments.callback ).len() > 0;
	}

    /**
     * Resets the in-memory array.
     */
	public void function reset() {
		variables.mail = [];
	}

}
