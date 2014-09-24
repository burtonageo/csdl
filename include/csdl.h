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
 * Represents what sort of dialog should be created. If
 * one of these types is not present, then the closest
 * alternative in meaning is used.
 *
 * Can take the values:
 * - T_NOTYPE,
 * - T_INFO,
 * - T_WARN,
 * - T_QUESTION,
 * - T_ERROR 
 */
typedef enum CsdlDialogType_e {
    T_NOTYPE,            /**< a blank message box */
    T_INFO,              /**< an information alert box */
    T_WARN,              /**< a message box with a warning */
    T_QUESTION,          /**< a message box with a question */
    T_ERROR              /**< a message box used to display an error */
} CsdlDialogType;



/**
 * Represents which button the program user clicked on
 *
 * Can take the values:
 * - R_PRIMARY,
 * - R_CANCEL,
 * - R_ALTERN,
 * - R_NORESPONSE
 */
typedef enum CsdlDialogUserResult_e {
    R_PRIMARY,           /**< the ok/action button */
    R_CANCEL,            /**< the cancel button */
    R_ALTERN,            /**< an alternate button */
    R_NORESPONSE         /**< this result means that the user did not have
                              an opportunity to give a response, and should
                              not normally occur. */
} CsdlDialogUserResult;



/**
 * A message box initialisation result.
 *
 * Can take the values:
 * - I_OK,
 * - I_ERROR
 */
typedef enum CsdlDialogInitResult_e {
    I_OK,                  /**< There is no error */
    I_ERROR                /**< there was an undefined error and the
                                message box couldn't be created */
} CsdlDialogInitResult;



/**
 * An opaque struct which holds implementation-specific data.
 */
typedef struct CsdlDialog_s CsdlDialog;



/**
 * Creates a CsdlDialog pointer with uninitialised values.
 * 
 * @return A pointer to the created CsdlDialog box. This
 *         pointer is guaranteed never to be null if there
 *         is enough memory, but it must be initialised with
 *         csdl_init_dialog before it can be shown.
 */
CsdlDialog*          csdl_create_dialog(void);



/**
 * Initialise a created CsdlDialog.
 *  
 * @param message_box If this parameter is NULL, then this function returns an error. Otherwise,
 *                    the csdl_msgbox will be initialised with the other data passed into this
 *                    function.
 *
 * @param title This parameter is optional; if NULL is passed, then the
 *              message box won't have a title
 *
 * @param message Main message box body. If this parameter is NULL, then this function
 *                returns an error, but the message_box parameter will still be a
 *                valid pointer.
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
CsdlDialogInitResult csdl_init_dialog(CsdlDialog*          dialog,
                                      const wchar_t* const title,
                                      const wchar_t* const message,
                                      const wchar_t* const primary_btn_text,
                                      const wchar_t* const cancel_btn_text,
                                      const wchar_t* const altern_btn_text,
                                      CsdlDialogType       alert_type);



/**
 * Shows the dialog, and blocks the current thread until a user
 * response is received. If the native system requires that an application
 * object has been constructed as a prerequisite to show a dialog window,
 * it will be constructed here the first time it is run (assuming that it
 * has not been constructed previously).
 *
 * @param message_box The message box to show. This is not modified, and
 *                    can be re-shown again.
 *
 * @return User response code. If the csdl_msgbox pointer is NULL, or there
 *         is an error, then a R_NORESPONSE is returned.
 */
CsdlDialogUserResult csdl_show_dialog(const CsdlDialog* const dialog);




/**
 * Deletes an initialised csdl_msgbox and frees all memory allocated
 * by it.
 *
 * @param message_box After this function, the pointer is set to NULL.
 */
void                 csdl_delete_dialog(CsdlDialog* dialog);



#ifdef __cplusplus__
} /* extern "C" */
#endif

#endif /* CSDL_H */
