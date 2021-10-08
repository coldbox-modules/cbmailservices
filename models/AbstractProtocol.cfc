/**
 * An abstract class that give identity to mail protocols when building custom or extending mail protocols the Mail Service uses.
 */
component accessors="true" {

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
	 * Implemented by concrete protocols to send a message
	 *
	 * @payload The paylod object to send the message with
	 * @payload.doc_generic cbmailservices.models.Mail
	 */
	struct function send( required payload ){
		throw( type = "NotImplementedException" );
	}

	/**
	 * Get a property, throws an exception if not found.
	 *
	 * @property The property to get
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
	 * @value The property value
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

}
