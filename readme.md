[![Build Status](https://travis-ci.org/coldbox-modules/cbmailservices.svg?branch=development)](https://travis-ci.org/coldbox-modules/cbmailservices)

# WELCOME TO THE COLDBOX MAILSERVICES MODULE

The ColdBox Mail services module will allow you to send email the OO way in 
multiple protocols for many environments.  The supported protocols are:

* **CFMail** - Traditional `cfmail` sending
* **Files** - Write emails to disk
* **Postmark API** - Send via the PostMark Service (https://postmarkapp.com/)

You can easily add your own mail protocols by building upon our standards.

## LICENSE

Apache License, Version 2.0.

## IMPORTANT LINKS

- https://github.com/coldbox-modules/cbmailservices
- http://forgebox.io/view/cbmailservices
- [Changelog](changelog.md)

## SYSTEM REQUIREMENTS

- Lucee 5+
- ColdFusion 2016+

## INSTRUCTIONS

Just drop into your modules folder or use the box-cli to install

`box install cbmailservices`

The mail services registers all mail components so you can use them in your application.

## Settings

You will need to update the your `ColdBox.cfc` with a `mailsettings` structure with your preferred mail settings and mail protocol to use.  All the keys that can go into the `mailsettings` struct map 1-1 to the `cfmail` tag except for the `tokenMarker` and `protocol` keys.  See below for more information on other protocols you can use.
 
```js
mailsettings = {
    // The default token Marker Symbol
    tokenMarker = "@",
    // protocol
    protocol = {
        class = "cbmailservices.models.protocols.CFMailProtocol",
        properties = {}
    }
};
```

## Models

This will register a `mailService@cbmailservices` in WireBox that you can leverage for usage.

```js
// build one-off mail
var mailService = getInstance( "mailService@cbmailservices" );
var oMail = mailService.newMail( 
	to="email@email.com",
	from="no_reply@ortussolutions.com",
	subject="Mail Services Rock",
	type="html",
	bodyTokens={ 
		user="Luis", 
		product="ColdBox", 
		link=event.buildLink( 'home' )
	}
);

// add a Body
oMail.setBody("
    <p>Dear @user@,</p>
    <p>Thank you for downloading @product@, have a great day!</p>
    <p><a href='@link@'>@link@</a></p> 
");

// send it
var results = mailService.send( oMail );
```

You can also inject mailService into your components as you would with other modules to avoid the getInstance() call.

```js
property name="mailService" inject="MailService@cbmailservices";
```

### Mail Additional Info

The `Mail` object has some additional methods to allow you to pass additional information so protocols can leverage them:

```js
setAdditionalInfo( struct );
getAdditionalInfo();

setAdditionalInfoItem( key, value );
getAdditionalInfoItem( key );
```

## Mail Protocols

The mail services can send mail via different protocols.  The available protocols are:

* `CFMailProtocol`
* `FileProtocol`
* `PostmarkProtocol`

You register the protocols in the `mailsettings` via the `protocol` structure:

```js
// FileProtocol
protocol = {
    class = "cbmailservices.models.protocols.FileProtocol",
    properties = {
        filePath = "logs",
        autoExpand = true
    }
}

// PostMark
protocol = {
    class = "cbmailservices.models.protocols.PostmarkProtocol",
    properties = {
        APIKey = ""
    }
}
```

### Custom Protocols

In order to create your own custom protocol you will create a CFC that inherits from `cbmailservices.models.AbstractProtocol` and make sure you implement the `init()` and `send()` method.

### Interception Points

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
