/**
 * @file    csdl_appkit.m
 * @author  George Burton <burtonageo@gmail.com>
 * @version 0.1
 *
 * @section LICENSE
 *
 * THIS SOFTWARE IS PROVIDED 'AS-IS', WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTY. IN NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES
 * ARISING FROM THE USE OF THIS SOFTWARE.
 * 
 * Permission is granted to anyone to use this software for any purpose,  
 * including commercial applications, and to alter it and redistribute it  
 * freely, subject to the following restrictions:
 * 
 *    1. The origin of this software must not be misrepresented; you must not  
 *       claim that you wrote the original software. If you use this software  
 *       in a product, an acknowledgment in the product documentation would be  
 *       appreciated but is not required.
 * 
 *    2. Altered source versions must be plainly marked as such, and must not be  
 *       misrepresented as being the original software.
 * 
 *    3. This notice may not be removed or altered from any source  
 *       distribution.
 *
 * @section DESCRIPTION
 *
 * The implementation of the csdl interface for the Cocoa appkit framework on
 * Mac OS X.
 *
 */


#include "csdl.h"

#import <Cocoa/Cocoa.h>

struct CsdlDialog_ {
    NSString* title,
            * message,
            * primary_btn_text,
            * cancel_btn_text,
            * altern_btn_text;

    CsdlDialogType alert_type;
};,


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


static __thread CsdlDialogUserResult app_result = R_NORESPONSE;

static void set_nsalert_data_from_csdl_dialog(NSAlert*, const CsdlDialog* const);
static BOOL create_app_delegate(const CsdlDialog* const dialog);
static CsdlDialogUserResult show_nsalert(NSAlert* alert);

CsdlDialogUserResult csdl_show_dialog(const CsdlDialog* const dialog)
{
    NSApplication* app = [NSApplication sharedApplication];

    if ( dialog == NULL || app == nil ) {
        return R_NORESPONSE;
    }

    if ( app.delegate == nil ) {
        create_app_delegate(dialog);
        return app_result;
    } else {
        [app activateIgnoringOtherApps:YES];
        NSAlert* alert = [NSAlert new];
        set_nsalert_data_from_csdl_dialog(alert, dialog);
        return show_nsalert(alert);
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
 *                          Internal helper functions                         *
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


static void set_nsalert_style(NSAlert* alert, CsdlDialogType dlg_type);

/**
 * Set the NSAlert's fields to the corresponding values
 * in the CsdlDialog
 */
static void set_nsalert_data_from_csdl_dialog(NSAlert*, const CsdlDialog* const)
{
    alert.messageText     = dialog->title;
    alert.informativeText = dialog->message;

    [alert addButtonWithTitle: dialog->primary_btn_text];
    [alert addButtonWithTitle: dialog->cancel_btn_text];
    [alert addButtonWithTitle: dialog->altern_btn_text];
    set_nsalert_style(alert, dialog->alert_type);
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


@interface CsdlAppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation CsdlAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSApplication* app = [NSApplication sharedApplication];
    [app stop: self];
}

@end

/**
 * Bring the application forward into the foreground so
 * that our dialog is in focus. If the app could not
 * be found, then there is something seriously wrong,
 * and we should return NO. Otherwise, everything is
 * oK, and return YES.
 */
static BOOL create_app_delegate(const CsdlDialog* const dialog)
{
    #define DLG_C_STR(x) [dialog->x cStringUsingEncoding: NSUTF8StringEncoding]
    const char* app_argv[] = {DLG_C_STR(title),
                              DLG_C_STR(message),
                              DLG_C_STR(primary_btn_text),
                              DLG_C_STR(cancel_btn_text),
                              DLG_C_STR(altern_btn_text)};
    #undef DLG_C_STR

    NSApplicationMain(5, app_argv);
    return NO;
}


/**
 * Displays the NSAlert
 *
 * @param alert Alert to display - runs modal.
 * @return The result of the NSAlert, converted to a CsdlDialogUserResult
 */
static CsdlDialogUserResult show_nsalert(NSAlert* alert)
{
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
