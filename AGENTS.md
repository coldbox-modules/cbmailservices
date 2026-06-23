### Quick orientation — cbmailservices (ColdBox module)

This repository is a ColdBox module that provides fluent, protocol-agnostic email sending with support for multiple mail backends (CFMail, Mailgun, Postmark, File, InMemory), async queuing, token replacement, and a scheduler for queue processing.

Keep guidance short and actionable. Prefer small, verifiable edits and reference the real files below.

1) Big picture
- ColdBox module: entrypoint and wiring in `ModuleConfig.cfc`.
- The core service `models/MailService.cfc` (singleton, WireBox ID: `MailService@cbmailservices`) manages:
  - Registered mailer protocols via `variables.mailers` (a struct of named protocol configurations).
  - A `ConcurrentLinkedQueue` (`models/ConcurrentLinkedQueue.cfc`) for async mail queuing.
  - Token replacement in mail bodies using `@token@` markers.
  - Announcement of `preMailSend` and `postMailSend` interception points.
- The `Mail` object (`models/Mail.cfc`) is a fluent builder for email payloads: `setTo()`, `setFrom()`, `setSubject()`, `setBody()`, `addMailPart()`, `addMailParam()`, etc. All config lives in `variables.config`.
- Sending happens via `mailService.send( mail )` or `mailService.sendAsync( mail )` (returns a ColdBox Future).
- The mixin helper `helpers/mixins.cfm` exposes `newMail()` in handlers/interceptors/models.
- The `Mailable` delegate (`models/delegates/Mailable.cfc`) can be mixed into any object to inject the MailService and delegate `newMail()`.

2) Source layout at a glance
- **Core service**: `models/MailService.cfc` — protocol registry, newMail(), send()/sendAsync(), processQueue(), token replacement, configuration merging.
- **Mail payload**: `models/Mail.cfc` — fluent property setters, body/content/buildBody(), addMailPart()/addMailParam(), struct/JSON serialization, HTML/template rendering.
- **Protocols**: `models/protocols/` — `CFMailProtocol.cfc` (native cfmail tag), `FileProtocol.cfc` (writes .eml files), `InMemoryProtocol.cfc` (test-friendly, stores mail in array), `MailgunProtocol.cfc` (Mailgun REST API), `NullProtocol.cfc` (no-op), `PostmarkProtocol.cfc` (Postmark REST API). All extend `models/AbstractProtocol.cfc`.
- **AbstractProtocol**: `models/AbstractProtocol.cfc` — base class with `properties` struct, `send()` contract (must be implemented by protocols).
- **Queue**: `models/ConcurrentLinkedQueue.cfc` — thread-safe linked queue for async mail jobs.
- **Delegates**: `models/delegates/Mailable.cfc` — injects `MailService@cbmailservices`, delegates `newMail()`.
- **Helpers**: `helpers/mixins.cfm` — exposes `newMail()` mixin via `this.applicationHelper`.
- **Config**: `config/Scheduler.cfc` — ColdBox scheduled task `MailQueue` that calls `MailService.processQueue()` every minute with no overlaps, gated by `runQueueTask` setting.
- **Module wiring**: `ModuleConfig.cfc` and `box.json` for metadata, dependencies, and scripts.
- **Build/CI**: `build/Build.cfc`, `build/release.boxr`.

3) Developer workflows (how to run, test, build)
- Install deps and test harness: `box install` at repo root.
- Run local server: `box server start serverConfigFile="server-{engine}.json"` where engine is one of `lucee@6`, `adobe@2023`, `adobe@2025`, `boxlang@1`, `boxlang-cfml@1`.
- Start fake SMTP server (needed for integration tests): `docker compose -f test-harness/tests/resources/docker-compose.yml up --detach`.
- Run tests: `box testbox run --verbose` (server must be running on port 60299). Or open `http://localhost:60299/tests/runner.cfm`.
- Run build tasks: `box task run taskFile=build/Build.cfc`.
- Server configs available: `server-lucee@6.json`, `server-adobe@2023.json`, `server-adobe@2025.json`, `server-boxlang@1.json` (no cfml compat), `server-boxlang-cfml@1.json` (with cfml compat).

