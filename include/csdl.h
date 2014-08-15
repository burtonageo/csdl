/**
 * @file    csdl.h
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
 * The main csdl interface.
 *
 */

#ifndef CSDL_H
#define CSDL_H

#ifndef __cplusplus__
#include <wchar.h>
#endif

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
  R_PRIMARY,           /**< the ok/action button */
  R_CANCEL,            /**< the cancel button */
  R_ALTERN,            /**< an alternate button */
  R_NORESPONSE         /**< this result means that the user did not have
                            an opportunity to give a response, and should
                            not normally occur. */
};

/**
 * A message box initialisation result.
 */
enum CSDL_MSGBOX_INIT_RESULT {
  I_OK,                  /**< There is no error */
  I_ERROR                /**< there was an undefined error and the
                              message box couldn't be created */
};

/**
 * An opaque type which holds implementation-specific data.
 */
typedef struct csdl_msgbox csdl_msgbox;

/**
 * Creates a csdl_msgbox pointer with uninitialised values.
 * 
 *  @return A pointer to the created csdl_message box. This
 *          pointer is guaranteed never to be null, but it
 *          must be initialised with csdl_init_msgbox before
 *          it can be shown.
 */
csdl_msgbox*            csdl_create_msgbox(void);

/**
 * Initialise a created csdl_msgbox.
 *  
 * @param message_box If this parameter is NULL, then this function returns an error. Otherwise,
 *                    the csdl_msgbox will be initialised with the data passed into this function.
 *
 * @param title This parameter is optional; if NULL is passed, then the
 *              message box won't have a title
 *
 * @param message Main message box body. If this parameter is NULL, then this function
 *                returns an error.
 *
 * @param primary_btn_text Text on primary button. If this parameter is NULL, then this
 *                         function returns an error.
 *
 * @param cancel_btn_text This parameter is optional; if NULL is passed, then the
 *                        message box won't have a cancel button.
 *
 * @param altern_btn_text This parameter is optional; if NULL is passed, then the
 *                        message box won't have an alternate button.
 *
 * @param alert_type The message box alert type.
 *
 * @return The result of the function.
 */
CSDL_MSGBOX_INIT_RESULT csdl_init_msgbox(csdl_msgbox*      box,
                                         const wchar_t*    title,
                                         const wchar_t*    message,
                                         const wchar_t*    primary_btn_text,
                                         const wchar_t*    cancel_btn_text,
                                         const wchar_t*    altern_btn_text,
                                         CSDL_MSGBOX_TYPE  alert_type);

/**
 * Shows the dialog, and blocks the current thread until a user
 * response is received. If the native system requires an application
 * object to create windows, it will be constructed here the first time
 * it is run (assuming that it has not been constructed previously).
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
void                    csdl_delete_msgbox(csdl_msgbox* message_box);

#ifdef __cplusplus__
} /* extern "C" */
#endif

#endif /* CSDL_H */
