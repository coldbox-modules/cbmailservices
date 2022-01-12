/**
 * *******************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * *******************************************************************************
 * ----
 * This protocol stores the mail in html files in the directory specified via the configuration
 * properties
 *
 * - filePath : The directory location to store the mail files
 * - autoExpand : Defaults to true to do an expandPath() on the incoming filePath
 *
 * @author Luis Majano <lmajano@ortussolutions.com>
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
	FileProtocol function init( struct properties = {} ){
		variables.name = "File";
		super.init( argumentCollection = arguments );

		// Property Checks
		if ( NOT propertyExists( "filePath" ) ) {
			// No API key was found, so throw an exception.
			throw( message = "(filePath) property is required", type = "FileProtocol.PropertyNotFound" );
		}
		// auto expand
		if ( NOT propertyExists( "autoExpand" ) ) {
			setProperty( "autoExpand", true );
		}

		// expandPath?
		if ( getProperty( "autoExpand" ) ) {
			setProperty( "filePath", expandPath( getProperty( "filePath" ) ) );
		}

		// Check for filepath and create if not found
		if ( !directoryExists( getProperty( "filePath" ) ) ) {
			directoryCreate( getProperty( "filePath" ) );
		}

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
		// The return structure
		var rtnStruct = { "error" : true, "messages" : [] };
		var content   = "";
		var filePath  = getProperty( "filePath" ) & "/mail.#dateFormat( now(), "mm-dd-yyyy" )#.#timeFormat( now(), "HH-mm-ss-L" )#.html";

		// Just mail the darned thing!!
		try {
			// write it out
			fileWrite(
				filePath,
				getMailContent( arguments.payload ),
				"UTF-8"
			);
			// send success
			rtnStruct.error = false;
		} catch ( Any e ) {
			arrayAppend( rtnStruct.messages, "Error sending mail. #e.message# : #e.detail# : #e.stackTrace#" );
		}

		// Return the return structure.
		return rtnStruct;
	}

	/**
	 * Generate the mail content to store in the file
	 */
	private function getMailContent( required mail ){
		// cfformat-ignore-start
		savecontent variable="local.thisMail"{
			writeOutput( "
				Sent at: #dateTimeFormat( now(), "full" )#<br/>
				<hr/>
				Mail Attributes
				<hr/>
			");
			writeDump( var=arguments.mail.getConfig() );
			writeOutput( "
				<hr/>
				Mail Params
				<hr/>
			" );
			writeDump( var=arguments.mail.getMailParams() );
			writeOutput( "
				<hr/>
				Mail Parts
				<hr/>
			" );
			writeDump( var=arguments.mail.getMailParts() );
			writeOutput( "
				<hr/>
				Mail Body
				<hr/>
			" );
			// Text or HTML Type
			if( arguments.mail.getProperty( "type", "text" ) eq "text" ){
				writeOutput( "<pre>#htmlCodeFormat( arguments.mail.getBody() )#</pre>" );
			} else {
				writeOutput( "#arguments.mail.getBody()#" );
			}
		}
		// cfformat-ignore-end

		return local.thisMail;
	}

}
