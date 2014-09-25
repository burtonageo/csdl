#include "csdl.h"

#include <Cocoa/Cocoa.h>

struct CsdlDialog_s {
    NSString* title,
            * message,
            * primary_btn_text,
            * cancel_btn_text,
            * altern_btn_text;

    CsdlDialogType alert_type;
};



CsdlDialog* csdl_create_dialog(void)
{
    CsdlDialog* dialog = malloc(sizeof(CsdlDialog));

    if ( dialog != NULL ) {
        dialog->title            = nil;
        dialog->message          = nil;
        dialog->primary_btn_text = nil;
        dialog->cancel_btn_text  = nil;
        dialog->altern_btn_text  = nil;
        dialog->alert_type       = T_NOTYPE;
    }

    return dialog;
}



static NSString* wcs_to_nsstring(const wchar_t*);

CsdlDialogInitResult csdl_init_dialog(CsdlDialog*          dialog,
                                      const wchar_t* const title,
                                      const wchar_t* const message,
                                      const wchar_t* const primary_btn_text,
                                      const wchar_t* const cancel_btn_text,
                                      const wchar_t* const altern_btn_text,
                                      CsdlDialogType       dialog_type)
{
    /* required parameters must not be NULL */
    if ( dialog           == NULL ||
         message          == NULL ||
         primary_btn_text == NULL ) {
        return I_ERROR;
    }

    dialog->title            = wcs_to_nsstring(title);
    dialog->message          = wcs_to_nsstring(message);
    dialog->primary_btn_text = wcs_to_nsstring(primary_btn_text);
    dialog->cancel_btn_text  = wcs_to_nsstring(cancel_btn_text);
    dialog->altern_btn_text  = wcs_to_nsstring(altern_btn_text);
    dialog->alert_type       = dialog_type;    

    return I_OK;
}



static void set_nsalert_style(NSAlert*, CsdlDialogType);
static BOOL activate_app(void);

CsdlDialogUserResult csdl_show_dialog(const CsdlDialog* const dialog)
{
    if ( dialog == NULL ||
         !activate_app() ) { /* nothing to show */
        return R_NORESPONSE;
    }

    NSAlert* alert = [NSAlert new];

    alert.messageText     = dialog->title;
    alert.informativeText = dialog->message;

    [alert addButtonWithTitle: dialog->primary_btn_text];
    [alert addButtonWithTitle: dialog->cancel_btn_text];
    [alert addButtonWithTitle: dialog->altern_btn_text];
    set_nsalert_style(alert, dialog->alert_type);

    NSInteger result = [alert runModal];

    #if !__has_feature(objc_arc)
            [alert release];
    #endif

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



void csdl_delete_dialog(CsdlDialog* dialog)
{
    if ( dialog != NULL ) {
        [dialog->title release];
        [dialog->message release];
        [dialog->primary_btn_text release];
        [dialog->cancel_btn_text release];
        [dialog->altern_btn_text release];
    
        free(dialog);
        dialog = NULL;
    }
}



/******************************************************************************
 * Internal helper functions
 ******************************************************************************/

/**
 * A small utility function to convert from a wide string to
 * an NSString*. Even if the input string is NULL, the output
 * will never be nil.
 */
static NSString* wcs_to_nsstring(const wchar_t* string)
{
    return string == NULL /* calling wcslen on NULL causes segfault 11 */
        ? @""
        : [[NSString alloc] initWithBytes: (const void*)string
                                   length: sizeof(wchar_t) * wcslen(string)
                                 encoding: NSUTF8StringEncoding];
}

/**
 * Sets the NSAlert's style to the cocoa equivelent
 * of the CsdlDialogType.
 */
static void set_nsalert_style(NSAlert* alert, CsdlDialogType dlg_type)
{
    NSAlertStyle alert_style;

    switch ( dlg_type ) {
        case T_WARN:
            alert_style = NSWarningAlertStyle;
            break;
        case T_ERROR:
            alert_style = NSCriticalAlertStyle;
            break;
        case T_INFO:
        case T_QUESTION: /* fall-through */
        case T_NOTYPE:   /* fall-through */
            alert_style = NSInformationalAlertStyle;
            break;
    }

    alert.alertStyle = alert_style;
}

/**
 * Bring the application forward into the foreground so
 * that our dialog is in focus. If the app could not
 * be found, then there is something seriously wrong,
 * and we should return NO. Otherwise, everything is
 * oK, and return YES.
 */
static BOOL activate_app(void)
{
    NSApplication* app = [NSApplication sharedApplication];
    if ( app == nil ) {
        /* panic instead of handling errors properly       
           (this should be very rare) */
        return NO;
    }

    if ( app.delegate == nil ) {
        /* create our own app delegate */
        //...
    }

    /* Bring our app to the foreground so that our
       dialog has focus */
    [app activateIgnoringOtherApps:YES];

    return YES;
}

