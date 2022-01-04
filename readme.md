# Welcome to the ColdBox Mail Services => (cbmailservices)

Sending email doesn't have to be complicated or archaic. The ColdBox Mail Services (cbmailservices) module will allow you to send email in a fluent and abstracted way in multiple protocols for many environments in a single cohesive API. The supported protocols are:

* **CFMail** - Traditional `cfmail` sending
* **File** - Write emails to disk
* **InMemory** - Store email mementos in an array. Perfect for testing.
* **Null** - Ignores emails sent to it.
* **Postmark** - Send via the PostMark API Service (https://postmarkapp.com/)

It also sports tons of useful features for mail sending:

* Async Mail
* Mail Queues
* Mail merging of variables
* Mail attachments, headers and parameters
* View and Layout+View rendering for mail
* Mail tracking
* Multiple mailers
* Success and Error callbacks
* So Much More!

## LICENSE

Apache License, Version 2.0.

## IMPORTANT LINKS

* Source: https://github.com/coldbox-modules/cbmailservices
* ForgeBox: http://forgebox.io/view/cbmailservices
* Docs: https://coldbox-mailservices.ortusbooks.com
* [Changelog](changelog.md)

## SYSTEM REQUIREMENTS

* Lucee 5+
* ColdFusion 2018+

## Upgrading to v2

- Move to `moduleSettings`
- `send` returns the `Mail` not a struct. Use `mail.getResults()` to get a similar struct (with `error` and `messages`).
- Make sure `onError` and `onSuccess` are only called after calling `send` (should this be the case?)

## INSTRUCTIONS

Just drop into your modules folder or use the box-cli to install

`box install cbmailservices`

This registers a new mixin helper `newMail()` and the mail service via the WireBox ID of `MailService@cbmailservices`.  You will initiate a mail payload via the `newMail()` helper or the `newMail()` method in the `MailService`.  This will give you access to the `Mail@cbmailservices` object which you will fluently use to send mail.

## Settings

You can configure the module by creating a `cbmailservices` key under the `moduleSettings` structure in the `config/Coldbox.cfc` file.  Here you will configure all the different mailers, default protocol, default sending settings and so much more.

```js
moduleSettings = {
    cbmailServices = {
        // The default token Marker Symbol
        tokenMarker     : "@",
        // Default protocol to use, it must be defined in the mailers configuration
        defaultProtocol : "default",
        // Here you can register one or many mailers by name
        mailers         : { 
            "default" : { class : "CFMail" },
            "files" : { class:"File", properties : { filePath : "/logs" },
            "postmark" : { class:"PostMark", properties : { apiKey : "234" } 
        },
        // The defaults for all mail config payloads and protocols
        defaults        : {
            from : "info@ortussolutions.com",
            cc : "sales@ortussolutions.com"
        }
    }
}
```

By default, the mail services are configured to send mail via the `cfmail` tag using a mailer called `default`.

### Mail Protocols

The mail services can send mail via different protocols.  The available protocol aliases are:

* `CFMail`
* `Null`
* `InMemory`
* `File`
* `Postmark`

> Please note that some of the protocol have property requirements.

```js
defaultProtocol : "default",
mailers : {
	// Default CFMail
	"default" : {
		class : "CFMail"
	},

	// FileProtocol
	"files" = {
		class = "File",
		properties = {
			filePath = "logs",
			autoExpand = true
		}
	},

	// NullProtocol
	"null" = {
		class = "Null",
		properties = {}
	},

	// InMemoryProtocol
	"memory" = {
		class = "InMemory",
		properties = {}
	},

	// PostMark
	"postmark" = {
		class = "Postmark",
		properties = {
			APIKey = "123"
		}
	};
}
```

## Sending Mail

You can initiate a mail payload via the mixin helper (`newMail()`) or via the injected mail service's `newMail()` method.  The arguments you pass into this method will be used to seed the payload with all the arguments passed to the `cfmail` tag or the chosen protocol settings.  You can also pass an optional `mailer` argument which will override the `default` protocol to one of your liking.

> Please note that the mixin helper can ONLY be used in handlers, interceptors, layouts and views.  You will need to use the injection if you want to send mail from your models.

### Helper Approach

```js
// Mixin Helper Approach
newMail( 
	to         : "email@email.com",
	from       : "no_reply@ortussolutions.com",
	subject    : "Mail Services Rock",
	type       : "html", // Can be plain, html, or text
	bodyTokens : { 
		user    : "Luis", 
		product : "ColdBox", 
		link    : event.buildLink( 'home' )
	}
)
.setBody("
    <p>Dear @user@,</p>
    <p>Thank you for downloading @product@, have a great day!</p>
    <p><a href='@link@'>@link@</a></p> 
")
.send()
.onSuccess( function( result, mail ){
	// Process the success
})
.onError( function( result, mail ){
	// Process the error
});
```

### MailService Approach


Use the WireBox ID of `MailService@cbmailservices` to inject the service.

```js
component{

	property name="mailService" inject="MailService@cbmailservices";

	...

	function submitOrder( required order ){

		...

		variables.mailService
		.newMail( 
			to         : "email@email.com",
			from       : "no_reply@ortussolutions.com",
			subject    : "Mail Services Rock",
			type       : "html",
			bodyTokens : { 
				user    : "Luis", 
				product : "ColdBox", 
				link    : event.buildLink( 'home' )
			}
		)
		.setBody("
			<p>Dear @user@,</p>
			<p>Thank you for downloading @product@, have a great day!</p>
			<p><a href='@link@'>@link@</a></p> 
		")
		.send()
		.onSuccess( function( result, mail ){
			// Process the success
		})
		.onError( function( result, mail ){
			// Process the error
		});

	}

}
```

### Callbacks

The mail payload allows you to register two callbacks for success and errors:

* `onSuccess( callback )`
* `onError( callback )`

Each `callback` argument is a function/closure/lambda that receives two arguments:

* `result` : The result structure with at least two keys: `{ error :boolean, messages: array }`
* `mail` : The mail payload itself.

```js
.send()
	.onSuccess( function( result, mail ){
		// Process the success
	})
	.onError( function( result, mail ){
		// Process the error
	});
```

### Changing Mailers

You can easily change to use a specific mailer protocol by specifiying the `mailer` argument to the `newMail()` calls or by calling the `setMailer( mailer )` method.

```js
newMail( mailer : "files" ),,,


newMail()
	.setMailer( "files" )

```

### Body Tokens

The mail service allows you to register a structure of tokens that can be replaced by key name on the body content for you.  The tokens are demarcated by the `tokenMarker` setting which defaults to `@`.  

```js
@tokenName@
```

Before sending the mail, the service will replace all the tokens with the specific key names in your content and then send the mail.  You can use the `bodyTokens` argument to the `newMail() or configure()` methods, or you can use the `setBodyTokens()` method.

```js
// Via constructor
newMail( 
	to         : "email@email.com",
	from       : "no_reply@ortussolutions.com",
	subject    : "Mail Services Rock",
	type       : "html",
	bodyTokens : { 
		user    : "Luis", 
		product : "ColdBox", 
		link    : event.buildLink( 'home' )
	}
)
.setBody("
	<p>Dear @user@,</p>
	<p>Thank you for downloading @product@, have a great day!</p>
	<p><a href='@link@'>@link@</a></p> 
")
.send()

// Body Tokens Method
newMail( 
	to         : "email@email.com",
	subject    : "Mail Services Rock",
	type       : "html",
)
.setBodyTokens( { 
	user    : "Luis", 
	product : "ColdBox", 
	link    : event.buildLink( 'home' )
})
.setBody("
	<p>Dear @user@,</p>
	<p>Thank you for downloading @product@, have a great day!</p>
	<p><a href='@link@'>@link@</a></p> 
")
.send()
```

### Rendering Views

You can also set the body of the email to be a view or a layout+view combination using the `setView()` method. Here is the method signature:

```js
/**
 * Render or a view layout combination as the body for this email.  If you use this, the `type`
 * of the email will be set to `html` as well.  You can also bind the view/layout with
 * the args struct and use them accordingly.  You can also use body tokens that the service will
 * replace for you at runtime.
 *
 * @view The view to render as the body
 * @args The structure of arguments to bind the view/layout with
 * @module Optional, the module the view is located in
 * @layout Optional, If passed, we will render the view in this layout
 * @layoutModule Optional, If passed, the module the layout is in
 */
Mail function setView(
	required view,
	struct args = {},
	module      = "",
	layout,
	layoutModule = ""
)
```

Please note that you can bind your views and layotus with the `args` structure as well.  You can also use the `bodyTokens` in your views.  Then you can use it in your mail sending goodness:

```js
newMail( 
	to         : "email@email.com",
	subject    : "Mail Services Rock",
	type       : "html",
)
.setBodyTokens( { 
	user    : "Luis", 
	product : "ColdBox", 
	link    : event.buildLink( 'home' )
})
.setView( view : "emails/newUser" )
.send()

newMail( 
	to         : "email@email.com",
	subject    : "Mail Services Rock",
	type       : "html",
)
.setView( view : "emails/newUser", layout : "emails" )
.send()
```

### Mail Attachments

You can easily add mail attachments using mail params (next section) directly or our fancy helper method called `addAttachments()`.  Here is our method signature:

```js
/**
 * Add attachment(s) to this payload using a list or array of file locations
 *
 * @files A list or array of files to attach to this payload
 * @remove If true, ColdFusion removes attachment files (if any) after the mail is successfully delivered.
 */
Mail function addAttachments( required files, boolean remove = false )
```

The `files` argument can be a list of file locations or an array of file locations to send.

```js
newMail(
	subject = "Hello",
	from    = "lmajano@mail.com",
	to      = "lmajano@mail.com",
	body    = "Here are your docs"
)
.addAttachments( "c:\temp\reports\report.pdf", true )
.addAttachments( expandpath( "/reports/anotherReport.pdf" ), true )
.addAttachments( [
	expandPath( "/logs/maillog.txt" )
	expandPath( "/logs/maillog2.txt" )
], true )
.send();

```

### Mail Params

You can easily add mail parameters (`cfmailparam`) to a payload so you can attach headers or files to the message by using the `addMailParam()` method. Please see the https://cfdocs.org/cfmailparam cfmail param docs for more information.

#### Signature

```js
/**
 * Attach a file or adss a header to the email payload
 * 
 * @contentID The Identifier for the attached file.
 * @disposition How the attached file is to be handled: attachment, inline
 * @file Attaches file to a message. Mutually exclusive with name argument.
 * @type The MIME media type for the attachment.
 * @name The name of the email header to attach. See https://cfdocs.org/cfmailparam. Mututally exclusive with file
 * @value The value of the header
 * @remove Tells ColdFusion to remove any attachments after sucdcesful mail delivery
 * @content Lets you send the contents of a ColdFusion variable as an attachment 
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
)
```

#### Example

```js
newMail()
	.configure(
		from    = "info@coldbox.org",
		to      = "automation@coldbox.org",
		subject = "Mail With Params - Hello Luis"
	)
	.setBody( "Hello This is my great unit test" )
	.addMailParam(
		name  = "Disposition-Notification-To",
		value = "info@coldbox.org"
	)
	.addMailParam( name = "Importance", value = "High" )
	.send();
```

### Mail Parts

You can also add mail parts via the `cfmailpart` feature of `cfmail` (https://cfdocs.org/cfmailpart).  This allows you to build multi-parted emails.

#### Signature

```js
/**
 * Add a new mail part to this mail payload
 * 
 * @charset The charset of the part, defaults to utf-8
 * @type The valid mime type: text/plain or text/html
 * @wraptext Specifies the maximum line length, in characters of the mail text.
 * @type The MIME media type for the attachment.
 * @body The body of the email according to the type.
 */
Mail function addMailPart(
	charset = "utf-8",
	type,
	numeric wraptext,
	body
){
```

#### Example

```js
newMail(
	from    = "info@coldbox.org",
	to      = "automation@coldbox.org",
	subject = "Mail MultiPart No Params - Hello Luis"
)
.addMailPart(
	type = "text",
	body = "You are reading this message as plain text, because your mail reader does not handle it."
)
.addMailPart( type = "html", body = "<h1>This is the body of the message.</h1>" )
.send()
```

### Mail Helper Methods

We have also registered several methods to help you when sending mail:

* `setReadReceipt( email )` - Set the read receipt email
* `setSendReceipt( email )` - Set the send receipt email
* `setHtml( body )` - Set a multi-part body for html
* `setText( body )` - Set a multi-part body for text
* `addAttachments( files, remove=false)` - Easily add attachments
* `getMemento()` - Get the entire mail settings for the payload
* `hasErrors():boolean` - Verifies if there are any errors in the mailing
* `getResultMessages():array` - Get's the array of messages of the sending of the mail
* `getResults():struct` - Get the structure of the results of sending the mail


### Mail Additional Info

The `Mail` object has some additional methods to allow you to pass additional information so protocols can leverage them:

```js
mail.setAdditionalInfo( struct );
mail.getAdditionalInfo();

mail.setAdditionalInfoItem( key, value );
mail.getAdditionalInfoItem( key );
```

### Async Mail

You can easily send mail asynchronously via the ColdBox Async Manager using the `sendAsync()` method.  This will return to you a ColdBox Future object (https://coldbox.ortusbooks.com/digging-deeper/promises-async-programming)

```js
newMail( 
	to         : "email@email.com",
	from       : "no_reply@ortussolutions.com",
	subject    : "Mail Services Rock",
	type       : "html",
	bodyTokens : { 
		user    : "Luis", 
		product : "ColdBox", 
		link    : event.buildLink( 'home' )
	}
)
.setBody("
    <p>Dear @user@,</p>
    <p>Thank you for downloading @product@, have a great day!</p>
    <p><a href='@link@'>@link@</a></p> 
")
.sendAsync()
.then( function( mail ){
	// Async pipeline that can process the mail once it is sent.

})
```

### Mail Queue

You can also detach the mail and let the cbmailservices Mail Queue send it for you.  The module's mail scheduler runs on a one-minute interval and will send any mail found in the processing queue.  All you need to do is use the `queue()` method and be done!

```js
var mailId = newMail( 
	to         : "email@email.com",
	from       : "no_reply@ortussolutions.com",
	subject    : "Mail Services Rock",
	type       : "html",
	bodyTokens : { 
		user    : "Luis", 
		product : "ColdBox", 
		link    : event.buildLink( 'home' )
	}
)
.setBody("
    <p>Dear @user@,</p>
    <p>Thank you for downloading @product@, have a great day!</p>
    <p><a href='@link@'>@link@</a></p> 
")
.queue();
```

The `queue` method will return back a task ID guid, which you can use to track the task down in your logs or via the Mail Service.

## Custom Protocols

In order to create your own custom protocol you will create a CFC that inherits from `cbmailservices.models.AbstractProtocol` and make sure you implement the `init()` and `send()` method.  Please see our docs for much more information: https://coldbox-mailservices.ortusbooks.com/advanced/building-protocols

## Mail Events

The module will register two interception points. `PreMailSend` and `PostMailSend`. These interception points are useful to alter the mail object before it gets sent out, and/or perform any functions after the mail gets sent out. An example interceptor would be:

```js
component extends="coldbox.system.Interceptor"{
    void function configure(){
        
    }

    boolean function preMailSend( event, interceptData, buffer, rc, prc ){
        var environment = getSetting('environment');
        var appName = getSetting('appName');
        var mail = interceptData.mail;
        var subject = mail.getSubject()

        if(environment eq 'development'){
            //change recipient if we are on development
            mail.setTo('johndoe@example.com');  
            //prefix the subject if we are on development
            mail.setSubject('<DEV-#appName#> #subject#');
        }       

        return false;
    }

    boolean function postMailSend( event, interceptData, buffer, rc, prc ){
        if(interceptData.result.error eq true){
            //log mail failure here...
        }

        return false;
    }

}
```

You can find much more information here: https://coldbox-mailservices.ortusbooks.com/advanced/mail-events

********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

#### HONOR GOES TO GOD ABOVE ALL

Because of His grace, this project exists. If you don't like this, then don't read it, its not for you.

>"Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
And patience, experience; and experience, hope:
And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the 
Holy Ghost which is given unto us. ." Romans 5:5

### THE DAILY BREAD

 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12