4) Patterns & conventions to follow
- **MailService protocol lookup**: When calling `newMail( mailer="xyz" )`, the service looks up `variables.mailers[ mailer ]` for the protocol class and settings. Default mailer is `"default"`.
- **Protocol contract**: Every protocol must implement a `send( required mail )` method that receives the `Mail` object. Return value should include `{ error : boolean, messages : [] }`.
- **Mail payload flow**: `mailService.newMail()` → configure Mail object fluently → `mailService.send( mail )` or `mailService.sendAsync( mail )` for queued sending.
- **Token replacement**: Body text uses `@variableName@` tokens. The `tokenMarker` module setting controls the delimiter (default `@`). Tokens are replaced from `mail.config.bodyTokens`.
- **Module settings structure**: `{ tokenMarker, defaultProtocol, mailers: { name: { class, properties } }, defaults: {}, runQueueTask: boolean }`. Protocol classes resolve relative to `cbmailservices.models.protocols.*` namespace.
- **WireBox ID to preserve**: `MailService@cbmailservices`.
- **Interceptor points**: `preMailSend` and `postMailSend` fire around every `send()` call with the Mail payload in the event data.

5) Events & integration points
- `preMailSend` — announced before a mail is sent. The Mail object is in the interception data.
- `postMailSend` — announced after a mail is sent. The Mail object (with results populated) is in the interception data.
- The scheduler `MailQueue` processes queued mails every minute via `processQueue()`. This can be disabled via the `runQueueTask` module setting.
- Custom interception points are registered in `ModuleConfig.cfc` → `interceptorSettings.customInterceptionPoints`.

6) Tests & test-harness specifics
- Test harness lives in `test-harness/`. Contains a minimal ColdBox app.
- Test specs: `test-harness/tests/specs/` — `AbstractProtocolTest.cfc`, `ConcurrentLinkedQueueTest.cfc`, `IntegrationTest.cfc`, `MailServiceTest.cfc`, `MailTest.cfc`, `protocols/` (per-protocol tests).
- Integration tests rely on a fake SMTP server via `test-harness/tests/resources/docker-compose.yml` (MailHog on port 1025/8025).
- Test resources: `test-harness/tests/resources/` (docker-compose, mail templates, etc.).
- Runner: `test-harness/tests/runner.cfm` expects a running CF server on port 60299.

7) Small, high-value tasks for AI agents
- Add a new protocol by extending `AbstractProtocol`, implementing `send()`, and registering it in module settings.
- Add a focused unit test for a protocol's `send()` method in `test-harness/tests/specs/protocols/`.
- When changing `MailService.send()` or token replacement logic, update `test-harness/tests/specs/MailServiceTest.cfc`.
- Preserve the `MailService@cbmailservices` WireBox ID and the `send( mail )` / `sendAsync( mail )` signatures.
- When adding new Mail properties, update `Mail.cfc`'s `onMissingMethod` or add explicit getters/setters, and update `MailTest.cfc`.

8) Safety and CI
- CI uses `build/Build.cfc` and `box.json` scripts. Do not modify CI scripts without updating `box.json` and `build/Build.cfc`.
- GitHub Actions workflows in `.github/workflows/`: `cron.yml`, `pr.yml`, `release.yml`, `snapshot.yml`, `tests.yml`.
- `.env` file for local environment overrides (see `.env.example` if present).
- The `tests.yml` matrix covers: `boxlang-cfml@1`, `adobe@2023`, `adobe@2025`, `boxlang@1`, `lucee@6` with ColdBox `^8.0.0` plus experimental `be` runs for all engines.

9) AI agent skills (`.agents/skills/`)
- 71 skill definitions are available in `.agents/skills/`, sourced from ortus-boxlang/skills and coldbox/skills GitHub repos.
- **BoxLang (29)**: language fundamentals, OOP, async, caching, config, database, security, testing, web, CLI, CommandBox, miniserver, interceptors, modules, files, zip, scheduled tasks, cfml-migration, java-integration, docbox, code-documenter, code-reviewer, best-practices, functional-programming, templating, application-descriptor, file-watchers, ortus-coding-standards.
- **ColdBox (32)**: handler/interceptor/layout/module development, routing, REST API, event model, DI (WireBox), cache, async, logging, config, CLI, proxy, decorators, flash messaging, request context, AI integration, app layouts, view rendering, scheduled tasks, reviewer, documenter, testing (base classes, handler, http-methods, integration, interceptor, model), database-migrations, wirebox-aop.
- **TestBox (10)**: BDD, xUnit, assertions, expectations, mockbox, cbmockdata, runners, reporters, listeners, testing-coverage, testing-fixtures.
- Skills lock file: `skills-lock.json` tracks source hashes for all installed skills.

If anything above is unclear or missing (protocol contract expectations, scheduler configuration, async patterns), tell me which area to expand and I will iterate.
