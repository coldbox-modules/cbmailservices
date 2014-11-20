INSTRUCTIONS
============
Just drop into your modules folder or use the box-cli to install

`box install cbmailservices`

The mail services registers all mail components so you can use them in your application.

## Settings
You will need to update the your `ColdBox.cfc` with a `mailsettings` structure with your preferred mail settings and mail protocol to use.  All the keys that can go into the `mailsettings` struct map 1-1 to the `cfmail` tag except for the `tokenMarker` and `protocol` keys.
 
```
mailsettings = {
	// The default token Marker Symbol
	tokenMarker = "@",
	// protocol
	protocol = {
		class = "",
		properties = {}
	}
};
```

## Models
This will register a `mailService@cbmailservices` in WireBox that you can leverage for usage.

```
// build mail and send
var oMail = getInstance( "mailService@cbmailservices" )
	.newMail( to="email@email.com",
			  subject="Mail Services Rock",
			  bodyTokens={ user="Luis", product="ColdBox", link=event.buildLink( 'home' )} );

// Set a Body
oMail.setBody("
	<p>Dear @user@,</p>
	<p>Thank you for downloading @product@, have a great day!</p>
	<p><a href='@link@'>@link@</a></p> 
");

//send it
var results = mailService.send( oMail );
```

##Mail Protocols

The mail services can send mail via different protocols.  The available protocols are:

* CFMailProtocol
* FileProtocol
* PostmarkProtocol

You register the protocols in the `mailsettings` via the `protocol` structure:

```
// FileProtocol
protocol = {
	class = "cbcbmailservices.models.protocols.FileProtocol",
	properties = {
		filePath = "logs",
		autoExpand = true
	}
}

// PostMark
protocol = {
	class = "cbcbmailservices.models.protocols.PostmarkProtocol",
	properties = {
		APIKey = ""
	}
}
```