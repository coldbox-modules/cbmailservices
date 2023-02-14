# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangel#og.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

----


## [v2.7.1] => 2023-FEB-14

### Fixed

* Fix usage of invalid named member function #33 (https://github.com/coldbox-modules/cbmailservices/pull/33)

----


## [v2.7.0] => 2023-JAN-16

A big thanks to @richardherbert for all the updates in this release.

### Fixed

* FIXED var scoping of attachments variable
* Updated to handle a response that is not JSON
* 🐛 FIX: Update GHA to avoid deprecated syntax

### Added

* Added test for MAILGUN_BASEURL property
* Updated to make MAILGUN_APIURL optional
* Added support for Mailgun EU region by making MAILGUN_APIURL an optional property with https://api.mailgun.net/v3/ as the default.

### Changed

* Updated all GHA actions to latest versions and moved to use `temurin` Java distributions from adopt due to deprecation of the service.

----


## [v2.6.2] => 2022-DEC-20

### Fixed

* If the incoming `layout` arugment for the `setView()` method in the mail is empty, it should ignore it.

----

## [v2.6.1] => 2022-NOV-21

### Changed

* Less verbosity for the mail queue log

----

## [v2.6.0] => 2022-NOV-15

### Added

* New ColdBox 7 delegate `Mailable@cbmailservices` so you can easily add mailing capabilities to objects

----

## [v2.5.1] => 2022-NOV-1

### Fixed

* Fixing asset version

----

## [v2.5.0] => 2022-OCT-19

### Modified

* More updates of injections to generic `box` instead of `coldbox`.

----

## [v2.4.0] => 2022-AUG-20

### Modified

* Updated injections to generic `box` instead of `coldbox`.


----

## [v2.3.1] => 2022-AUG-04

### Fixed

* Fix github action

----

## [v2.3.0] => 2022-AUG-04

### Fixed

* Fixed build process so it doesn't include `box.bin` in the final artifact.

----

## [v2.2.0] => 2022-JUN-06

### Added

* Added mailgun protocol to available mail protocols @scottsteinbeck
----

## [v2.1.0] => 2022-MAY-17

### Added

* Ability for the `preMailSend` event to influence the `mail` record thanks to @gpickin
* Getters only work if there is a `variables.config` key in existence. Add reasonable defaults for commonly accessed mail fields
* New module setting: `runQueueTask` which is defaulted to `true`.  If `false` it will not run the mail queue task in the background

----

## [v2.0.4] => 2022-FEB-09

### Fixed

* `-snapshot` left on the box.json

### Added

* Github actions standards via new module template
* Reusable Workflows

----

## [v2.0.3] => 2021-NOV-17

### Fixed

* Fix for Default-Settings overwrites Mail-Bean Payload

----

## [v2.0.2] => 2021-NOV-17

### Fixed

* Fixed `getFileMimeType()` so postmark attachments can work. Thanks to @garciadev

----

## [v2.0.1] => 2021-NOV-12

### Fixed

* BOX-119 CBMailService - Setting the defaultProtocol in moduleSettings to something other than default gets ignored

----

## [v2.0.0] => 2021-NOV-08

### Changed

* `COMPATIBILITY` : Settings are now using ColdBox 5 module approach of `moduleSettings.cbmailservices` instead of a root key element called `cbmailservices`.  Make sure you update your settings and move them to `modulesettings.cbmailservices`
* `COMPATIBILITY` : Changed all arguments called `default` to `defaultValue` to avoid ACF issues with the parser
* `Mail` object `config()` renamed to `configure()`
* The return results structure from the protocols `errorArray` has been renamed to just `messages` as it can contain warnings, information messages as well as error messages
* PostmarkAPI result returns `MessageID` instead of `message_id` now.

### Added

* Ability for the mail payload to render the body from a view or a view/layout combination using the `setView()` method.
* New ability to queue mail for sending using the async scheduler for the module and the new `queue()` method
* New asynchronous mail sending via `sendAsync()` which returns a ColdBox Future
* New mixin helper: `newMail()` so you can get access to send mails easily in handlers and interceptors.
* In order to run and validate SMPT tests, we now use FakeSMTP as a container located in /test-harnes/tests/resources/docker-compose.yml.  This will send mail to disk for us when testing smtp. If you want to run the tests on your machine, you will need to startup the container.
* Every protocol now has a `log` LogBox logger configured object thanks to the `AbstractProtocol`.
* Every protocol gets a `name` property now for a numan readable name thanks to the `AbstractProtocol`.
* `Mail` object now can send itself via the new `send()` method which delegates to the service, but provides a nice sending DSL.
* `Mail` object now has dynamic getters and setters for ALL configuration objects.
* You can now use aliases to build out any of the core protocols: `CFMail, File, InMemory, Null or Postmark` instead of the full path.
* You can now use a wirebox id or class path as the protocol class apart from the core protocols.
* Added ability for the `getProperty( property, defaultValue )` method on the abstract protocol to have a default value.
* Migration to script of all core items.
* Migration to github actions.
* Adobe 2021 Support.
* Modernization of all source code.

### Removed

* `MailSettingsBean` removed in favor of a more cohesive `MailService`
* `protocol` setting removed in favor of multiple mailers approach and `defaultProtocol` usage. Please see docs.
* Adobe ColdFusion 2016 Support.

----

## [v1.6.0] => 2021-FEB-22

### Addded

* Two new protocols: `NullProtocol, InMemoryProtocol`
  * The `NullProtocol` ignores all calls to it.
  * The `InMemoryProtocol` stores mail mementos in an internal array. This can be useful for testing to check that mail was sent. It also includes a handle `hasMessage` method which takes a predicate callback and checks it against each sent mail. A `reset` method is included for use inside tests.
* New CI updates and code quality systems
* New updates for ColdBox 6

----

## [v1.5.0] => 2019-NOV-12

### New Features

* Added a `fromName` to the Mail bean to track names due to some protocols allowing it
* The module will register two interception points. `PreMailSend` and `PostMailSend`

### Improvements

* New module layout
* Removed unecessary routing endpoint

### Bugs

* Var scoping issue

----

## [v1.4.2]

* Fixes incorrect argument collection nesting on protocol registration

----

## [v1.4.1]

* Auto create folder paths in FileProtocol if they do not exist

----

## [v1.4.0]

* Updated to use module templating
* Proposed additionalInfo data struct for provider specific implementations. Added a couple of helper methods : https://github.com/coldbox-modules/cbox-mailservices/pull/5
* Updated to leverage WireBox for object creations instead of internal new and createobjects

----

## [v1.3.0]

* Fix on date formatting on file protocol thanks to @elpete
* Fix for type inclusion on the file protocol thanks to @elpete

----

## [v1.2.0]

* Travis integration
* DocBox updates
* Build process updates

----

## [v1.1.0]

* Updated build process
* Updated readme and instructions

----

## [v1.0.0]

* Create first module version
