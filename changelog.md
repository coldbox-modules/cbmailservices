# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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