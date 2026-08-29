/**
 * Discovers File protocol mailers and exposes their existing HTML logs.
 */
component singleton {

    property name="mailService" inject="MailService@cbmailservices";

    struct function listMessages() {
        var sources = getFileSources();
        var messages = [];

        for ( var source in sources ) {
            for ( var file in listLogFiles( source.path ) ) {
                messages.append( summarizeFile( source, file ) );
            }
        }

        messages.sort( ( first, second ) => {
            return compare( second.sortKey, first.sortKey );
        } );

        return {
            "sources": sources.map( ( source ) => {
                return { "mailer": source.mailer, "path": source.path };
            } ),
            "messages": messages,
            "refreshedAt": dateTimeFormat( now(), "iso" )
        };
    }

    function findMessage( required string id ) {
        for ( var source in getFileSources() ) {
            for ( var file in listLogFiles( source.path ) ) {
                if ( messageId( source.mailer, file.name ) == arguments.id ) {
                    return inspectFile( source, file );
                }
            }
        }

        return javacast( "null", "" );
    }

    array function getFileSources() {
        var sources = [];

        mailService
            .getMailers()
            .each( ( name, definition ) => {
                if ( isInstanceOf( definition.transit, "cbmailservices.models.protocols.FileProtocol" ) ) {
                    var path = canonicalPath( definition.transit.getProperty( "filePath" ) );
                    if ( directoryExists( path ) ) {
                        sources.append( { "mailer": name, "path": path } );
                    }
                }
            } );

        return sources;
    }

    private array function listLogFiles( required string directory ) {
        var files = directoryList(
            arguments.directory,
            false,
            "query",
            "*.html",
            "dateLastModified desc"
        );
        var results = [];

        for ( var file in files ) {
            if ( file.type == "File" ) {
                results.append( { "name": file.name, "dateLastModified": file.dateLastModified, "size": file.size } );
            }
        }

        return results;
    }

    private struct function summarizeFile( required struct source, required struct file ) {
        var content = fileRead( arguments.source.path & "/" & arguments.file.name );
        var metadata = extractMetadata( content );

        return {
            "id": messageId( arguments.source.mailer, arguments.file.name ),
            "mailer": arguments.source.mailer,
            "fileName": arguments.file.name,
            "from": metadata.from,
            "to": metadata.to,
            "subject": metadata.subject,
            "sent": len( metadata.sent ) ? metadata.sent : dateTimeFormat( arguments.file.dateLastModified, "iso" ),
            "size": arguments.file.size,
            "sortKey": dateTimeFormat( arguments.file.dateLastModified, "iso" )
        };
    }

    private struct function inspectFile( required struct source, required struct file ) {
        var summary = summarizeFile( arguments.source, arguments.file );
        var content = fileRead( arguments.source.path & "/" & arguments.file.name );

        summary[ "source" ] = content;
        summary[ "preview" ] = extractBody( content );
        summary[ "path" ] = arguments.source.path;
        return summary;
    }

    private struct function extractMetadata( required string content ) {
        return {
            "from": extractMetadataValue( arguments.content, "from" ),
            "to": extractMetadataValue( arguments.content, "to" ),
            "subject": extractMetadataValue( arguments.content, "subject" ),
            "sent": extractMetadataValue( arguments.content, "sent" )
        };
    }

    private string function extractMetadataValue( required string content, required string key ) {
        var attributeMatch = reFindNoCase(
            "data-#arguments.key#\s*=\s*[""']([^""']*)[""']",
            arguments.content,
            1,
            true
        );
        if ( attributeMatch.pos.len() > 1 && attributeMatch.pos[ 2 ] > 0 ) {
            return decodeHTML( mid( arguments.content, attributeMatch.pos[ 2 ], attributeMatch.len[ 2 ] ) );
        }

        if ( arguments.key == "sent" ) {
            return "";
        }

        var rowMatch = reFindNoCase(
            "(?is)<(?:th|td)\b[^>]*>\s*#arguments.key#\s*</(?:th|td)>\s*<td\b[^>]*>(.*?)</td>\s*</tr>",
            arguments.content,
            1,
            true
        );
        if ( rowMatch.pos.len() <= 1 || rowMatch.pos[ 2 ] <= 0 ) {
            return "";
        }

        var cell = mid( arguments.content, rowMatch.pos[ 2 ], rowMatch.len[ 2 ] );
        var spans = reMatchNoCase( "(?is)<span(?:\s[^>]*)?>.*?</span>", cell );
        var value = spans.len() ? spans.last() : cell;
        value = reReplaceNoCase( value, "(?is)<[^>]+>", "", "all" );
        value = reReplaceNoCase( value, "^\s*(String:)?\s*", "" );
        return decodeHTML( trim( value ) );
    }

    private string function extractBody( required string content ) {
        var body = reReplaceNoCase( arguments.content, "(?is)^.*Mail Body\s*<hr\s*/?>", "" );
        return body == arguments.content ? arguments.content : body;
    }

    private string function decodeHTML( required string value ) {
        try {
            return xmlParse(
                "<root>" & replaceNoCase(
                    arguments.value,
                    "&nbsp;",
                    "&##160;",
                    "all"
                ) & "</root>"
            ).root.xmlText;
        } catch ( any ignored ) {
            return arguments.value;
        }
    }

    private string function canonicalPath( required string path ) {
        return createObject( "java", "java.io.File" ).init( arguments.path ).getCanonicalPath();
    }

    private string function messageId( required string mailer, required string fileName ) {
        return lCase( hash( "#arguments.mailer#|#arguments.fileName#", "SHA-256" ) );
    }

}
