/**
 * *******************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * *******************************************************************************
 * ----
 * The ColdBox Mail Service is used to send emails in a fluent and human fashion.
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component accessors="true" singleton threadsafe {

	// DI
	property name="inteceptorService" inject="box:interceptorService";
	property name="settings"          inject="box:moduleSettings:cbmailservices";
	property name="wirebox"           inject="wirebox";
	property name="asyncManager"      inject="box:asyncManager";
	property name="log"               inject="logbox:logger:{this}";

	/**
	 * The token marker used for token replacements, default is `@`
	 */
	property name="tokenMarker" type="string";

	/**
	 * Mail Defaults that are used by all mailer protocols
	 */
	property name="defaultSettings" type="struct";

	/**
	 * The default protocol used for sending mail. The default is called `default` :)
	 */
	property name="defaultProtocol" type="string";

	/**
	 * Collection of mailers used for mailings
	 */
	property name="mailers" type="struct";

	/**
	 * The concurrent mail queue used by our scheduler to send asynchronous queued mail tasks
	 */
	property name="mailQueue";

	/**
	 * Constructor
	 */
	MailService function init(){
		// Register Defaults
		variables.tokenMarker     = "@";
		variables.defaultSettings = {};
		variables.defaultProtocol = "default";
		variables.mailers         = { "default" : { class : "CFMail" } };
		variables.mailQueue       = new ConcurrentLinkedQueue();

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
	 * Prepare the mail services for operation
	 */
	function onDIComplete(){
		// Store Mail Token Symbol from settings
		variables.tokenMarker     = variables.settings.tokenMarker;
		// Store Default Protocol by name
		variables.defaultProtocol = variables.settings.defaultProtocol;
		// Store Defaults from settings if any
		storeMailDefaults( argumentCollection = variables.settings.defaults );
		// Register all mailers
		registerMailers( variables.settings.mailers );
		return this;
	}

	/**
	 * Convenience method to get a mail default setting value
	 *
	 * @setting      The setting key to get
	 * @defaultValue The default value to return if the setting key doesn't exist
	 *
	 * @throws SettingNotFoundException - if the setting doesn't exist and no default value passed
	 */
	function getDefaultSetting( required setting, defaultValue ){
		if ( structKeyExists( variables.defaultSettings, arguments.setting ) ) {
			return variables.defaultSettings[ arguments.setting ];
		}
		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}
		throw(
			type   : "SettingNotFoundException",
			message: "The setting you requested #arguments.setting# does not exist. Valid settings are #variables.defaultSettings.keyList()#"
		);
	}

	/**
	 * Convenience method to set a default setting value
	 *
	 * @setting The setting key to set
	 * @value   The setting value to set
	 */
	MailService function setDefaultSetting( required setting, value ){
		variables.defaultSettings[ arguments.setting ] = arguments.value;
		return this;
	}

	/**
	 * Register a struct of mailers in this mail service according to our convention:
	 * <pre>
	 * { class: "", properties : "" }
	 * </pre>
	 *
	 * @mailers The structure of mailers to register
	 *
	 * @throws InvalidDefaultProtocol - If the default protocol was not registered in the mailers structure
	 */
	MailService function registerMailers( required struct mailers ){
		// Check the default protocol is in the mailers
		if ( !structKeyExists( arguments.mailers, variables.defaultProtocol ) ) {
			throw(
				type   : "InvalidDefaultProtocol",
				message: "The default protocol (#variables.defaultProtocol#) does not exist in the registered mailers (#arguments.mailers.keyList()#)"
			);
		}

		// Build out the mailers
		variables.mailers = arguments.mailers.map( function( key, definition ){
			// Params
			param arguments.definition.properties = {};
			param arguments.definition.transit    = "";

			// Are we a core protocol?
			if ( structKeyExists( variables.registeredProtocols, arguments.definition.class ) ) {
				arguments.definition.class = variables.registeredProtocols[ arguments.definition.class ];
			}

			// Build it out
			arguments.definition.transit = variables.wirebox.getInstance(
				name         : arguments.definition.class,
				initArguments: { "properties" : arguments.definition.properties }
			);

			return arguments.definition;
		} );

		return this;
	}

	/**
	 * Dynamically register a mailer protocol in this mail service
	 *
	 * @name       The unique name of the protocol
	 * @class      The protocol alias or wirebox id
	 * @properties The properties to instantiate the transit protocol with
	 *
	 * @return
	 */
	MailService function registerMailer(
		required name,
		required class,
		struct properties = {}
	){
		var thisMailer = {
			"class"      : arguments.class,
			"properties" : arguments.properties,
			"transit"    : ""
		};

		// Are we a core protocol?
		if ( structKeyExists( variables.registeredProtocols, arguments.class ) ) {
			arguments.class = variables.registeredProtocols[ arguments.class ];
		}

		// Build it out
		thisMailer.transit = variables.wirebox.getInstance(
			name         : arguments.class,
			initArguments: { "properties" : arguments.properties }
		);

		// Register it now
		variables.mailers[ arguments.name ] = thisMailer;

		return this;
	}

	/**
	 * Get the default mailer record
	 *
	 * @return { class:"", properties : {}, transit : object }
	 */
	struct function getDefaultMailer(){
		return variables.mailers[ variables.defaultProtocol ];
	}

	/**
	 * Get a mailer record by name
	 *
	 * @return { class:"", properties : {}, transit : object }
	 *
	 * @throws UnregisteredMailerException - When an invalid name is sent
	 */
	struct function getMailer( required name ){
		if ( structKeyExists( variables.mailers, arguments.name ) ) {
			return variables.mailers[ arguments.name ];
		}
		throw(
			message: "Mailer (#arguments.name#) not registered. Valid mailers are #variables.mailers.keyList()#",
			type   : "UnregisteredMailerException"
		);
	}

	/**
	 * Get an array of names of the registered mailers
	 */
	array function getRegisteredMailers(){
		return variables.mailers.keyArray();
	}

	/**
	 * Get a new Mail payload object, just use config() on it to prepare it or pass in all the arguments via this method
	 * All arguments passed to this method will be bound into the returning Mail object.
	 */
	Mail function newMail(){
		// Append defaults to incoming arguments
		structAppend( arguments, variables.defaultSettings, false );
		// Build out a new payload
		var oMail = variables.wirebox.getInstance( name = "Mail@cbmailservices", initArguments = arguments );

		// Set the right mailer
		oMail.setMailer( isNull( arguments.mailer ) ? variables.defaultProtocol : arguments.mailer );

		return oMail;
	}

	/**
	 * Send an email payload and returns to you the payload
	 *
	 * @mail The mail payload to send.
	 *
	 * @return Mail payload
	 */
	Mail function send( required Mail mail ){
		// Validate Basic Mail Fields and error out
		if ( NOT arguments.mail.validate() ) {
			arguments.mail.setResults( {
				"error"    : true,
				"messages" : [
					"Please check the basic mail fields of To, From, Subject and Body as they are empty. To: #arguments.mail.getTo()#, From: #arguments.mail.getFrom()#, Subject Len = #arguments.mail.getSubject().length()#, Body Len = #arguments.mail.getBody().length()#."
				]
			} )
			log.error( "Mail object does not validate." );
			return arguments.mail;
		}

		// Parse Body Tokens
		parseTokens( arguments.mail );

		// Just mail the darned thing!!
		try {
			// announce interception point before mail send
			variables.inteceptorService.announce( "preMailSend", { mail : arguments.mail } );

			// Get mailer
			var mailerRecord = getMailer( arguments.mail.getMailer() );

			// We mail it with the mailer of choice
			var results = mailerRecord.transit.send( arguments.mail );
			// Store results
			arguments.mail.setResults( results );
			// announce interception point after mail send
			variables.inteceptorService.announce( "postMailSend", { mail : arguments.mail, result : results } );
		} catch ( Any e ) {
			arguments.mail.setResults( {
				"error"    : true,
				"messages" : [ "Error sending mail. #e.message# : #e.detail# : #e.stackTrace#" ]
			} );
			log.error( arguments.mail.getResultMessages().toString(), e );
		}

		return arguments.mail;
	}

	/**
	 * Send an email payload asynchronously and return a ColdBox Future
	 *
	 * @mail The mail payload to send.
	 *
	 * @return ColdBox Future object: coldbox.system.async.tasks.Future
	 */
	function sendAsync( required mail ){
		return variables.asyncManager.newFuture( function(){
			return this.send( mail );
		} );
	}

	/**
	 * Queue the mail payload into our asynchronous work queue
	 *
	 * @mail The mail payload to send.
	 *
	 * @return A unique identifier for the task that was registered for you.
	 */
	string function queue( required mail ){
		var taskId = createUUID();
		variables.mailQueue.offer( {
			"id"       : taskId,
			"mail"     : arguments.mail,
			"created"  : now(),
			"ran"      : "",
			"errors"   : false,
			"messages" : []
		} );
		return taskId;
	}

	/**
	 * This method is called by our scheduling services or can be called manually to process the queue for
	 * mail sending
	 */
	function processQueue(){
		// Only work on the current size as we can allow more data to be let in after starting the dequeuing process.
		var size = variables.mailQueue.size();

		log.debug( "Starting to process mail queue of (#size#) elements" );

		for ( var x = 1; x lte size; x++ ) {
			// take the payload head and remove it (FIFO)
			var payload = variables.mailQueue.poll();
			// Send it
			this.send( payload.mail )
				.onSuccess( function( results, mail ){
					log.info(
						"Mail payload id (#payload.id#) to (#arguments.mail.getTo()#) with subject (#arguments.mail.getSubject()#) sent successfully!"
					);
				} )
				.onError( function( results, mail ){
					log.error(
						"Mail payload id (#payload.id#) to (#arguments.mail.getTo()#) with subject (#arguments.mail.getSubject()#) failed to send (#results.messages.toString()#)!"
					);
				} );
		}

		log.debug( "Finished processing mail queue" );
	}

	/**
	 * Parse the tokens and do body replacements.
	 *
	 * @mail The mail payload to use for parsing and usage.
	 */
	function parseTokens( required mail ){
		var tokens      = arguments.mail.getBodyTokens();
		var body        = arguments.mail.getBody();
		var mailParts   = arguments.mail.getMailParts();
		var tokenMarker = getTokenMarker();
		var key         = "";

		// Check mail parts for content
		if ( arrayLen( mailparts ) ) {
			// Loop over mail parts
			for ( var mailPart = 1; mailPart lte arrayLen( mailParts ); mailPart++ ) {
				body = mailParts[ mailPart ].body;
				for ( key in tokens ) {
					body = replaceNoCase(
						body,
						"#tokenMarker##key##tokenMarker#",
						tokens[ key ],
						"all"
					);
				}
				mailParts[ mailPart ].body = body;
			}
		}

		// Do token replacement on the body text
		for ( var key in tokens ) {
			body = replaceNoCase(
				body,
				"#tokenMarker##key##tokenMarker#",
				tokens[ key ],
				"all"
			);
		}

		// replace back the body
		arguments.mail.setBody( body );
	}

	/******************************* PRIVATE *********************************/

	/**
	 * Store the mail defaults
	 */
	private MailService function storeMailDefaults(
		server,
		username,
		password,
		numeric port,
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
				variables.defaultSettings[ key ] = arguments[ key ];
			}
		}

		return this;
	}

}
