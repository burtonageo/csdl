#include "csdl.h"

csdl_msgbox* csdl_create_msgbox(void)
{
  return NULL;
}

CSDL_MSGBOX_INIT_RESULT csdl_init_msgbox(const csdl_msgbox*    box,
                                         const wchar_t* const  title,
                                         const wchar_t* const  message,
                                         const wchar_t* const  primary_btn_text,
                                         const wchar_t* const  cancel_btn_text,
                                         const wchar_t* const  altern_btn_text,
                                         CSDL_MSGBOX_TYPE      alert_type)
{
  return I_ERROR;
}

CSDL_MSGBOX_USER_RESULT csdl_show_msgbox(const csdl_msgbox* message_box)
{
  return R_NORESPONSE;
}

void csdl_delete_msgbox(csdl_msgbox* message_box)
{
  free(message_box);
}
