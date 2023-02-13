/**
 * *******************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * *******************************************************************************
 * ----
 * A mail payload object used by the developer to send mail via the mail services.
 * You can use our dynamic getters and setters to set any property in the configuration structure
 * that can be used by the sending transit protocol.  Example: If we use the CFMail protocol
 * then we can set ANY of the attributes that the cfmail tag uses into this configuration
 * object.  Then the transit object will use it accordingly.
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
 */
component accessors="true" {

	// DI
	property name="wirebox" inject="wirebox";

	/**
	 * The config struct representing the mail payload which is sent to the configured protocol in the mail service
	 */
	property name="config" type="struct";

	/**
	 * The structure of results of sending the mail via the protocol. At most it will contain the following keys:
	 * - error : boolean
	 * - messages : array of messages
	 */
	property name="results" type="struct";

	/**
	 * The mailer to use when sending the payload. It defaults to `default`
	 */
	property name="mailer" type="string";

	/**
	 * Constructor
	 */
	function init(){
		// Basic config with default settings
		variables.config = {
			"bodyTokens"     : {},
			"mailParams"     : [],
			"mailParts"      : [],
			"body"           : "",
			"from"           : "",
			"fromName"       : "",
			"to"             : "",
			"cc"             : "",
			"bcc"            : "",
			"subject"        : "",
			"additionalInfo" : {}
		};

		variables.mailer  = "default";
		variables.results = {};

		return this.configure( argumentCollection = arguments );
	}

	/**
	 * Get a config property, throws an exception if not found.
	 *
	 * @property     The property to get
	 * @defaultValue The default value to retrieve if property doesn't exist
	 *
	 * @throws PropertyNotFoundException if the property doesn't exist
	 */
	function getProperty( required property, defaultValue ){
		if ( structKeyExists( variables.config, arguments.property ) ) {
			return variables.config[ arguments.property ];
		}
		if ( !isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}
		throw(
			type   : "PropertyNotFoundException",
			message: "The property (#arguments.property#) doesn't exist. Valid properties are #variables.config.keyList()#"
		)
	}

	/**
	 * Set a config property with a value
	 *
	 * @property The property key
	 * @value    The property value
	 */
	Mail function setProperty( required property, required value ){
		variables.config[ arguments.property ] = arguments.value;
		return this;
	}

	/**
	 * Verifies if a config property exists or not
	 *
	 * @property The property key
	 */
	boolean function propertyExists( required property ){
		return structKeyExists( variables.config, arguments.property );
	}

	/**
	 * Place holder for `configure()` as a compatibility shim
	 *
	 * @deprecated This will be removed
	 */
	Mail function config(){
		return this.configure( argumentCollection = arguments );
	}

	/**
	 * Seed the configuration of this object
	 */
	Mail function configure(
		from,
		to,
		body,
		bcc,
		cc,
		charset,
		boolean debug,
		failto,
		group,
		boolean groupcasesensitive,
		mailerid,
		numeric maxrows,
		mimeattach,
		password,
		numeric port,
		priority,
		query,
		replyto,
		server,
		boolean spoolenable,
		numeric startrow,
		subject,
		numeric timeout,
		type,
		username,
		boolean useSSL,
		boolean useTLS,
		numeric wraptext,
		struct additionalInfo = {},
		fromName
	){
		// populate mail keys
		for ( var key in arguments ) {
			if ( structKeyExists( arguments, key ) ) {
				variables.config[ key ] = arguments[ key ];
			}
		}

		// server exception
		if ( !isNull( arguments.server ) AND NOT len( arguments.server ) ) {
			structDelete( variables.config, "server" );
		}

		return this;
	}

	/**
	 * Listen to dynamic getters and setters for any configuration setting:
	 * <pre>
	 * getFrom()
	 * getFrom( "defaultValue" )
	 * setFrom( "luis@ortussolutions.com" )
	 * setFrom() => empty value, same as setFrom( "" )
	 * </pre>
	 */
	function onMissingMethod( missingMethodName, missingMethodArguments = {} ){
		// Dynamic Getter: getServer(), getUsername(), getFrom( "default" )
		if ( left( arguments.missingMethodName, 3 ) == "get" ) {
			return this.getProperty(
				property    : arguments.missingMethodName.replaceNoCase( "get", "" ),
				defaultValue: structCount( missingMethodArguments ) ? missingMethodArguments[ 1 ] : javacast(
					"null",
					""
				)
			);
		}

		// Dynamic Setter: setFrom( "value" ), setFrom() same as setFrom( "" )
		if ( left( arguments.missingMethodName, 3 ) == "set" ) {
			return this.setProperty(
				property: arguments.missingMethodName.replaceNoCase( "set", "" ),
				value   : structCount( missingMethodArguments ) ? missingMethodArguments[ 1 ] : ""
			);
		}

		throw(
			type   : "InvalidMethodException",
			message: "Only dynamic getters and setters are allowed",
			detail : "You requested the following function: #arguments.missingMethodName#"
		);
	}

	/**
	 * Run email validation and throw an InvalidMailException if required params are missing.
	 */
	Mail function validateOrFail(){
		if ( NOT this.validate() ){
			throw(
				type   : "InvalidMailException",
				message: "One or more required fields are missing.",
				detail : "Please check the basic mail fields of To, From, Subject and Body as they are empty. To: #variables.config.to#, From: #variables.config.from#, Subject Len = #variables.config.subject.len()#, Body Len = #variables.config.body.len()#."
			);
		}
		return this;
	}

	/**
	 * Validate that the basic fields of from, to, subject, and body are set for sending mail
	 */
	boolean function validate(){
		if (
			variables.config.from.len() eq 0 OR
			variables.config.to.len() eq 0 OR
			variables.config.subject.len() eq 0 OR
			( variables.config.body.len() eq 0 AND arrayLen( variables.config.mailParts ) EQ 0 )
		) {
			return false;
		} else {
			return true;
		}
	}

	/**
	 * Get the additional info stored by key
	 *
	 * @key          The key to get
	 * @defaultValue The default value if not found, defaults to empty string
	 */
	any function getAdditionalInfoItem( required key, defaultValue = "" ){
		return structKeyExists( variables.config.additionalInfo, arguments.key ) ? variables.config.additionalInfo[
			arguments.key
		] : arguments.defaultValue;
	}

	/**
	 * Store additional info items
	 *
	 * @key   The key to store
	 * @value The value to store
	 */
	Mail function setAdditionalInfoItem( required key, required value ){
		variables.config.additionalInfo[ arguments.key ] = arguments.value;
		return this;
	}

	/**
	 * Set the email address that will receive read receipts. I just place the appropriate mail headers
	 *
	 * @email The email to send the read recipt to
	 */
	Mail function setReadReceipt( required email ){
		addMailParam( name = "Read-Receipt-To", value = arguments.email );
		addMailParam( name = "Disposition-Notification-To", value = arguments.email );
		return this;
	}

	/**
	 * Sets the email that get's notified once the email is delivered by setting the appropriate mail headers
	 *
	 * @email The email to send the send recipt to
	 */
	Mail function setSendReceipt( required email ){
		addMailParam( name = "Return-Receipt-To", value = arguments.email );
		return this;
	}

	/**
	 * Sets up a mail part that is HTML using utf8 for you by calling addMailpart()
	 *
	 * @body The body content to set the mail part on
	 */
	Mail function setHtml( required body ){
		addMailPart(
			charset = "utf8",
			type    = "text/html",
			body    = arguments.body
		);
		return this;
	}

	/**
	 * Sets up a mail part that is TEXT using utf8 for you by calling addMailpart()
	 *
	 * @body The body content to set the mail part on
	 */
	Mail function setText( required body ){
		addMailPart(
			charset = "utf8",
			type    = "text/plain",
			body    = arguments.body
		);
		return this;
	}

	/**
	 * Add attachment(s) to this payload using a list or array of file locations
	 *
	 * @files  A list or array of files to attach to this payload
	 * @remove If true, ColdFusion removes attachment files (if any) after the mail is successfully delivered.
	 */
	Mail function addAttachments( required files, boolean remove = false ){
		if ( isSimpleValue( arguments.files ) ) {
			arguments.files = listToArray( arguments.files );
		}
		for ( var x = 1; x lte arrayLen( arguments.files ); x = x + 1 ) {
			addMailParam( file = arguments.files[ x ], remove = arguments.remove );
		}

		return this;
	}

	/**
	 * Add a new mail part to this mail payload
	 */
	Mail function addMailPart(
		charset = "utf-8",
		type,
		numeric wraptext,
		body
	){
		// Add new mail part
		var mailpart = {};
		for ( var key in arguments ) {
			if ( structKeyExists( arguments, key ) ) {
				mailpart[ key ] = arguments[ key ];
			}
		}

		arrayAppend( this.getMailParts(), mailpart );

		return this;
	}

	/**
	 * Add mail params to this payload
	 */
	Mail function addMailParam(
		contentID,
		disposition,
		file,
		type,
		name,
		value,
		boolean remove,
		content
	){
		// Add new mail Param
		var mailparams = {};

		for ( var key in arguments ) {
			if ( structKeyExists( arguments, key ) ) {
				mailparams[ key ] = arguments[ key ];
			}
		}

		arrayAppend( this.getMailParams(), mailparams );

		return this;
	}

	/**
	 * Send this mail payload and return itself
	 */
	Mail function send(){
		return variables.wirebox.getInstance( "MailService@cbmailservices" ).send( this );
	}

	/**
	 * Send this mail payload asynchronously and return a Future
	 */
	function sendAsync(){
		return variables.wirebox.getInstance( "MailService@cbmailservices" ).sendAsync( this );
	}

	/**
	 * Queue the mail payload into our asynchronous work queue
	 *
	 * @return A unique identifier for the task that was registered for you.
	 */
	string function queue(){
		return variables.wirebox.getInstance( "MailService@cbmailservices" ).queue( this );
	}

	/**
	 * Callback that if there is an error in the sending of the mail it will be called for you.
	 *
	 * The callback will receive the results struct and the mail object itself
	 */
	function onError( required callback ){
		if ( structCount( variables.results ) && hasErrors() ) {
			arguments.callback( variables.results, this );
		}
		return this;
	}

	/**
	 * Callback that if there is NO error in the sending of the mail it will be called for you.
	 *
	 * The callback will receive the results struct and the mail object itself
	 */
	function onSuccess( required callback ){
		if ( structCount( variables.results ) && !hasErrors() ) {
			arguments.callback( variables.results, this );
		}
		return this;
	}

	/**
	 * Check if the sending had errors or not
	 */
	boolean function hasErrors(){
		return variables.results.error ?: false;
	}

	/**
	 * Get the result messages
	 */
	array function getResultMessages(){
		return variables.results.messages ?: [];
	}

	/**
	 * Return the configuration structure
	 *
	 * @deprecated This will be dropped do not use anymore, use getConfig()
	 */
	struct function getMemento(){
		return variables.config;
	}

	/**
	 * Render or a view layout combination as the body for this email.  If you use this, the `type`
	 * of the email will be set to `html` as well.  You can also bind the view/layout with
	 * the args struct and use them accordingly.  You can also use body tokens that the service will
	 * replace for you at runtime.
	 *
	 * @view         The view to render as the body
	 * @args         The structure of arguments to bind the view/layout with
	 * @module       Optional, the module the view is located in
	 * @layout       Optional, If passed, we will render the view in this layout
	 * @layoutModule Optional, If passed, the module the layout is in
	 */
	Mail function setView(
		required view,
		struct args = {},
		module      = "",
		layout,
		layoutModule = ""
	){
		// Set the type to be HTML
		variables.config.type = "html";

		// Do we have a layout?
		if ( !isNull( arguments.layout ) && len( arguments.layout ) ) {
			variables.config.body = variables.wirebox
				.getInstance( "Renderer@coldbox" )
				.layout(
					layout    : arguments.layout,
					module    : arguments.layoutModule,
					view      : arguments.view,
					args      : arguments.args,
					viewModule: arguments.module
				);
		}
		// Else, plain view rendering
		else {
			variables.config.body = variables.wirebox
				.getInstance( "Renderer@coldbox" )
				.view(
					view  : arguments.view,
					args  : arguments.args,
					module: arguments.module
				);
		}

		return this;
	}

}
