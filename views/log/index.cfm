<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>cbMailServices Log</title>
        <script>
        ( () => {
            "use strict";

            const systemPrefersDark = window.matchMedia( "(prefers-color-scheme: dark)" ).matches;
            let theme = systemPrefersDark ? "dark" : "light";

            try {
                const savedTheme = window.localStorage.getItem( "cbmailservices-log-theme" );
                if ( savedTheme === "light" || savedTheme === "dark" ) {
                    theme = savedTheme;
                }
            } catch ( error ) {
                // Local storage can be unavailable in privacy-restricted browser contexts.
            }

            document.documentElement.dataset.theme = theme;
        } )();
        </script>
        <style>
            :root {
            color-scheme: light;
            --accent: #087f9f;
            --accent-strong: #006982;
            --accent-soft: #dff5fa;
            --background: #edf4f9;
            --rail: #f5f9fc;
            --surface: #ffffff;
            --surface-raised: #e9f4f8;
            --header: #ffffff;
            --header-action: rgba( 255, 255, 255, .82 );
            --detail-header: #f9fbfd;
            --viewer: #e8f0f6;
            --text: #121a36;
            --muted: #5e6e8a;
            --heading-muted: #52617e;
            --border: #d7e2ec;
            --border-strong: #b7cadb;
            --row-hover: #eaf3f8;
            --row-selected-start: #dff5fa;
            --row-selected-end: #eaf6fb;
            --row-selected-border: #77bdd0;
            --message-icon: #7184a3;
            --message-subject: #344462;
            --search-placeholder: #7686a1;
            --source-text: #273656;
            --success: #3fcb78;
            --success-ring: rgba( 29, 145, 78, .12 );
            --danger: #c72f48;
            --preview: #ffffff;
            --shadow: 0 18px 48px rgba( 30, 65, 95, .15 );
            --geometry: conic-gradient( from 205deg at 50% 75%, #d6edf5, #9bd9e8, #5abbd3, #8acfe1, #d9eff6, #d6edf5 );
            --geometry-opacity: .76;
            --focus-ring: rgba( 8, 127, 159, .3 );
            font-family: Inter, ui-sans-serif, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            }

            :root[data-theme="dark"] {
            color-scheme: dark;
            --accent: #63d8f4;
            --accent-strong: #1fc5ee;
            --accent-soft: #162a52;
            --background: #08091b;
            --rail: #090d21;
            --surface: #0c1129;
            --surface-raised: #111936;
            --header: #070819;
            --header-action: rgba( 8, 9, 27, .74 );
            --detail-header: #0b1026;
            --viewer: #080d20;
            --text: #f7f9ff;
            --muted: #aab5d3;
            --heading-muted: #c9d2ea;
            --border: #263757;
            --border-strong: #365174;
            --row-hover: #0f1732;
            --row-selected-start: #162b54;
            --row-selected-end: #142243;
            --row-selected-border: #35567c;
            --message-icon: #9db0d5;
            --message-subject: #d9e1f3;
            --search-placeholder: #8d9abb;
            --source-text: #273656;
            --success: #3fcb78;
            --success-ring: rgba( 63, 203, 120, .1 );
            --danger: #ff7a8a;
            --preview: #ffffff;
            --shadow: 0 18px 48px rgba( 0, 0, 0, .28 );
            --geometry: conic-gradient( from 205deg at 50% 75%, #11204d, #183477, #174fa1, #172968, #0d1538, #11204d );
            --geometry-opacity: .74;
            --focus-ring: rgba( 99, 216, 244, .35 );
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
            outline: 3px solid var( --focus-ring );
            outline-offset: 2px;
            }

            .app {
            display: grid;
            grid-template-rows: 80px minmax( 0, 1fr ) 52px;
            height: 100%;
            min-height: 520px;
            }

            .app-header {
            position: relative;
            display: grid;
            grid-template-columns: minmax( 430px, 1fr ) minmax( 260px, 420px ) auto;
            gap: 20px;
            align-items: center;
            padding: 0 30px;
            border-bottom: 1px solid var( --border-strong );
            background: var( --header );
            overflow: hidden;
            }

            .brand-lockup {
            position: relative;
            z-index: 1;
            display: flex;
            align-items: center;
            min-width: 0;
            }

            .coldbox-logo {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            flex: 0 0 auto;
            color: var( --text );
            font-size: 16px;
            font-weight: 780;
            letter-spacing: -.025em;
            }

            .coldbox-mark {
            width: 42px;
            height: 42px;
            flex: 0 0 auto;
            }

            .coldbox-wordmark sup {
            position: relative;
            top: -.35em;
            margin-left: 1px;
            font-size: 7px;
            }

            .brand-divider {
            width: 1px;
            height: 42px;
            margin: 0 24px;
            background: var( --border-strong );
            }

            .brand-title {
            margin: 0;
            overflow: hidden;
            font-size: 24px;
            font-weight: 750;
            letter-spacing: -.025em;
            text-overflow: ellipsis;
            white-space: nowrap;
            }

            .brand-geometry {
            position: absolute;
            top: -38px;
            right: -28px;
            width: 250px;
            height: 150px;
            background: var( --geometry );
            clip-path: polygon( 40% 0, 100% 0, 100% 100%, 4% 100%, 23% 62% );
            opacity: var( --geometry-opacity );
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
            height: 46px;
            padding: 0 42px;
            border: 1px solid var( --border );
            border-radius: 7px;
            background: var( --surface );
            color: var( --text );
            font-size: 15px;
            box-shadow: inset 0 1px 0 rgba( 255, 255, 255, .025 );
            }

            .search input::placeholder { color: var( --search-placeholder ); }

            .search input:hover { border-color: var( --border-strong ); }

            .search input:focus { border-color: var( --accent ); }

            .search-shortcut {
            position: absolute;
            right: 11px;
            display: grid;
            place-items: center;
            width: 24px;
            height: 24px;
            border: 1px solid var( --border-strong );
            border-radius: 4px;
            color: var( --muted );
            font: 12px/1 ui-monospace, SFMono-Regular, Menlo, monospace;
            }

            .header-actions {
            position: relative;
            z-index: 1;
            display: flex;
            gap: 4px;
            justify-content: flex-end;
            }

            .action {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            height: 42px;
            padding: 0 14px;
            border: 1px solid var( --border-strong );
            border-radius: 6px;
            background: var( --header-action );
            color: var( --accent );
            font-size: 14px;
            font-weight: 650;
            }

            .action:hover { border-color: var( --accent ); background: var( --surface-raised ); }

            .action.primary { color: var( --accent ); }

            .action:disabled { cursor: progress; opacity: .55; }

            .action svg { width: 18px; height: 18px; }

            .theme-action {
            width: 42px;
            padding: 0;
            }

            .theme-icon { display: none; }

            :root[data-theme="light"] .theme-icon-moon,
            :root[data-theme="dark"] .theme-icon-sun { display: block; }

            .app-body {
            display: grid;
            grid-template-columns: minmax( 360px, 34vw ) minmax( 0, 1fr );
            min-height: 0;
            overflow: hidden;
            }

            .inbox {
            display: grid;
            grid-template-rows: 68px 52px minmax( 0, 1fr );
            min-height: 0;
            min-width: 0;
            border-right: 1px solid var( --border-strong );
            background: var( --rail );
            }

            .inbox-heading {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 18px;
            padding: 0 24px;
            border-bottom: 1px solid var( --border-strong );
            color: var( --heading-muted );
            font-size: 13px;
            font-weight: 650;
            }

            .inbox-title {
            margin-right: auto;
            color: var( --text );
            font-size: 18px;
            font-weight: 760;
            letter-spacing: -.015em;
            }

            .bulk-actions {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 0 18px;
            border-bottom: 1px solid var( --border-strong );
            background: var( --surface );
            }

            .select-all, .message-select {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            }

            .select-all { gap: 8px; color: var( --muted ); font-size: 13px; font-weight: 650; white-space: nowrap; }

            .select-all input, .message-select input {
            width: 17px;
            height: 17px;
            accent-color: var( --accent );
            }

            .selection-count { margin-left: auto; color: var( --muted ); font-size: 12px; white-space: nowrap; }

            .delete-action {
            min-height: 34px;
            padding: 0 11px;
            border: 1px solid color-mix( in srgb, var( --danger ) 45%, var( --border ) );
            border-radius: 6px;
            background: transparent;
            color: var( --danger );
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
            }

            .delete-action:hover:not( :disabled ) { background: color-mix( in srgb, var( --danger ) 10%, transparent ); }
            .delete-action:disabled { cursor: not-allowed; opacity: .45; }

            .message-list {
            margin: 0;
            padding: 0;
            list-style: none;
            overflow: auto;
            }

            .message-item {
            display: grid;
            grid-template-columns: 46px minmax( 0, 1fr );
            border-bottom: 1px solid var( --border );
            }

            .message-item:has( .message-select input:checked ) { background: var( --accent-soft ); }

            .message-select { border: 0; }

            .message-row {
            position: relative;
            display: grid;
            grid-template-columns: 30px minmax( 0, 1fr ) auto;
            gap: 14px;
            min-height: 120px;
            padding: 20px 22px;
            border: 0;
            border-bottom: 0;
            background: transparent;
            text-align: left;
            width: 100%;
            }

            .message-row:hover { background: var( --row-hover ); }

            .message-row[aria-current="true"] {
            background: linear-gradient( 90deg, var( --row-selected-start ) 0%, var( --row-selected-end ) 100% );
            box-shadow: inset 5px 0 0 var( --accent ), inset 0 0 0 1px var( --row-selected-border );
            }

            .message-icon {
            width: 25px;
            height: 25px;
            margin-top: 21px;
            color: var( --message-icon );
            }

            .message-row[aria-current="true"] .message-icon { color: var( --accent ); }

            .message-copy { min-width: 0; }

            .message-from, .message-subject, .message-to {
            display: block;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            }

            .message-from {
            font-size: 15px;
            font-weight: 720;
            }

            .message-to {
            margin-top: 6px;
            color: var( --muted );
            font-size: 13px;
            }

            .message-subject {
            margin-top: 8px;
            color: var( --message-subject );
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
            min-height: 0;
            min-width: 0;
            background: var( --surface );
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
            padding: 0 30px 24px;
            border-bottom: 1px solid var( --border-strong );
            background: var( --detail-header );
            }

            .detail-tabs {
            display: flex;
            gap: 30px;
            height: 68px;
            border-bottom: 1px solid var( --border-strong );
            }

            .detail-delete { margin: auto 0 auto auto; }

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
            height: 3px;
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
            grid-template-columns: 92px minmax( 0, 1fr );
            gap: 12px 18px;
            margin: 24px 0 0;
            }

            .metadata dt { color: var( --accent ); font-weight: 680; }

            .metadata dd {
            margin: 0;
            min-width: 0;
            overflow-wrap: anywhere;
            }

            .viewer {
            min-height: 0;
            padding: 14px;
            background: var( --viewer );
            }

            .preview-frame, .source-view {
            width: 100%;
            height: 100%;
            border: 1px solid var( --border-strong );
            border-radius: 6px;
            background: var( --preview );
            box-shadow: var( --shadow );
            }

            .preview-frame { display: block; }

            .source-view {
            margin: 0;
            padding: 20px;
            overflow: auto;
            color: var( --source-text );
            font: 13px/1.6 ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            white-space: pre-wrap;
            word-break: break-word;
            }

            [hidden] { display: none !important; }

            .status-bar {
            position: relative;
            z-index: 2;
            display: flex;
            align-items: center;
            gap: 10px;
            min-width: 0;
            padding: 0 30px;
            border-top: 1px solid var( --border-strong );
            background: var( --header );
            font-size: 12px;
            }

            .status-source {
            position: relative;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            min-width: 0;
            max-width: calc( 100% - 245px );
            cursor: help;
            }

            .status-source::after {
            position: absolute;
            bottom: calc( 100% + 10px );
            left: 0;
            z-index: 3;
            width: max-content;
            max-width: min( 420px, calc( 100vw - 36px ) );
            padding: 9px 11px;
            border: 1px solid var( --border-strong );
            border-radius: 6px;
            background: var( --surface );
            box-sizing: border-box;
            box-shadow: var( --shadow );
            color: var( --text );
            content: attr( data-tooltip );
            font: 12px/1.45 Inter, ui-sans-serif, system-ui, sans-serif;
            opacity: 0;
            pointer-events: none;
            transform: translateY( 4px );
            transition: opacity 120ms ease, transform 120ms ease, visibility 120ms;
            visibility: hidden;
            white-space: normal;
            }

            .status-source:hover::after,
            .status-source:focus-visible::after {
            opacity: 1;
            transform: translateY( 0 );
            visibility: visible;
            }

            .status-source:focus-visible {
            border-radius: 3px;
            outline: 2px solid var( --focus );
            outline-offset: 4px;
            }

            .status-label {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            color: var( --text );
            font-weight: 720;
            }

            .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var( --success );
            box-shadow: 0 0 0 4px var( --success-ring );
            }

            .status-sources {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            min-width: 0;
            overflow: hidden;
            }

            .status-source-item {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            min-width: 0;
            }

            .status-mailer {
            flex: 0 0 auto;
            padding: 2px 7px;
            border: 1px solid var( --border-strong );
            border-radius: 999px;
            background: var( --surface );
            color: var( --muted );
            font-size: 11px;
            font-weight: 720;
            line-height: 1.3;
            }

            .status-path {
            min-width: 0;
            overflow: hidden;
            color: var( --accent );
            font: 12px/1.4 ui-monospace, SFMono-Regular, Menlo, monospace;
            text-overflow: ellipsis;
            white-space: nowrap;
            }

            .status-source-separator { flex: 0 0 auto; color: var( --muted ); }

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

            @media ( min-width: 801px ) and ( max-width: 1040px ) {
            .app { grid-template-rows: auto minmax( 0, 1fr ) 52px; }
            .app-header {
            grid-template-columns: minmax( 0, 1fr ) auto;
            gap: 14px;
            padding: 14px 20px;
            }
            .search { grid-column: 1 / -1; grid-row: 2; }
            .header-actions { grid-column: 2; grid-row: 1; }
            }

            @media ( max-width: 800px ) {
            body { overflow: hidden; }
            .app { grid-template-rows: auto minmax( 0, 1fr ) 58px; min-height: 100%; }
            .app-header {
            grid-template-columns: minmax( 0, 1fr ) auto;
            gap: 14px;
            padding: 18px;
            }
            .coldbox-mark { width: 36px; height: 36px; }
            .brand-divider { height: 34px; margin: 0 14px; }
            .brand-title { font-size: 18px; }
            .brand-geometry { right: -70px; opacity: .45; }
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
            .inbox-heading { height: 56px; padding: 0 18px; }
            .bulk-actions { min-height: 52px; padding: 0 12px; }
            .select-all span, .selection-count { display: none; }
            .inbox-title { font-size: 16px; }
            .message-item { grid-template-columns: 42px minmax( 0, 1fr ); }
            .message-row { min-height: 112px; padding: 18px 12px; }
            .detail-header { padding: 0 18px 18px; }
            .detail-tabs { align-items: center; height: 54px; }
            .back-button { display: inline-flex; }
            .metadata { grid-template-columns: 58px minmax( 0, 1fr ); margin-top: 16px; font-size: 13px; }
            .viewer { padding: 10px; }
            .preview-frame, .source-view { border-radius: 6px; }
            .status-bar { padding: 9px 18px; }
            .status-source { width: 100%; max-width: 100%; }
            .status-sources, .status-source-item, .status-path { flex: 1 1 auto; }
            .status-summary { display: none; }
            }

            @media ( max-width: 520px ) {
            .app-header { grid-template-columns: minmax( 0, 1fr ) auto; }
            .coldbox-wordmark { display: none; }
            .brand-divider { margin: 0 12px; }
            .brand-title { font-size: 16px; }
            .action span { display: none; }
            .delete-action { padding: 0 9px; }
            .inbox-heading { gap: 12px; }
            .inbox-title { margin-right: auto; }
            .message-row { grid-template-columns: 24px minmax( 0, 1fr ) auto; gap: 10px; }
            .message-icon { width: 21px; height: 21px; }
            }

            @media ( prefers-reduced-motion: reduce ) {
            .detail { transition: none; }
            }
        </style>
    </head>
    <body>
        <div class="app" id="app">
            <header class="app-header">
                <div class="brand-geometry" aria-hidden="true"></div>
                <div class="brand-lockup">
                    <span class="coldbox-logo" aria-label="ColdBox">
                        <svg
                            class="coldbox-mark"
                            aria-hidden="true"
                            viewBox="53 20 87 86"
                            fill="none"
                            xmlns="http://www.w3.org/2000/svg"
                        >
                            <path
                                d="M131.51 104.714H61.8349C57.9936 104.714 54.8436 101.573 54.8436 97.7421V28.2573C54.8436 24.4266 57.9936 21.2852 61.8349 21.2852H131.51C135.352 21.2852 138.502 24.4266 138.502 28.2573V97.7421C138.502 101.585 135.352 104.714 131.51 104.714Z"
                                fill="#343433"
                            ></path>
                            <path
                                d="M131.51 105.882H61.8348C57.3378 105.882 53.6726 102.227 53.6726 97.7423V28.2576C53.6726 23.7728 57.3378 20.1177 61.8348 20.1177H131.51C136.007 20.1177 139.673 23.7728 139.673 28.2576V97.7423C139.673 102.239 136.007 105.882 131.51 105.882ZM61.8348 22.4649C58.6257 22.4649 56.0145 25.069 56.0145 28.2693V97.7541C56.0145 100.954 58.6257 103.559 61.8348 103.559H131.51C134.719 103.559 137.331 100.954 137.331 97.7541V28.2693C137.331 25.069 134.719 22.4649 131.51 22.4649H61.8348Z"
                                fill="white"
                            ></path>
                            <path
                                d="M102.652 90.838C87.7752 90.867 75.6627 79.0205 75.6333 64.3632C75.6038 49.7058 87.628 37.7723 102.505 37.7433C109.738 37.7143 116.676 40.5817 121.762 45.6506C111.707 32.0361 92.3608 29.0237 78.5142 38.9312C64.6659 48.8371 61.6378 67.8978 71.6939 81.5398C81.7484 95.1543 101.095 98.1667 114.942 88.2593C115.617 87.7661 116.295 87.2455 116.911 86.7248C112.678 89.4471 107.739 90.867 102.652 90.838Z"
                                fill="#80C7DD"
                            ></path>
                            <path
                                d="M112.111 42.0952C122.438 48.0724 125.9 61.2109 119.907 71.4331C113.885 81.6553 100.649 85.1211 90.3513 79.1713C84.4463 75.7634 80.5194 69.7573 79.762 63.0298V64.2718C79.762 77.4392 90.497 88.0952 103.762 88.0952C117.027 88.0952 127.762 77.4392 127.762 64.2718C127.587 54.3966 121.42 45.5884 112.111 42.0952Z"
                                fill="#80C7DD"
                            ></path>
                            <path
                                d="M99.8951 43.0953C91.9584 43.066 84.9866 48.3173 82.762 55.9453C86.3652 48.025 95.7068 44.5334 103.616 48.1426C111.523 51.7517 115.009 61.1085 111.406 69.0304C108.857 74.6637 103.234 78.2419 97.0839 78.2419C95.7068 78.2125 94.3313 78.0362 92.9835 77.7146C95.1804 78.6532 97.5239 79.1233 99.9245 79.0939C109.853 79.0352 117.82 70.9092 117.762 60.9632C117.644 51.1347 109.737 43.185 99.8951 43.0969"
                                fill="#80C7DD"
                            ></path>
                        </svg>
                        <span class="coldbox-wordmark" aria-hidden="true">
                            COLDBOX<sup>®</sup>
                        </span>
                    </span>
                    <span class="brand-divider" aria-hidden="true"></span>
                    <h1 class="brand-title">cbMailServices Log</h1>
                </div>
                <label class="search">
                    <span class="sr-only">Search messages</span>
                    <svg aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="11" cy="11" r="7"></circle><path d="m20 20-4-4"></path>
                    </svg>
                    <input id="search" type="search" placeholder="Search messages" autocomplete="off">
                    <span class="search-shortcut" aria-hidden="true">/</span>
                </label>
                <div class="header-actions">
                    <button class="action theme-action" id="theme-toggle" type="button" aria-label="Switch color theme">
                        <svg
                            class="theme-icon theme-icon-moon"
                            aria-hidden="true"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                        >
                            <path d="M20.4 14.8A8.5 8.5 0 0 1 9.2 3.6 8.5 8.5 0 1 0 20.4 14.8Z"></path>
                        </svg>
                        <svg
                            class="theme-icon theme-icon-sun"
                            aria-hidden="true"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            stroke-linecap="round"
                        >
                            <circle cx="12" cy="12" r="4"></circle>
                            <path
                                d="M12 2v2M12 20v2M4.93 4.93l1.42 1.42M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.42-1.42M17.66 6.34l1.41-1.41"
                            ></path>
                        </svg>
                    </button>
                    <button class="action primary" id="refresh" type="button">
                        <svg aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M20 7v5h-5"></path><path d="M4 17v-5h5"></path><path
                                d="M6.1 9a7 7 0 0 1 11.5-2L20 12"
                            ></path><path d="m4 12 2.4 5a7 7 0 0 0 11.5-2"></path>
                        </svg>
                        <span>Refresh</span>
                    </button>
                    <button class="action clear-action" id="clear" type="button">Clear filters</button>
                </div>
            </header>

            <main class="app-body">
                <aside class="inbox" aria-label="Logged messages">
                    <div class="inbox-heading">
                        <span class="inbox-title">Inbox</span>
                        <span id="message-count">Loading messages</span>
                        <span>All time</span>
                    </div>
                    <div class="bulk-actions">
                        <label class="select-all">
                            <input id="select-all" type="checkbox">
                            <span>Select visible</span>
                        </label>
                        <span class="selection-count" id="selection-count">0 selected</span>
                        <button class="delete-action" id="delete-selected" type="button" disabled>Delete selected</button>
                        <button class="delete-action" id="delete-all" type="button">Delete all</button>
                    </div>
                    <ul class="message-list" id="message-list"></ul>
                </aside>

                <section class="detail" aria-label="Selected message">
                    <div class="detail-empty" id="detail-empty">
                        <div class="empty-copy">
                            <strong>Select a message</strong>Choose a logged email to inspect its preview and source.
                        </div>
                    </div>
                    <div class="detail-content" id="detail-content" hidden>
                        <header class="detail-header">
                            <div class="detail-tabs" role="tablist" aria-label="Message view">
                                <button class="back-button" id="back" type="button">
                                    <svg
                                        aria-hidden="true"
                                        width="18"
                                        height="18"
                                        viewBox="0 0 24 24"
                                        fill="none"
                                        stroke="currentColor"
                                        stroke-width="2"
                                    >
                                        <path d="m15 18-6-6 6-6"></path>
                                    </svg>
                                    Back
                                </button>
                                <button
                                    class="tab" id="preview-tab"
                                    type="button"
                                    role="tab"
                                    aria-controls="preview-frame"
                                    aria-selected="true"
                                >Preview</button>
                                <button
                                    class="tab" id="source-tab"
                                    type="button"
                                    role="tab"
                                    aria-controls="source-view"
                                    aria-selected="false"
                                >Source</button>
                                <button class="delete-action detail-delete" id="delete-message" type="button">Delete message</button>
                            </div>
                            <dl class="metadata">
                                <dt>From</dt>
                                <dd id="meta-from"></dd>
                                <dt>To</dt>
                                <dd id="meta-to"></dd>
                                <dt>Subject</dt>
                                <dd id="meta-subject"></dd>
                                <dt>Sent</dt>
                                <dd id="meta-sent"></dd>
                            </dl>
                        </header>
                        <div class="viewer">
                            <iframe
                                class="preview-frame" id="preview-frame"
                                title="Rendered email preview"
                                sandbox="allow-popups allow-popups-to-escape-sandbox"
                            ></iframe>
                            <pre class="source-view" id="source-view" role="tabpanel" tabindex="0" hidden></pre>
                        </div>
                    </div>
                </section>
            </main>

            <footer class="status-bar">
                <span
                    class="status-source"
                    id="status-source"
                    tabindex="0"
                    data-tooltip="To change a watched directory, update that File protocol's filePath in your cbMailServices settings."
                >
                    <span class="status-label">
                        <span class="status-dot"></span>Watching
                    </span>
                    <span class="status-sources" id="status-sources">Discovering File protocols…</span>
                </span>
                <span class="status-summary" id="status-summary">Auto-refresh every 5s</span>
            </footer>
        </div>

        <div class="sr-only" id="announcer" aria-live="polite"></div>

        <script>
        ( () => {
            "use strict";

            const basePath = window.location.pathname.replace( /\/$/, "" );
            const state = {
                messages: [],
                filtered: [],
                selectedIds: new Set(),
                selectedId: null,
                selected: null,
                loading: false,
                deleting: false,
                tab: "preview"
            };
            const elements = {
                app: document.getElementById( "app" ),
                themeToggle: document.getElementById( "theme-toggle" ),
                search: document.getElementById( "search" ),
                refresh: document.getElementById( "refresh" ),
                clear: document.getElementById( "clear" ),
                selectAll: document.getElementById( "select-all" ),
                selectionCount: document.getElementById( "selection-count" ),
                deleteSelected: document.getElementById( "delete-selected" ),
                deleteAll: document.getElementById( "delete-all" ),
                list: document.getElementById( "message-list" ),
                count: document.getElementById( "message-count" ),
                empty: document.getElementById( "detail-empty" ),
                content: document.getElementById( "detail-content" ),
                back: document.getElementById( "back" ),
                previewTab: document.getElementById( "preview-tab" ),
                sourceTab: document.getElementById( "source-tab" ),
                deleteMessage: document.getElementById( "delete-message" ),
                preview: document.getElementById( "preview-frame" ),
                source: document.getElementById( "source-view" ),
                statusSource: document.getElementById( "status-source" ),
                sources: document.getElementById( "status-sources" ),
                summary: document.getElementById( "status-summary" ),
                announcer: document.getElementById( "announcer" )
            };

            const escapeHTML = ( value ) => String( value || "" )
                .replaceAll( "&", "&amp;" )
                .replaceAll( "<", "&lt;" )
                .replaceAll( ">", "&gt;" )
                .replaceAll( '"', "&quot;" )
                .replaceAll( "'", "&#039;" );

            const preparePreviewHTML = ( value ) => {
                const previewDocument = new DOMParser().parseFromString( String( value || "" ), "text/html" );
                previewDocument.querySelectorAll( "a[href], area[href]" ).forEach( ( link ) => {
                    link.setAttribute( "target", "_blank" );
                } );
                return `<!doctype html>${ previewDocument.documentElement.outerHTML }`;
            };

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

            function updateBulkControls(){
                const visibleIds = state.filtered.map( ( message ) => message.id );
                const selectedVisible = visibleIds.filter( ( id ) => state.selectedIds.has( id ) ).length;
                const selectedCount = state.selectedIds.size;
                elements.selectAll.checked = Boolean( visibleIds.length ) && selectedVisible === visibleIds.length;
                elements.selectAll.indeterminate = selectedVisible > 0 && selectedVisible < visibleIds.length;
                elements.selectAll.disabled = !visibleIds.length || state.deleting;
                elements.selectionCount.textContent = `${ selectedCount } selected`;
                elements.deleteSelected.disabled = !selectedCount || state.deleting;
                elements.deleteAll.disabled = !state.messages.length || state.deleting;
                elements.deleteMessage.disabled = !state.selectedId || state.deleting;
            }

            function updateThemeControl(){
                const currentTheme = document.documentElement.dataset.theme;
                const nextTheme = currentTheme === "dark" ? "light" : "dark";
                const label = `Switch to ${ nextTheme } mode`;
                elements.themeToggle.setAttribute( "aria-label", label );
                elements.themeToggle.title = label;
            }

            function setTheme( theme, options = {} ){
                document.documentElement.dataset.theme = theme;
                updateThemeControl();
                if ( options.persist ) {
                    try {
                        window.localStorage.setItem( "cbmailservices-log-theme", theme );
                    } catch ( error ) {
                        // The selected theme still applies for the current page.
                    }
                }
                if ( options.announce ) {
                    announce( `${ theme === "dark" ? "Dark" : "Light" } mode enabled` );
                }
            }

            function renderList(){
                const query = elements.search.value.trim().toLowerCase();
                state.filtered = state.messages.filter( ( message ) => {
                    return [ message.from, message.to, message.subject, message.fileName, message.mailer ]
                        .some( ( value ) => String( value || "" ).toLowerCase().includes( query ) );
                } );

                elements.count.textContent = `${ state.filtered.length } ${ state.filtered.length === 1 ? "message" : "messages" }`;
                if ( !state.filtered.length ) {
                    elements.list.innerHTML = '<li class="list-empty"><div class="empty-copy"><strong>No messages found</strong>Try another search or send a new local email.</div></li>';
                    updateBulkControls();
                    return;
                }

                elements.list.innerHTML = state.filtered.map( ( message ) => `
                    <li class="message-item">
                        <label class="message-select">
                            <input type="checkbox" data-select-message-id="${ escapeHTML( message.id ) }" ${ state.selectedIds.has( message.id ) ? "checked" : "" }>
                            <span class="sr-only">Select ${ escapeHTML( message.subject || "message" ) }</span>
                        </label>
                        <button class="message-row" type="button" data-message-id="${ escapeHTML( message.id ) }" aria-current="${ message.id === state.selectedId }">
                            <svg class="message-icon" aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"></rect><path d="m3 7 9 6 9-6"></path></svg>
                            <span class="message-copy">
                                <span class="message-from">${ escapeHTML( message.from || "Unknown sender" ) }</span>
                                <span class="message-to">To: ${ escapeHTML( message.to || "Unknown recipient" ) }</span>
                                <span class="message-subject">${ escapeHTML( message.subject || "(No subject)" ) }</span>
                            </span>
                            <time class="message-time">${ escapeHTML( timeLabel( message.sent ) ) }</time>
                        </button>
                    </li>
                ` ).join( "" );
                updateBulkControls();
            }

            function clearSelectedMessage(){
                state.selectedId = null;
                state.selected = null;
                elements.content.hidden = true;
                elements.empty.hidden = false;
                elements.app.classList.remove( "detail-open" );
                history.replaceState( {}, "", basePath );
            }

            async function deleteMessages( options = {} ){
                const ids = options.all ? state.messages.map( ( message ) => message.id ) : Array.from( options.ids || [] );
                if ( !ids.length ) {
                    return;
                }

                const label = options.all
                    ? `all ${ ids.length } logged messages`
                    : `${ ids.length } selected ${ ids.length === 1 ? "message" : "messages" }`;
                if ( !window.confirm( `Delete ${ label }? This cannot be undone.` ) ) {
                    return;
                }

                state.deleting = true;
                updateBulkControls();
                try {
                    const response = await fetch( options.all ? `${ basePath }/messages` : options.singleId
                        ? `${ basePath }/message/${ encodeURIComponent( options.singleId ) }`
                        : `${ basePath }/messages`, {
                        method: "DELETE",
                        headers: { Accept: "application/json", "Content-Type": "application/json" },
                        body: options.singleId ? undefined : JSON.stringify( options.all ? { all: true } : { ids } )
                    } );
                    if ( !response.ok ) {
                        const error = await response.json().catch( () => ( {} ) );
                        throw new Error( error.message || "Unable to delete the selected mail logs." );
                    }
                    const result = await response.json();
                    const deletedIds = new Set( result.deleted || ids );
                    state.selectedIds = new Set( Array.from( state.selectedIds ).filter( ( id ) => !deletedIds.has( id ) ) );
                    if ( state.selectedId && deletedIds.has( state.selectedId ) ) {
                        clearSelectedMessage();
                    }
                    announce( `Deleted ${ result.count } ${ result.count === 1 ? "message" : "messages" }` );
                } catch ( error ) {
                    announce( error.message );
                    window.alert( error.message );
                } finally {
                    state.deleting = false;
                    await loadMessages( { silent: true } );
                }
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
                    elements.preview.srcdoc = preparePreviewHTML( state.selected.preview || state.selected.source );
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

            function renderSources( sources ){
                elements.sources.replaceChildren();

                if ( !sources.length ) {
                    elements.sources.textContent = "No File protocol is configured";
                    elements.statusSource.setAttribute(
                        "aria-label",
                        "No File protocol is configured. To add one, update your cbMailServices settings."
                    );
                    return;
                }

                sources.forEach( ( source, index ) => {
                    if ( index ) {
                        const separator = document.createElement( "span" );
                        separator.className = "status-source-separator";
                        separator.setAttribute( "aria-hidden", "true" );
                        separator.textContent = "·";
                        elements.sources.append( separator );
                    }

                    const item = document.createElement( "span" );
                    item.className = "status-source-item";

                    const mailer = document.createElement( "span" );
                    mailer.className = "status-mailer";
                    mailer.textContent = source.mailer;

                    const path = document.createElement( "span" );
                    path.className = "status-path";
                    path.textContent = source.path;

                    item.append( mailer, path );
                    elements.sources.append( item );
                } );

                const sourceDescription = sources
                    .map( ( source ) => `${ source.mailer }: ${ source.path }` )
                    .join( "; " );
                elements.statusSource.setAttribute(
                    "aria-label",
                    `Watching ${ sourceDescription }. To change these directories, update each File protocol filePath in your cbMailServices settings.`
                );
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
                    const availableIds = new Set( state.messages.map( ( message ) => message.id ) );
                    state.selectedIds = new Set( Array.from( state.selectedIds ).filter( ( id ) => availableIds.has( id ) ) );
                    renderSources( data.sources || [] );
                    elements.summary.textContent = `Auto-refresh every 5s  |  ${ state.messages.length } messages`;
                    renderList();

                    const requestedId = new URLSearchParams( window.location.search ).get( "message" );
                    const candidateId = state.selectedId || requestedId;
                    const nextId = candidateId && state.messages.some( ( message ) => message.id === candidateId )
                        ? candidateId
                        : state.messages[ 0 ]?.id;
                    if ( candidateId && candidateId !== nextId ) {
                        history.replaceState( {}, "", basePath );
                    }
                    if ( nextId && state.messages.some( ( message ) => message.id === nextId ) ) {
                        if ( !options.silent || !state.selected || state.selectedId !== nextId ) {
                            const openDetail = Boolean( requestedId )
                                || !window.matchMedia( "(max-width: 800px)" ).matches
                                || elements.app.classList.contains( "detail-open" );
                            await selectMessage( nextId, { silent: Boolean( options.silent ), openDetail } );
                        }
                    } else if ( !state.messages.length ) {
                        clearSelectedMessage();
                        elements.empty.innerHTML = '<div class="empty-copy"><strong>No logged mail yet</strong>Send mail through a configured File protocol and it will appear here.</div>';
                    }
                    if ( !options.silent ) {
                        announce( `Loaded ${ state.messages.length } messages` );
                    }
                } catch ( error ) {
                    elements.list.innerHTML = `<li class="error-state">${ escapeHTML( error.message ) }</li>`;
                    elements.sources.textContent = "Mail log unavailable";
                    announce( error.message );
                } finally {
                    state.loading = false;
                    elements.refresh.disabled = false;
                }
            }

            elements.list.addEventListener( "click", ( event ) => {
                const checkbox = event.target.closest( "[data-select-message-id]" );
                if ( checkbox ) {
                    if ( checkbox.checked ) {
                        state.selectedIds.add( checkbox.dataset.selectMessageId );
                    } else {
                        state.selectedIds.delete( checkbox.dataset.selectMessageId );
                    }
                    updateBulkControls();
                    return;
                }
                const row = event.target.closest( "[data-message-id]" );
                if ( row ) {
                    selectMessage( row.dataset.messageId );
                }
            } );
            elements.themeToggle.addEventListener( "click", () => {
                const nextTheme = document.documentElement.dataset.theme === "dark" ? "light" : "dark";
                setTheme( nextTheme, { persist: true, announce: true } );
            } );
            elements.search.addEventListener( "input", renderList );
            elements.selectAll.addEventListener( "change", () => {
                for ( const message of state.filtered ) {
                    if ( elements.selectAll.checked ) {
                        state.selectedIds.add( message.id );
                    } else {
                        state.selectedIds.delete( message.id );
                    }
                }
                renderList();
            } );
            elements.deleteSelected.addEventListener( "click", () => deleteMessages( { ids: state.selectedIds } ) );
            elements.deleteAll.addEventListener( "click", () => deleteMessages( { all: true } ) );
            elements.deleteMessage.addEventListener( "click", () => deleteMessages( { ids: [ state.selectedId ], singleId: state.selectedId } ) );
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

            updateThemeControl();
            loadMessages();
            window.setInterval( () => loadMessages( { silent: true } ), 5000 );
        } )();
        </script>
    </body>
</html>
