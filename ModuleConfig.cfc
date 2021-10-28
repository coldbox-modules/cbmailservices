/**
 ********************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 ********************************************************************************
 * @author Luis Majano <lmajano@ortussolutions.com>
 * ----
 * Module Config
 */
component {

	// Module Properties
	this.title              = "ColdBox Mail Services";
	this.author             = "Ortus Solutions";
	this.webURL             = "https://www.ortussolutions.com";
	this.description        = "A module that allows you to leverage many mail service protocols in a nice abstracted API";
	// Model Namespace
	this.modelNamespace     = "cbmailservices";
	// CF Mapping
	this.cfmapping          = "cbmailservices";

	/**
	 * Configure the module
	 */
	function configure(){
		// Module Settings
		settings = {
			// The default token Marker Symbol
			tokenMarker : "@",
			// Default protocol is to use cfmail
			protocol    : { class : "CFMail", properties : {} }
		};

		// Listeners
		interceptorSettings = { customInterceptionPoints : "preMailSend,postMailSend" };
	}

	/**
	 * Fired when the module is registered and activated.
	 */
	function onLoad(){
	}

	/**
	 * Fired when the module is unregistered and unloaded
	 */
	function onUnload(){
	}

}
