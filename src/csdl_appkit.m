#include "csdl.h"

#include <Cocoa/Cocoa.h>

struct CsdlMessageBox_s {
    NSString* title,
            * message,
            * primary_btn_text,
            * cancel_btn_text,
            * altern_btn_text;

    CsdlMessageboxType alert_type;
};

CsdlMessageBox* csdl_create_msgbox(void)
{
    CsdlMessageBox* message_box = malloc(sizeof(CsdlMessageBox));

    if ( message_box != NULL ) {
        message_box->title            = nil;
        message_box->message          = nil;
        message_box->primary_btn_text = nil;
        message_box->cancel_btn_text  = nil;
        message_box->altern_btn_text  = nil;
        message_box->alert_type       = T_NOTYPE;
    }

    return message_box;
}

static NSString* wcs_to_nsstring(const wchar_t* string) {
    return string == NULL /* calling wcslen on NULL causes segfault 11 */
        ? @""
        : [[NSString alloc] initWithBytes: (const void*)string
                                   length: sizeof(wchar_t) * wcslen(string)
                                 encoding: NSUTF8StringEncoding];
}

CsdlMessageboxInitResult csdl_init_msgbox(CsdlMessageBox*      message_box,
                                          const wchar_t* const title,
                                          const wchar_t* const message,
                                          const wchar_t* const primary_btn_text,
                                          const wchar_t* const cancel_btn_text,
                                          const wchar_t* const altern_btn_text,
                                          CsdlMessageboxType   alert_type)
{
    /* required parameters must not be NULL */
    if ( message_box      == NULL ||
         message          == NULL ||
         primary_btn_text == NULL ) {
        return I_ERROR;
    }

    message_box->title            = wcs_to_nsstring(title);
    message_box->message          = wcs_to_nsstring(message);
    message_box->primary_btn_text = wcs_to_nsstring(primary_btn_text);
    message_box->cancel_btn_text  = wcs_to_nsstring(cancel_btn_text);
    message_box->altern_btn_text  = wcs_to_nsstring(altern_btn_text);
    message_box->alert_type       = alert_type;    

    return I_OK;
}

CsdlMessageboxUserResult csdl_show_msgbox(const CsdlMessageBox* const message_box)
{
    if ( message_box == NULL ) { /* nothing to show */
        return R_NORESPONSE;
    }

    NSApplication* app = [NSApplication sharedApplication];
    if ( app == nil ) { /* panic instead of handling errors properly       
                           (this should be very rare) */

        return R_NORESPONSE;
    }

    if ( app.delegate == nil ) {
        /* create our own app delegate so that
           our alert can get focus */
        // [app activateIgnoringOtherApps:YES];
    } else {
        /* Bring our app to the foreground so that our
           dialog has focus */
        [app activateIgnoringOtherApps:YES];
    }

    NSAlert* alert = [NSAlert new];

    alert.messageText = message_box->title;
    alert.informativeText = message_box->message;

    [alert addButtonWithTitle: message_box->primary_btn_text];
    [alert addButtonWithTitle: message_box->cancel_btn_text];
    [alert addButtonWithTitle: message_box->altern_btn_text];
    

    NSAlertStyle cocoa_alert_style;
    switch ( message_box->alert_type ) {
        case T_WARN:
            cocoa_alert_style = NSWarningAlertStyle;
            break;
        case T_ERROR:
            cocoa_alert_style = NSCriticalAlertStyle;
            break;
        case T_INFO:
        case T_QUESTION: /* fall-through */
        case T_NOTYPE:   /* fall-through */
            cocoa_alert_style = NSInformationalAlertStyle;
            break;
    }

    alert.alertStyle = cocoa_alert_style;

    NSInteger result = [alert runModal];
    [alert release];   /* destroy the NSAlert! */

    switch ( result ) {
        case NSAlertThirdButtonReturn:
            return R_ALTERN;
        case NSAlertSecondButtonReturn:
            return R_CANCEL;
        case NSAlertFirstButtonReturn:
        default:              /* fall-through */
            return R_PRIMARY; /* we have run the alert, and assume that
                                 we have a valid response in the case of
                                 the default action */
    }
}

void csdl_delete_msgbox(CsdlMessageBox* message_box)
{
    if ( message_box == NULL ) {
        return;
    }

    [message_box->title release];
    [message_box->message release];
    [message_box->primary_btn_text release];
    [message_box->cancel_btn_text release];
    [message_box->altern_btn_text release];

    free(message_box);
    message_box = NULL;
}

