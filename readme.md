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

Note: One of the features is the ability to queue emails for asynchronous (non-blocking) sending. This is done via a task runner which is on by default. 
This feature can be turned off, if desired, by these steps:
1. Open config/coldbox.cfc
   
2. In the modulesSettings section, add a key for cbmailServices with the property `runQueueTask` set to `false`. 

```
moduleSettings = {
	cbmailServices : {
		runQueueTask: false
	}
}
```

## View the documentation at https://coldbox-mailservices.ortusbooks.com

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
