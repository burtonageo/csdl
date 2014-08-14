/**
 * @file    csdl.h
 * @author  George Burton <burtonageo@gmail.com>
 * @version 0.1
 *
 * @section LICENSE
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details at
 * http://www.gnu.org/copyleft/gpl.html
 *
 * @section DESCRIPTION
 *
 * The main csdl interface.
 *
 */

#ifndef CSDL_H
#define CSDL_H

#include <wchar.h>

#ifdef __cplusplus__
extern "C" {
#endif

/**
 * Represents what sort of message box should be created.
 */
enum CSDL_MSGBOX_TYPE {
  T_NOTYPE,            /**< a blank message box */
  T_INFO,              /**< an information alert box */
  T_WARN,              /**< a message box with a warning */
  T_ERROR              /**< a message box used to display an error */
};

/**
 * Represents which button the program user clicked on
 */
enum CSDL_MSGBOX_USER_RESULT {
  R_PRIMARY,           /**< the primary action */
  R_CANCEL,            /**< a cancelled action */
  R_ALTERN,            /**< an alternate action */
  R_NORESPONSE         /**< this result means that the message box
                            could not be shown, and should not normally
                            occur. */
};

/**
 * A message box initialisation result.
 */
enum CSDL_MSGBOX_INIT_RESULT {
  OK,                  /**< There is no error */
  ERROR                /**< there was an undefined error and the
                            message box couldn't be created */
};

/**
 * An opaque type with implementation-specific data.
 */
typedef struct csdl_msgbox csdl_msgbox;

/**
 * Creates a csdl_msgbox pointer with default values.
 * 
 *  @return The created csdl_message box. This pointer is
 *          guaranteed never to be null.
 */
csdl_msgbox*            csdl_create_msgbox(void);

/**
 * Initialise a created csdl_msgbox.
 *  
 * @param message_box If this parameter is NULL, then this function returns an error. Otherwise,
 *                    the csdl_msgbox will be initialised with the data passed into this function.
 *
 * @param title This parameter is optional, and if NULL is passed, then the
 *              message box won't have a title
 *
 * @param message Main message box body. If this parameter is NULL, then this function
 *                returns an error.
 *
 * @param primary_btn_text Text on primary button. If this parameter is NULL, then this
 *                         function returns an error.
 *
 * @param cancel_btn_text This parameter is optional, and if NULL is passed, then the
 *                        message box won't have a cancel button.
 *
 * @param altern_btn_text This parameter is optional, and if NULL is passed, then the
 *                        message box won't have an alternate button.
 *
 * @param alert_type The message box alert type.
 *
 * @return The result of the function.
 *
 */
CSDL_MSGBOX_INIT_RESULT csdl_init_msgbox(csdl_msgbox*     box,
                                         const wchar_t*   title,
                                         const wchar_t*   message,
                                         const wchar_t*   primary_btn_text,
                                         const wchar_t*   cancel_btn_text,
                                         const wchar_t*   altern_btn_text,
                                         CSDL_MSGBOX_TYPE alert_type);

/**
 * Shows the dialog, and blocks the current thread until a user
 * response is received.
 *
 * @param message_box The message box to show. This is not modified, and
 *                    can be re-shown again.
 *
 * @return User response code. If the csdl_msgbox pointer is NULL,
 *         then a R_NORESPONSE is returned.
 */
CSDL_MSGBOX_USER_RESULT csdl_show_msgbox(const csdl_msgbox* message_box);

/**
 * Deletes an initialised csdl_msgbox and frees all memory allocated
 * by it.
 *
 * @param message_box After this function, the pointer is set to NULL.
 */
void                    csdl_delete_msgbox(const csdl_msgbox* message_box);

#ifdef __cplusplus__
} // extern "C"
#endif

#endif // CSDL_H
