/**
 * *******************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * *******************************************************************************
 * ----
 * An abstract class that gives identity to mail protocols when building custom or extending mail protocols the Mail Service uses.
 *
 * The `send()` function is the one you want to implement in your protocols
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component accessors="true" {

	// DI
	property name="log" inject="logbox:logger:{this}";

	/**
	 * A collection of configuration properties for a protocol
	 */
	property name="properties" type="struct";

	/**
	 * The protocol's human name
	 */
	property name="name";

	/**
	 * Constructor
	 *
	 * @properties The protocol properties to instantiate
	 */
	function init( struct properties = {} ){
		variables.properties = arguments.properties;
		return this;
	}

	/**
	 * Get a property, throws an exception if not found.
	 *
	 * @property     The property to get
	 * @defaultValue The default value to retrieve if property doesn't exist
	 *
	 * @throws PropertyNotFoundException if the property doesn't exist
	 */
	function getProperty( required property, defaultValue ){
		if ( structKeyExists( variables.properties, arguments.property ) ) {
			return variables.properties[ arguments.property ];
		}
		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}
		throw(
			type   : "PropertyNotFoundException",
			message: "The property (#arguments.property#) doesn't exist. Valid properties are #variables.properties.keyList()#"
		)
	}

	/**
	 * Set a property with a value
	 *
	 * @property The property key
	 * @value    The property value
	 */
	AbstractProtocol function setProperty( required property, required value ){
		variables.properties[ arguments.property ] = arguments.value;
		return this;
	}

	/**
	 * Verifies if a property exists or not
	 *
	 * @property The property key
	 */
	boolean function propertyExists( required property ){
		return structKeyExists( variables.properties, arguments.property );
	}

	/******************** TO IMPLEMENT ************************/

	/**
	 * Implemented by concrete protocols to send a message.
	 *
	 * The return is a struct with a minimum of the following two keys
	 * - `error` - A boolean flag if the message was sent or not
	 * - `messages` - An array of messages the protocol stored if any when sending the payload
	 *
	 * @payload             The paylod object to send the message with
	 * @payload.doc_generic cbmailservices.models.Mail
	 *
	 * @return struct of { "error" : boolean, "messages" : [] }
	 */
	struct function send( required cbmailservices.models.Mail payload ){
		throw( type = "NotImplementedException" );
	}

}
