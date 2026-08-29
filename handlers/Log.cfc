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
