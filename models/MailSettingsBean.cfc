/**
 ********************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 ********************************************************************************
 * @author Luis Majano <lmajano@ortussolutions.com>
 * ----
 * I model mail server settings. You can send this bean to model or EJB's and when sending email. It will use its settings.
 * All settings are stored in the variables scope as first-class properties.
 */
component accessors="true" singleton threadsafe {

	// DI
	property name="wirebox" inject="wirebox";

	/**
	 * The transit object that models the protocol configuration
	 */
	property name="transit";

	/**
	 * Holder of all mail configuration settings
	 */
	property name="config" type="struct";

	/**
	 * Constructor
	 */
	function init(){
		variables.config              = {};
		// Protocols Path
		variables.protocolsPath       = getDirectoryFromPath( getMetadata( this ).path ) & "protocols";
		// Register core protocols
		variables.registeredProtocols = directoryList(
			variables.protocolsPath,
			false,
			"name",
			"*.cfc"
		)
			// don't do the interfaces
			.filter( function( item ){
				return ( item != "IProtocol.cfc" );
			} )
			// Purge extension
			.map( function( item ){
				return listFirst( item, "." );
			} )
			// Build out wirebox mapping
			.reduce( function( result, item ){
				result[ item.replaceNoCase( "Protocol", "" ) ] = "cbmailservices.models.protocols.#item#";
				return result;
			}, {} );

		return this;
	}

	/**
	 * Configure this bean for operation by storing all mail settings and building the transit protocol
	 */
	MailSettingsBean function configure(
		server          = "",
		username        = "",
		password        = "",
		numeric port    = 0,
		struct protocol = {},
		from,
		to,
		body,
		bcc,
		cc,
		charset,
		boolean debug = false,
		failto,
		group,
		boolean groupcasesensitive,
		mailerid,
		numeric maxrows,
		mimeattach,
		priority,
		query,
		replyto,
		boolean spoolenable,
		numeric startrow,
		subject,
		numeric timeout,
		type,
		boolean useSSL,
		boolean useTLS,
		numeric wraptext
	){
		// populate mail settings
		for ( var key in arguments ) {
			if ( !isNull( arguments[ key ] ) ) {
				variables.config[ key ] = arguments[ key ];
			}
		}

		// Register the protocol to be used
		registerProtocol( argumentCollection = arguments.protocol );

		return this;
	}

	/**
	 * Get a mail setting value
	 *
	 * @setting The setting key to get
	 * @defaultValue The default value to return if the setting key doesn't exist
	 *
	 * @throws SettingNotFoundException - if the setting doesn't exist and no default value passed
	 */
	function getValue( required setting, defaultValue ){
		if ( structKeyExists( variables.config, arguments.setting ) ) {
			return variables.config[ arguments.setting ];
		}
		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}
		throw(
			type   : "SettingNotFoundException",
			message: "The setting you requested #arguments.setting# does not exist. Valid settings are #variables.config.keyList()#"
		);
	}

	/**
	 * Set a mail setting value
	 *
	 * @setting The setting key to set
	 * @value The setting value to set
	 */
	MailSettingsBean function setValue( required setting, value ){
		variables.config[ arguments.setting ] = arguments.value;
		return this;
	}

	/**
	 * Register a protocol in this mail bean
	 *
	 * @class The wirebox id or path of the protocol
	 * @properties The properties to construct the protocol with
	 *
	 * @return The constructed transit protocol
	 */
	any function registerProtocol( required class, struct properties = {} ){
		// Are we a core protocol?
		if ( structKeyExists( variables.registeredProtocols, arguments.class ) ) {
			arguments.class = variables.registeredProtocols[ arguments.class ];
		}

		// Build it out
		variables.transit = variables.wirebox.getInstance(
			name         : arguments.class,
			initArguments: { "properties" : arguments.properties }
		);

		// Return the transit protocol
		return variables.transit;
	}

	/**
	 * Get the memento of this mail configuration bean
	 */
	struct function getMemento(){
		return variables.filter( function( k, v ){
			// Do not return UDFs
			return ( !isCustomFunction( v ) );
		} );
	}

	/**
	 * Set the complete state of this configuration bean
	 *
	 * @memento The state to set
	 */
	MailSettingsBean function setMemento( required struct memento ){
		structAppend( variables, arguments.memento, true );
		return this;
	}

}
