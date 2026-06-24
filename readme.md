<p align="center">
	<img src="https://www.ortussolutions.com/__media/coldbox-185-logo.png">
	<br>
	<img src="https://www.ortussolutions.com/__media/wirebox-185.png" height="125">
	<img src="https://www.ortussolutions.com/__media/cachebox-185.png" height="125" >
	<img src="https://www.ortussolutions.com/__media/logbox-185.png"  height="125">
</p>

<p align="center">
	Copyright Since 2005 ColdBox Platform by Luis Majano and Ortus Solutions, Corp
	<br>
	<a href="https://www.coldbox.org">www.coldbox.org</a> |
	<a href="https://www.ortussolutions.com">www.ortussolutions.com</a>
</p>

----

# Welcome to the ColdBox Mail Services => (`cbmailservices`)

Sending email doesn't have to be complicated or archaic or sad 😭. The ColdBox Mail Services (`cbmailservices`) module will allow you to send email in a fluent and abstracted way in multiple protocols for many environments in a single cohesive API, which will bring you smiles 😍, rainbows 🌈 and unicorns 🦄!. The supported protocols are:

| Protocol     	| Description |
|---------------|-------------|
| `BXMail` 		| Sending mail via BoxLang's `bx:mail` component |
| `CFMail` 		| Traditional sending via the `mail` component in a CFML engine. |
| `File`      	| Sends mails to a location on disk as `.html` files. |
| `InMemory` 	| Store email mementos in an array. Perfect for testing. |
| `Null` 		| Ignores emails send to it! |
| `MailGun` 	| Sends mail via the Mailgun API Services (https://www.mailgun.com) |
| `Postmark`	| Send via the PostMark API Service (https://postmarkapp.com/) |

It also sports tons of useful features for mail sending:

* Async Mail
* Mail Queues
* Mail merging of variables
* Mail attachments, headers and parameters
* View and Layout+View rendering for mail
* Mail tracking
* Multiple mailers
* Success and Error callbacks
* `Mailable@cbmailservices` delegate for adding mailing traits to objects.
* So Much More!

Note: One of the features is the ability to queue emails for asynchronous (non-blocking) sending. This is done via a task runner which is on by default.
This feature can be turned off, if desired, by these steps:

## Configuration

There are two ways to configure cbmailservices in your application.

### Via `moduleSettings` in `ColdBox.cfc` / `ColdBox.bx`

Add a `cbmailservices` key under `moduleSettings`:

```javascript
// config/ColdBox.cfc or config/ColdBox.bx
moduleSettings = {
    cbmailservices = {
        // The default token Marker Symbol
        tokenMarker     : "@",
        // Default protocol to use, it must be defined in the mailers configuration
        defaultProtocol : "default",
        // Here you can register one or many mailers by name
        mailers         : {
            "default"  : { class : "CFMail" },
            "files"    : { class : "File",    properties : { filePath : "/logs" } },
            "postmark" : { class : "Postmark", properties : { apiKey : "234" } },
            "mailgun"  : { class : "Mailgun",  properties : {
                apiKey : "234",
                domain : "mailgun.example.com"
            } }
        },
        // The defaults for all mail config payloads and protocols
        defaults : {
            from : "info@mydomain.com",
            cc   : "sales@mydomain.com"
        },
        // Whether the scheduled task is running or not
        runQueueTask : true
    }
}
```

### Via Module Config Override

Create a dedicated configuration file at `config/modules/cbmailservices.cfc` (CFML) or `config/modules/cbmailservices.bx` (BoxLang). This keeps your mail configuration separate from the main app config.

**CFML (`config/modules/cbmailservices.cfc`):**

```javascript
component {
    function configure(){
        return {
            tokenMarker     : "@",
            defaultProtocol : "default",
            mailers         : {
                "default"  : { class : "CFMail" },
                "files"    : { class : "File",    properties : { filePath : "/logs" } },
                "postmark" : { class : "Postmark", properties : { apiKey : "234" } },
                "mailgun"  : { class : "Mailgun",  properties : {
                    apiKey : "234",
                    domain : "mailgun.example.com"
                } }
            },
            defaults : {
                from : "info@mydomain.com",
                cc   : "sales@mydomain.com"
            },
            runQueueTask : true
        }
    }
}
```

**BoxLang (`config/modules/cbmailservices.bx`):**

```java
class {
    function configure(){
        return {
            tokenMarker     : "@",
            defaultProtocol : "default",
            mailers         : { ... },
            defaults        : { from : "info@mydomain.com", cc : "sales@mydomain.com" },
            runQueueTask    : true
        }
    }
}
```

### Configuration Reference

| Setting | Default | Description |
|---------|---------|-------------|
| `tokenMarker` | `@` | Character used for mail merge token delimiters (`@{key}@`) |
| `defaultProtocol` | `"default"` | The mailer key to use by default |
| `mailers` | `{ default: { class: "CFMail" } }` | Struct of named mailer protocol registrations |
| `defaults` | `{}` | Default variables seeded into every Mail payload |
| `runQueueTask` | `true` | Whether to run the background scheduler for async mail |


## View the documentation at https://coldbox-mailservices.ortusbooks.com

## LICENSE

Apache License, Version 2.0.

## IMPORTANT LINKS

* Source: https://github.com/coldbox-modules/cbmailservices
* ForgeBox: http://forgebox.io/view/cbmailservices
* Docs: https://coldbox-mailservices.ortusbooks.com
* [Changelog](changelog.md)

## SYSTEM REQUIREMENTS

* BoxLang 1+ (Preferred)
* Lucee 6+
* ColdFusion 2023+

********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

## HONOR GOES TO GOD ABOVE ALL

Because of His grace, this project exists. If you don't like this, then don't read it, its not for you.

>"Therefore being justified by faith, we have peace with God through our Lord Jesus Christ:
By whom also we have access by faith into this grace wherein we stand, and rejoice in hope of the glory of God.
And not only so, but we glory in tribulations also: knowing that tribulation worketh patience;
And patience, experience; and experience, hope:
And hope maketh not ashamed; because the love of God is shed abroad in our hearts by the
Holy Ghost which is given unto us. ." Romans 5:5

### THE DAILY BREAD

 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12
