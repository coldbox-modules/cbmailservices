<cfscript>
	/**
	 * Get a new Mail payload object, just use config() on it to prepare it or pass in all the arguments via this method
	 * All arguments passed to this method will be bound into the returning Mail object.
	 */
	Mail function newMail(){
		return getInstance( "MailService@cbmailservices" ).newMail( argumentCollection = arguments );
	}
</cfscript>