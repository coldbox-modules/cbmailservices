<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>cbMailServices Log</title>
	<style>
		:root {
			color-scheme: light;
			--accent: #1457d9;
			--accent-soft: #eaf1ff;
			--background: #ffffff;
			--rail: #f6f8fb;
			--surface: #ffffff;
			--text: #101c3b;
			--muted: #64708a;
			--border: #d7deea;
			--border-strong: #b9c4d6;
			--success: #15803d;
			--danger: #b42318;
			--shadow: 0 12px 40px rgba( 20, 39, 78, .08 );
			font-family: Inter, ui-sans-serif, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
		}

		* { box-sizing: border-box; }

		html, body { height: 100%; }

		body {
			margin: 0;
			background: var( --background );
			color: var( --text );
			font-size: 15px;
			line-height: 1.45;
			overflow: hidden;
		}

		button, input { font: inherit; }

		button {
			color: inherit;
			cursor: pointer;
		}

		button:focus-visible, input:focus-visible, [tabindex]:focus-visible {
			outline: 3px solid rgba( 20, 87, 217, .28 );
			outline-offset: 2px;
		}

		.app {
			display: grid;
			grid-template-rows: 72px minmax( 0, 1fr ) 48px;
			height: 100%;
			min-height: 520px;
		}

		.app-header {
			display: grid;
			grid-template-columns: minmax( 260px, 1fr ) minmax( 300px, 430px ) auto;
			gap: 24px;
			align-items: center;
			padding: 0 28px;
			border-bottom: 1px solid var( --border-strong );
			background: var( --surface );
		}

		.brand {
			margin: 0;
			font-size: 25px;
			font-weight: 750;
			letter-spacing: -.025em;
		}

		.search {
			position: relative;
			display: flex;
			align-items: center;
		}

		.search svg {
			position: absolute;
			left: 14px;
			width: 20px;
			height: 20px;
			color: var( --muted );
			pointer-events: none;
		}

		.search input {
			width: 100%;
			height: 44px;
			padding: 0 42px;
			border: 1px solid var( --border-strong );
			border-radius: 8px;
			background: #fff;
			color: var( --text );
			font-size: 16px;
		}

		.search-shortcut {
			position: absolute;
			right: 11px;
			display: grid;
			place-items: center;
			width: 24px;
			height: 24px;
			border: 1px solid var( --border );
			border-radius: 5px;
			color: var( --muted );
			font: 12px/1 ui-monospace, SFMono-Regular, Menlo, monospace;
		}

		.header-actions {
			display: flex;
			gap: 10px;
			justify-content: flex-end;
		}

		.action {
			display: inline-flex;
			align-items: center;
			justify-content: center;
			gap: 8px;
			height: 42px;
			padding: 0 16px;
			border: 1px solid var( --border-strong );
			border-radius: 8px;
			background: #fff;
			font-size: 14px;
			font-weight: 650;
		}

		.action:hover { border-color: var( --accent ); color: var( --accent ); }

		.action.primary { border-color: var( --accent ); color: var( --accent ); }

		.action svg { width: 18px; height: 18px; }

		.app-body {
			display: grid;
			grid-template-columns: minmax( 320px, 30vw ) minmax( 0, 1fr );
			min-height: 0;
		}

		.inbox {
			display: grid;
			grid-template-rows: 56px minmax( 0, 1fr );
			min-width: 0;
			border-right: 1px solid var( --border-strong );
			background: var( --rail );
		}

		.inbox-heading {
			display: flex;
			align-items: center;
			justify-content: space-between;
			padding: 0 20px;
			border-bottom: 1px solid var( --border );
			color: var( --muted );
			font-size: 13px;
			font-weight: 650;
		}

		.message-list {
			margin: 0;
			padding: 0;
			list-style: none;
			overflow: auto;
		}

		.message-row {
			position: relative;
			display: grid;
			grid-template-columns: 10px minmax( 0, 1fr ) auto;
			gap: 12px;
			min-height: 102px;
			padding: 16px 18px;
			border: 0;
			border-bottom: 1px solid var( --border );
			background: transparent;
			text-align: left;
			width: 100%;
		}

		.message-row:hover { background: #f0f4fa; }

		.message-row[aria-current="true"] {
			background: var( --accent-soft );
			box-shadow: inset 3px 0 0 var( --accent );
		}

		.message-dot {
			width: 8px;
			height: 8px;
			margin-top: 6px;
			border-radius: 50%;
			background: var( --border-strong );
		}

		.message-row[aria-current="true"] .message-dot { background: var( --accent ); }

		.message-copy { min-width: 0; }

		.message-from, .message-subject, .message-to {
			display: block;
			overflow: hidden;
			text-overflow: ellipsis;
			white-space: nowrap;
		}

		.message-from {
			font-size: 14px;
			font-weight: 720;
		}

		.message-to {
			margin-top: 3px;
			color: var( --muted );
			font-size: 13px;
		}

		.message-subject {
			margin-top: 7px;
			font-size: 14px;
			font-weight: 620;
		}

		.message-time {
			color: var( --muted );
			font-size: 12px;
			white-space: nowrap;
		}

		.detail {
			display: grid;
			grid-template-rows: auto minmax( 0, 1fr );
			min-width: 0;
			background: var( --background );
		}

		.detail-empty, .list-empty, .error-state {
			display: grid;
			place-items: center;
			min-height: 100%;
			padding: 32px;
			color: var( --muted );
			text-align: center;
		}

		.empty-copy strong {
			display: block;
			margin-bottom: 6px;
			color: var( --text );
			font-size: 18px;
		}

		.detail-content { display: contents; }

		.detail-header {
			padding: 0 28px 22px;
			border-bottom: 1px solid var( --border );
		}

		.detail-tabs {
			display: flex;
			gap: 28px;
			height: 56px;
			border-bottom: 1px solid var( --border );
		}

		.tab {
			position: relative;
			border: 0;
			background: transparent;
			font-size: 14px;
			font-weight: 680;
		}

		.tab[aria-selected="true"] { color: var( --accent ); }

		.tab[aria-selected="true"]::after {
			position: absolute;
			left: 0;
			right: 0;
			bottom: -1px;
			height: 2px;
			background: var( --accent );
			content: "";
		}

		.back-button {
			display: none;
			align-items: center;
			gap: 6px;
			margin-right: auto;
			border: 0;
			background: transparent;
			color: var( --accent );
			font-weight: 680;
		}

		.metadata {
			display: grid;
			grid-template-columns: 80px minmax( 0, 1fr );
			gap: 8px 18px;
			margin: 22px 0 0;
		}

		.metadata dt { font-weight: 720; }

		.metadata dd {
			margin: 0;
			min-width: 0;
			overflow-wrap: anywhere;
		}

		.viewer {
			min-height: 0;
			padding: 18px;
			background: #f7f9fc;
		}

		.preview-frame, .source-view {
			width: 100%;
			height: 100%;
			border: 1px solid var( --border-strong );
			border-radius: 8px;
			background: #fff;
			box-shadow: var( --shadow );
		}

		.preview-frame { display: block; }

		.source-view {
			margin: 0;
			padding: 20px;
			overflow: auto;
			color: #243252;
			font: 13px/1.6 ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
			white-space: pre-wrap;
			word-break: break-word;
		}

		[hidden] { display: none !important; }

		.status-bar {
			display: flex;
			align-items: center;
			gap: 10px;
			min-width: 0;
			padding: 0 28px;
			border-top: 1px solid var( --border-strong );
			background: #fff;
			font-size: 12px;
		}

		.status-label {
			display: inline-flex;
			align-items: center;
			gap: 7px;
			color: var( --accent );
			font-weight: 720;
		}

		.status-dot {
			width: 8px;
			height: 8px;
			border-radius: 50%;
			background: var( --success );
		}

		.status-path {
			overflow: hidden;
			color: var( --text );
			font: 12px/1.4 ui-monospace, SFMono-Regular, Menlo, monospace;
			text-overflow: ellipsis;
			white-space: nowrap;
		}

		.status-summary { margin-left: auto; color: var( --muted ); white-space: nowrap; }

		.sr-only {
			position: absolute;
			width: 1px;
			height: 1px;
			padding: 0;
			margin: -1px;
			overflow: hidden;
			clip: rect( 0, 0, 0, 0 );
			white-space: nowrap;
			border: 0;
		}

		@media ( max-width: 800px ) {
			body { overflow: hidden; }
			.app { grid-template-rows: auto minmax( 0, 1fr ) 58px; min-height: 100%; }
			.app-header {
				grid-template-columns: minmax( 0, 1fr ) auto;
				gap: 14px;
				padding: 18px;
			}
			.brand { font-size: 20px; }
			.search { grid-column: 1 / -1; grid-row: 2; }
			.search input { height: 48px; }
			.search-shortcut, .clear-action { display: none; }
			.header-actions { grid-column: 2; grid-row: 1; }
			.action { min-width: 44px; height: 44px; padding: 0 10px; border-color: transparent; }
			.app-body { display: block; position: relative; overflow: hidden; }
			.inbox, .detail { position: absolute; inset: 0; }
			.inbox { border-right: 0; }
			.detail { visibility: hidden; transform: translateX( 100% ); transition: transform 180ms ease; }
			.detail-open .detail { visibility: visible; transform: translateX( 0 ); }
			.detail-open .inbox { visibility: hidden; }
			.inbox-heading { height: 44px; padding: 0 18px; }
			.message-row { min-height: 112px; padding: 18px; }
			.detail-header { padding: 0 18px 18px; }
			.detail-tabs { align-items: center; height: 54px; }
			.back-button { display: inline-flex; }
			.metadata { grid-template-columns: 58px minmax( 0, 1fr ); margin-top: 16px; font-size: 13px; }
			.viewer { padding: 10px; }
			.preview-frame, .source-view { border-radius: 6px; }
			.status-bar { align-items: flex-start; flex-wrap: wrap; gap: 3px 9px; padding: 9px 18px; }
			.status-path { flex-basis: calc( 100% - 90px ); }
			.status-summary { display: none; }
		}

		@media ( prefers-reduced-motion: reduce ) {
			.detail { transition: none; }
		}
	</style>
</head>
<body>
	<div class="app" id="app">
		<header class="app-header">
			<h1 class="brand">cbMailServices Log</h1>
			<label class="search">
				<span class="sr-only">Search messages</span>
				<svg aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-4-4"></path></svg>
				<input id="search" type="search" placeholder="Search messages" autocomplete="off">
				<span class="search-shortcut" aria-hidden="true">/</span>
			</label>
			<div class="header-actions">
				<button class="action primary" id="refresh" type="button">
					<svg aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 7v5h-5"></path><path d="M4 17v-5h5"></path><path d="M6.1 9a7 7 0 0 1 11.5-2L20 12"></path><path d="m4 12 2.4 5a7 7 0 0 0 11.5-2"></path></svg>
					<span>Refresh</span>
				</button>
				<button class="action clear-action" id="clear" type="button">Clear filters</button>
			</div>
		</header>

		<main class="app-body">
			<aside class="inbox" aria-label="Logged messages">
				<div class="inbox-heading">
					<span id="message-count">Loading messages</span>
					<span>All time</span>
				</div>
				<ul class="message-list" id="message-list"></ul>
			</aside>

			<section class="detail" aria-label="Selected message">
				<div class="detail-empty" id="detail-empty">
					<div class="empty-copy"><strong>Select a message</strong>Choose a logged email to inspect its preview and source.</div>
				</div>
				<div class="detail-content" id="detail-content" hidden>
					<header class="detail-header">
						<div class="detail-tabs" role="tablist" aria-label="Message view">
							<button class="back-button" id="back" type="button">
								<svg aria-hidden="true" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m15 18-6-6 6-6"></path></svg>
								Back
							</button>
							<button class="tab" id="preview-tab" type="button" role="tab" aria-controls="preview-frame" aria-selected="true">Preview</button>
							<button class="tab" id="source-tab" type="button" role="tab" aria-controls="source-view" aria-selected="false">Source</button>
						</div>
						<dl class="metadata">
							<dt>From</dt><dd id="meta-from"></dd>
							<dt>To</dt><dd id="meta-to"></dd>
							<dt>Subject</dt><dd id="meta-subject"></dd>
							<dt>Sent</dt><dd id="meta-sent"></dd>
						</dl>
					</header>
					<div class="viewer">
						<iframe class="preview-frame" id="preview-frame" title="Rendered email preview" sandbox="allow-popups allow-popups-to-escape-sandbox"></iframe>
						<pre class="source-view" id="source-view" role="tabpanel" tabindex="0" hidden></pre>
					</div>
				</div>
			</section>
		</main>

		<footer class="status-bar">
			<span class="status-label"><span class="status-dot"></span>Watching</span>
			<span class="status-path" id="status-path">Discovering File protocol…</span>
			<span class="status-summary" id="status-summary">Auto-refresh every 5s</span>
		</footer>
	</div>

	<div class="sr-only" id="announcer" aria-live="polite"></div>

	<script>
		( () => {
			"use strict";

			const basePath = window.location.pathname.replace( /\/$/, "" );
			const state = { messages: [], filtered: [], selectedId: null, selected: null, loading: false, tab: "preview" };
			const elements = {
				app: document.getElementById( "app" ),
				search: document.getElementById( "search" ),
				refresh: document.getElementById( "refresh" ),
				clear: document.getElementById( "clear" ),
				list: document.getElementById( "message-list" ),
				count: document.getElementById( "message-count" ),
				empty: document.getElementById( "detail-empty" ),
				content: document.getElementById( "detail-content" ),
				back: document.getElementById( "back" ),
				previewTab: document.getElementById( "preview-tab" ),
				sourceTab: document.getElementById( "source-tab" ),
				preview: document.getElementById( "preview-frame" ),
				source: document.getElementById( "source-view" ),
				path: document.getElementById( "status-path" ),
				summary: document.getElementById( "status-summary" ),
				announcer: document.getElementById( "announcer" )
			};

			const escapeHTML = ( value ) => String( value || "" )
				.replaceAll( "&", "&amp;" )
				.replaceAll( "<", "&lt;" )
				.replaceAll( ">", "&gt;" )
				.replaceAll( '"', "&quot;" )
				.replaceAll( "'", "&#039;" );

			const timeLabel = ( value ) => {
				const parsed = new Date( value );
				if ( Number.isNaN( parsed.getTime() ) ) {
					return value || "Unknown time";
				}
				const today = new Date();
				if ( parsed.toDateString() === today.toDateString() ) {
					return new Intl.DateTimeFormat( undefined, { hour: "numeric", minute: "2-digit" } ).format( parsed );
				}
				return new Intl.DateTimeFormat( undefined, { month: "short", day: "numeric" } ).format( parsed );
			};

			const fullTimeLabel = ( value ) => {
				const parsed = new Date( value );
				if ( Number.isNaN( parsed.getTime() ) ) {
					return value || "Unknown time";
				}
				return new Intl.DateTimeFormat( undefined, { dateStyle: "medium", timeStyle: "medium" } ).format( parsed );
			};

			const announce = ( message ) => { elements.announcer.textContent = message; };

			function renderList(){
				const query = elements.search.value.trim().toLowerCase();
				state.filtered = state.messages.filter( ( message ) => {
					return [ message.from, message.to, message.subject, message.fileName, message.mailer ]
						.some( ( value ) => String( value || "" ).toLowerCase().includes( query ) );
				} );

				elements.count.textContent = `${ state.filtered.length } ${ state.filtered.length === 1 ? "message" : "messages" }`;
				if ( !state.filtered.length ) {
					elements.list.innerHTML = '<li class="list-empty"><div class="empty-copy"><strong>No messages found</strong>Try another search or send a new local email.</div></li>';
					return;
				}

				elements.list.innerHTML = state.filtered.map( ( message ) => `
					<li>
						<button class="message-row" type="button" data-message-id="${ escapeHTML( message.id ) }" aria-current="${ message.id === state.selectedId }">
							<span class="message-dot" aria-hidden="true"></span>
							<span class="message-copy">
								<span class="message-from">${ escapeHTML( message.from || "Unknown sender" ) }</span>
								<span class="message-to">To: ${ escapeHTML( message.to || "Unknown recipient" ) }</span>
								<span class="message-subject">${ escapeHTML( message.subject || "(No subject)" ) }</span>
							</span>
							<time class="message-time">${ escapeHTML( timeLabel( message.sent ) ) }</time>
						</button>
					</li>
				` ).join( "" );
			}

			function setTab( tab ){
				state.tab = tab;
				const previewActive = tab === "preview";
				elements.previewTab.setAttribute( "aria-selected", String( previewActive ) );
				elements.sourceTab.setAttribute( "aria-selected", String( !previewActive ) );
				elements.preview.hidden = !previewActive;
				elements.source.hidden = previewActive;
			}

			async function selectMessage( id, options = {} ){
				state.selectedId = id;
				renderList();
				try {
					const response = await fetch( `${ basePath }/message/${ encodeURIComponent( id ) }`, { headers: { Accept: "application/json" } } );
					if ( !response.ok ) {
						throw new Error( "Unable to load that mail log." );
					}
					state.selected = await response.json();
					document.getElementById( "meta-from" ).textContent = state.selected.from || "Unknown sender";
					document.getElementById( "meta-to" ).textContent = state.selected.to || "Unknown recipient";
					document.getElementById( "meta-subject" ).textContent = state.selected.subject || "(No subject)";
					document.getElementById( "meta-sent" ).textContent = fullTimeLabel( state.selected.sent );
					elements.preview.srcdoc = state.selected.preview || state.selected.source;
					elements.source.textContent = state.selected.source;
					elements.empty.hidden = true;
					elements.content.hidden = false;
					if ( options.openDetail !== false ) {
						elements.app.classList.add( "detail-open" );
					}
					setTab( state.tab );
					if ( !options.silent && options.openDetail !== false ) {
						history.replaceState( {}, "", `${ basePath }?message=${ encodeURIComponent( id ) }` );
						announce( `Opened ${ state.selected.subject || "message" }` );
					}
				} catch ( error ) {
					announce( error.message );
				}
			}

			async function loadMessages( options = {} ){
				if ( state.loading ) {
					return;
				}
				state.loading = true;
				elements.refresh.disabled = true;
				try {
					const response = await fetch( `${ basePath }/messages`, { headers: { Accept: "application/json" } } );
					if ( !response.ok ) {
						throw new Error( "Unable to read the configured mail logs." );
					}
					const data = await response.json();
					state.messages = data.messages || [];
					elements.path.textContent = data.sources.length
						? data.sources.map( ( source ) => source.path ).join( " · " )
						: "No File protocol is configured";
					elements.path.title = elements.path.textContent;
					elements.summary.textContent = `Auto-refresh every 5s  |  ${ state.messages.length } messages`;
					renderList();

					const requestedId = new URLSearchParams( window.location.search ).get( "message" );
					const nextId = state.selectedId || requestedId || state.messages[ 0 ]?.id;
					if ( nextId && state.messages.some( ( message ) => message.id === nextId ) ) {
						if ( !options.silent || !state.selected || state.selectedId !== nextId ) {
							const openDetail = Boolean( requestedId )
								|| !window.matchMedia( "(max-width: 800px)" ).matches
								|| elements.app.classList.contains( "detail-open" );
							await selectMessage( nextId, { silent: Boolean( options.silent ), openDetail } );
						}
					} else if ( !state.messages.length ) {
						state.selectedId = null;
						state.selected = null;
						elements.content.hidden = true;
						elements.empty.hidden = false;
						elements.app.classList.remove( "detail-open" );
						elements.empty.innerHTML = '<div class="empty-copy"><strong>No logged mail yet</strong>Send mail through a configured File protocol and it will appear here.</div>';
					}
					if ( !options.silent ) {
						announce( `Loaded ${ state.messages.length } messages` );
					}
				} catch ( error ) {
					elements.list.innerHTML = `<li class="error-state">${ escapeHTML( error.message ) }</li>`;
					elements.path.textContent = "Mail log unavailable";
					announce( error.message );
				} finally {
					state.loading = false;
					elements.refresh.disabled = false;
				}
			}

			elements.list.addEventListener( "click", ( event ) => {
				const row = event.target.closest( "[data-message-id]" );
				if ( row ) {
					selectMessage( row.dataset.messageId );
				}
			} );
			elements.search.addEventListener( "input", renderList );
			elements.refresh.addEventListener( "click", () => loadMessages() );
			elements.clear.addEventListener( "click", () => {
				elements.search.value = "";
				renderList();
				elements.search.focus();
			} );
			elements.previewTab.addEventListener( "click", () => setTab( "preview" ) );
			elements.sourceTab.addEventListener( "click", () => setTab( "source" ) );
			elements.back.addEventListener( "click", () => {
				elements.app.classList.remove( "detail-open" );
				elements.list.querySelector( `[data-message-id="${ state.selectedId }"]` )?.focus();
			} );

			document.addEventListener( "keydown", ( event ) => {
				if ( event.key === "/" && document.activeElement !== elements.search ) {
					event.preventDefault();
					elements.search.focus();
				}
				if ( event.key === "Escape" && document.activeElement === elements.search ) {
					elements.search.value = "";
					renderList();
				}
			} );

			loadMessages();
			window.setInterval( () => loadMessages( { silent: true } ), 5000 );
		} )();
	</script>
</body>
</html>
