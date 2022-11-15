/**
 * *******************************************************************************
 * Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
 * www.ortussolutions.com
 * *******************************************************************************
 * ----
 * This delegate allows objects to easily send mail.
 */
component accessors="true" {

	property
		name    ="mailService"
		inject  ="MailService@cbmailservices"
		delegate="newMail";

}
