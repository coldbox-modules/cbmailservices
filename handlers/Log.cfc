/**
 * Development-only file mail viewer.
 */
component {

    property name="mailLogService" inject="MailLogService@cbmailservices";
    property name="controller" inject="coldbox";

    function index( event, rc, prc ) {
        if ( !ensureDevelopment( event ) ) {
            return;
        }
        event.setView( view = "log/index", noLayout = true );
    }

    function messages( event, rc, prc ) {
        if ( !ensureDevelopment( event ) ) {
            return;
        }
        event.renderData( type = "json", data = mailLogService.listMessages() );
    }

    function show( event, rc, prc ) {
        if ( !ensureDevelopment( event ) ) {
            return;
        }
        var message = mailLogService.findMessage( rc.id );
        if ( isNull( message ) ) {
            event.renderData(
                type = "json",
                statusCode = 404,
                data = { "error": true, "message": "Mail log not found." }
            );
            return;
        }
        event.renderData( type = "json", data = message );
    }

    function deleteMessage( event, rc, prc ) {
        if ( !ensureDevelopment( event ) ) {
            return;
        }
        if ( !mailLogService.deleteMessage( rc.id ) ) {
            event.renderData(
                type = "json",
                statusCode = 404,
                data = { "error": true, "message": "Mail log not found." }
            );
            return;
        }
        event.renderData( type = "json", data = { "deleted": [ rc.id ], "count": 1 } );
    }

    function deleteMany( event, rc, prc ) {
        if ( !ensureDevelopment( event ) ) {
            return;
        }

        var payload = {};
        if ( len( event.getHTTPContent() ) && isJSON( event.getHTTPContent() ) ) {
            payload = event.getHTTPContent( json = true );
        }

        if ( payload.keyExists( "all" ) && payload.all == true ) {
            event.renderData( type = "json", data = mailLogService.deleteAllMessages() );
            return;
        }

        if ( !payload.keyExists( "ids" ) || !isArray( payload.ids ) || payload.ids.isEmpty() ) {
            event.renderData(
                type = "json",
                statusCode = 400,
                data = { "error": true, "message": "Provide at least one mail log id or set all to true." }
            );
            return;
        }

        event.renderData( type = "json", data = mailLogService.deleteMessages( payload.ids ) );
    }

    private boolean function ensureDevelopment( required event ) {
        if ( controller.getSetting( "environment" ) != "development" ) {
            arguments.event.renderData(
                type = "json",
                statusCode = 404,
                data = { "error": true, "message": "Not found." }
            );
            return false;
        }
        return true;
    }

}
