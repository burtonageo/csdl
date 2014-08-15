#include "csdl.h"

#include <cocoa/cocoa.h>

struct csdl_msgbox {
  NSString* title,
            message,
            primary_btn_text,
            cancel_btn_text,
            alert_btn_text;

  CSDL_MSGBOX_TYPE alert_type;
};

csdl_msgbox* csdl_create_msgbox(void)
{
  struct csdl_msgbox* message_box = malloc(sizeof(struct csdl_msgbox));

  message_box.title = nil;
  message_box.message = nil;
  message_box.primary_btn_text = nil;
  message_box.cancel_btn_text = nil;
  message_box.alert_btn_text = nil;
  message_box.alert_type = T_NOTYPE;

  return message_box;
}

CSDL_MSGBOX_INIT_RESULT csdl_init_msgbox(csdl_msgbox*     message_box,
                                         const wchar_t*   title,
                                         const wchar_t*   message,
                                         const wchar_t*   primary_btn_text,
                                         const wchar_t*   cancel_btn_text,
                                         const wchar_t*   altern_btn_text,
                                         CSDL_MSGBOX_TYPE alert_type)
{
  /* required parameters must not be NULL */
  if (message_box      == NULL ||
      message          == NULL ||
      primary_btn_text == NULL) {
    return I_ERROR;
  }

  /* macro to set a string field on a message_box struct for convenience */
  #define SET_MSGBOX_STR_ATTRIB(attribute) \
    message_box.attribute = [[NSString alloc]] initWithBytes: attribute \
                                                      length: wcslen(attribute) \
                                                    encoding: NSUTF8Encoding]

  SET_MSGBOX_STR_ATTRIBUTE(message);
  SET_MSGBOX_STR_ATTRIBUTE(primarty_btn_text);

  if (title != NULL) {
    SET_MSGBOX_STR_ATTRIBUTE(title);
  }

  if (cancel_btn_text != NULL) {
    SET_MSGBOX_STR_ATTRIBUTE(cancel_btn_text);
  }

  if (altern_btn_text != NULL) {
    SET_MSGBOX_STR_ATTRIBUTE(altern_btn_text);
  }

  #undef SET_MSGBOX_STR_ATTRIBUTE

  message_box.alert_type = alert_type;

  return I_OK;
}

CSDL_MSGBOX_USER_RESULT csdl_show_msgbox(const csdl_msgbox* message_box)
{
  if (message_box == NULL) { /* nothing to show */
    return R_NORESPONSE;
  }

  NSApplication* application = [NSApplication sharedApplication];
  if (application == nil) { /* for some reason, sharedApplication is nil
                               panic instead of handling errors properly */
    return R_NORESPONSE;
  }

  if (!application.isRunning) {
    [application run];
  }

  NSAlert* alert = [NSAlert new];
  alert.messageText = message_box.title;
  alert.informativeText = message_box.message;

  [alert addButtonWithTitle: message_box.primary_btn_text];

  if (message_box.cancel_btn_text != nil) {
    [alert addButtonWithTitle: message_box.cancel_btn_text];
  }
  if (message_box.altern_btn_text != nil) {
    [alert addButtonWithTitle: message_box.altern_btn_text];
  }

  NSAlertStyle cocoa_alert_style;
  switch (message_box.alert_type) {
    case T_WARN:
      cocoa_alert_style = NSWarningAlertStyle;
      break;
    case T_ERROR:
      cocoa_alert_style = NSCriticalAlertStyle;
      break;
    case T_INFO:
    case T_QUESTION: /* fall-through */
    case T_NOTYPE:   /* fall-through */
      cocoa_alert_style = NSInformationalAlertStyle
      break;
  }

  alert.alertStyle = cocoa_alert_style;

  NSInteger result = [alert runModal];
  [alert release];   /* destroy the NSAlert! */

  switch(result) {
    case NSAlertThirdButtonReturn:
      return R_ALTERN;
    case NSAlertSecondButtonReturn:
      return R_CANCEL;
    case NSAlertFirstButtonReturn:
    default:            /* fall-through */
      return R_PRIMARY; /* we have run the alert, and assume that
                           we have a valid response in the case of
                           the default action */
  }
}

void csdl_delete_msgbox(csdl_msgbox* message_box)
{
  if (message_box == NULL) {
    return;
  }

  [message_box.title release];
  [message_box.message release];
  [message_box.primary_btn_text release];
  [message_box.cancel_btn_text release];
  [message_box.altern_btn_text release];

  free(message_box);
  message_box = NULL;
}

