﻿<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************
Author 	 :	Luis Majano & Robert Rawlings
Description :
	A mail protocol that sends via cffile
	
	Properties:
	- filePath   : location to store files
	- autoExpand(true) : auto expand path or not 

----------------------------------------------------------------------->
<cfcomponent extends="cbmailservices.models.AbstractProtocol" output="false" hint="A mail protocol that sends via cffile">

	<!--- init --->
	<cffunction name="init" access="public" returntype="FileProtocol" hint="Constructor" output="false">
		<cfargument name="properties" required="false" default="#structnew()#" hint="A map of configuration properties for the protocol" />
		<cfscript>
			super.init( argumentCollection=arguments );
			
			// Property Checks
			if( NOT propertyExists( "filePath" ) ){
				// No API key was found, so throw an exception.
				throw( message="filePath property is Required", type="FileProtocol.PropertyNotFound" );
			}	
			// auto expand
			if( NOT propertyExists( "autoExpand" ) ){
				setProperty( "autoExpand", true );
			}
			
			// expandPath?
			if( getProperty( "autoExpand" ) ){
				setProperty( "filePath", expandPath( getProperty( 'filePath' ) ) );
			}

			// Check for filepath and create if not found
			if( !directoryExists( getProperty( "filePath" ) ) ){
				directoryCreate( getProperty( "filePath" ) );
			}
				
			return this;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PUBLIC ------------------------------------------>
	
	<cffunction name="send" access="public" returntype="struct" hint="I send a payload via the cfmail protocol.">
		<cfargument name="payload" required="true" type="any" hint="I'm the payload to delivery" doc_generic="cbmailservices.models.Mail"/>
		<cfscript>
			// The return structure
			var rtnStruct 	= { error=true, errorArray=[] };
			var content		= "";
			var filePath	= getProperty( "filePath" ) & "/mail.#dateformat(now(),"mm-dd-yyyy")#.#timeFormat(now(),"HH-mm-ss-L")#.html";
				
			//Just mail the darned thing!!
			try{
				// write it out
				fileWrite( filePath, getMailContent(arguments.payload) );
				
				// send success
				rtnStruct.error = false;
			}
			catch(Any e){
				ArrayAppend(rtnStruct.errorArray,"Error sending mail. #e.message# : #e.detail# : #e.stackTrace#");
			}			
			
			// Return the return structure.
			return rtnStruct;
		</cfscript>
	</cffunction>
	
<!------------------------------------------- PRIVATE ------------------------------------------>
	
	<!--- getMailContent --->
	<cffunction name="getMailContent" output="false" access="private" returntype="any" hint="Generate Mail content">
		<cfargument name="mail" required="true" type="any" hint="The mail payload" doc_generic="cbmailservices.models.Mail"/>
		<cfset var thisMail = "">
		
		<cfsavecontent variable="thisMail">
		<cfoutput>
			Sent at: #dateTimeFormat( now(), "full" )#<br/>
			<hr/>
			Mail Attributes
			<hr/>
			<cfdump var="#arguments.mail.getMemento()#">
			<hr/>
			Mail Params 
			<hr/>
			<cfdump var="#arguments.mail.getMailParams()#">
			<hr/>
			Mail Parts  
			<hr/>
			<cfdump var="#arguments.mail.getMailParts()#">
			<hr/>
			Mail Body
			<hr/>
			<cfif structKeyExists( arguments.mail.getMemento(), "type" ) AND
				  arguments.mail.getMemento().type eq "text">
		    <pre>#htmlcodeformat( arguments.mail.getBody() )#</pre>
		    <cfelse>
		    #arguments.mail.getBody()#
		    </cfif>
		</cfoutput>
		</cfsavecontent>
		
		<cfreturn thisMail>
	</cffunction>
	
</cfcomponent>