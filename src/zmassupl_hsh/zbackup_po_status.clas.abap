CLASS zbackup_po_status DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  meTHODS: backup.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zbackup_po_status IMPLEMENTATION.
  METHOD backup.

**PACKAGE : ZA2R_PO_STATUS
*-----------------------
*mESAGE CLASS- ZA2R_PROJNOTIFY
*
*-------------------------
*000 DOA table not maintained!
*001 Error in fetching sender email!
*002 Project & and WBS element updated to CLSD successfully
*003 Failed in changing the status to CLSD for project &
*004 Person responsible email id is not maintained for &
*005 Project Category & does not exist.
*006
*007 Project Subcategory &1 does not belong to Category &2.
*___ _________________________________________________________________________
*
*pROGRAM - ZA2R_R_SEND_NOTIFICATIONS
*
**&---------------------------------------------------------------------*
**& Report ZA2R_R_SEND_NOTIFICATIONS
**&---------------------------------------------------------------------*
** PROGRAM ID          : ZA2R_R_SEND_NOTIFICATIONS
** DESCRIPTION         : The objective of this program is to send notifications on
**                       30th and 5th day on before the planned capitalization date.
**                       Notification on 30th and 5th days before project close date
**                       based on PO status.
**                       Project closure (E016)
** AUTHOR              : AK311653
** CREATE DATE         : 08/28/2024
** Transport Request   : FSDK901013
** Initial Change Req# :
**
** VERSION CONTROL
**
** Date        Name       Change Req#   Description of change    Issue#
**======================================================================
** 05.11.2024 SH311655   E016      Project closure
**======================================================================
**&---------------------------------------------------------------------*
**& Report ZA2R_R_SEND_NOTIFICATIONS
**&---------------------------------------------------------------------*
*
*REPORT za2r_r_send_notifications.
*
**&---------------------------------------------------------------------*
**& INCLUDE ZA2R_R_SEND_NOTIFICATIONS_TOP
**&---------------------------------------------------------------------*
*INCLUDE za2r_r_send_notifications_top.
*
**&---------------------------------------------------------------------*
**& INCLUDE ZA2R_R_SEND_NOTIFICATIONS_SEL
**&---------------------------------------------------------------------*
*INCLUDE za2r_r_send_notifications_sel.
*
**&---------------------------------------------------------------------*
**& INCLUDE ZA2R_R_SEND_NOTIFICATIONS_SUB
**&---------------------------------------------------------------------*
*INCLUDE za2r_r_send_notifications_sub.
*
** **********************************************************************
** Start of selection
*************************************************************************
*
*START-OF-SELECTION.
*
**Perform for fetching and processing Data.
*  DATA : go_uploader TYPE REF TO lcl_uploader.
*  CREATE OBJECT go_uploader.
*
***    Method Call to process data
*  go_uploader->process_notification( ).
*
*
*-----------------------------------------------
*
*Includes:
*ZA2R_R_SEND_NOTIFICATIONS_TOP
*
**&---------------------------------------------------------------------*
**& Include          ZA2R_R_SEND_NOTIFICATIONS_TOP
**&---------------------------------------------------------------------*
** PROGRAM ID          : ZA2R_R_SEND_NOTIFICATIONS_TOP
** DESCRIPTION         : The objective of this program is to send notifications on
**                       30th and 5th day on before the planned capitalization date
**
** AUTHOR              : SH311655/AK311653
** CREATE DATE         : 08/28/2024
** Transport Request   : FSDK901013
** Initial Change Req# :
**
** VERSION CONTROL
**
** Date        Name       Change Req#   Description of change    Issue#
**======================================================================
** 5.11.2024 Sushmitha    E016          Project closure
**======================================================================
*
** Local Class Definition
*CLASS lcl_uploader DEFINITION FINAL.
*  PUBLIC SECTION.
*    TYPES: BEGIN OF lty_receiver,
*             name          TYPE tvarvc-name,
*             low           TYPE tvarvc-low,
*             high          TYPE tvarvc-high,
*             expcategoryid TYPE zfi_wd_doa-expcategoryid,
*             userid        TYPE zfi_wd_doa-userid,
*             useremail     TYPE zfi_wd_doa-useremail,
*             managerid     TYPE zfi_wd_doa-managerid,
*             manageremail  TYPE zfi_wd_doa-manageremail,
*           END OF lty_receiver,
*           ltt_receiver TYPE STANDARD TABLE OF lty_receiver,
*           ltt_wbs      TYPE STANDARD TABLE OF za2r_i_projnotify.
*
*    DATA: lv_size            TYPE so_obj_len,
*          lt_binary_content1 TYPE solix_tab.
*
*    CONSTANTS: lc_capdate TYPE char20         VALUE 'CAP_DATE_ESCALATE',
*               lc_podate  TYPE char20         VALUE 'PO_DATE_ESCALATE',
*               lc_tvarv   TYPE rvari_vnam     VALUE 'ZA2R_S_30D_5D_NOTIFICATION'.
*
** Class-Methods
*    METHODS :
**      All method call will happen here
*      process_notification,
**      Method for AutoClose
*      project_autoclose
*        IMPORTING im_date  TYPE sy-datum
*                  im_sendr TYPE adr6-smtp_addr
*                  it_wbs   TYPE ltt_wbs,
**      Method for sending email
*      sendmail
*        IMPORTING im_receiver    TYPE ad_smtpadr
*                  im_projprofl   TYPE i_projectdata-projectprofilecode OPTIONAL
*                  im_attach_flg  TYPE char1 OPTIONAL
*                  im_cc_flg      TYPE char1 OPTIONAL
*                  im_wbs         TYPE prps-posid OPTIONAL
*                  iv_template    TYPE smtg_tmpl_id
*                  it_doareceiver TYPE ltt_receiver OPTIONAL
*                  im_sender      TYPE adr6-smtp_addr.
*ENDCLASS.
*
*-------------------------------
*
*ZA2R_R_SEND_NOTIFICATIONS_SUB
*
**&-------------------------------------------------------------------------*
**& Include          ZA2R_R_SEND_NOTIFICATIONS_SUB
**&-------------------------------------------------------------------------*
** PROGRAM ID          : ZA2R_R_SEND_NOTIFICATIONS
** DESCRIPTION         : The objective of this program is to send notifications on
**                       30th and 5th day on before the planned capitalization date
**
** AUTHOR              : SH311655/AK311653
** CREATE DATE         : 08/28/2024
** Transport Request   : FSDK901013
** Initial Change Req# :
**
** VERSION CONTROL
**
** Date        Name       Change Req#   Description of change        Issue#
** 11/03/2025  CY311688                 Delete unwanted WO and PO    INC0562342
**                                      status from ZA2R_A_POSTATUS
**==============================================================================
*
**Implementation block for class lcl_uploader
*CLASS lcl_uploader IMPLEMENTATION.
*
*  METHOD process_notification.
*
*    DATA : lwa_durd30      TYPE psen_duration,
*           lwa_durd5       TYPE psen_duration,
*           lwa_durd1       TYPE psen_duration,
*           lv_30date       TYPE datum,
*           lv_5date        TYPE datum,
*           lv_1date        TYPE datum,
*           lwa_attach      TYPE soli,
*           lv_data_string  TYPE string,
*           lv_template     TYPE smtg_tmpl_id,
*           lv_atchtemplate TYPE smtg_tmpl_id,
*           lt_mail         TYPE TABLE OF lty_receiver.
*
** Start of Changes by CY311688 on 11/03/2025 for INC0562342
*    DATA: lr_wo_status TYPE RANGE OF zzwostatus,
*          lr_po_status TYPE RANGE OF zzpostatus.
** End of Changes by CY311688 on 11/03/2025 for INC0562342
*
*    CONSTANTS: lc_add      TYPE adsub               VALUE '+',
*               lc_subtract TYPE adsub               VALUE '-',
*               lc_30       TYPE psen_duration-durdd VALUE 30.
*
**    If selection screen date is empty taking syatem date
*    IF p_date IS INITIAL.
*      DATA(lv_date) = sy-datum.
*    ELSE.
*      lv_date = p_date.
*    ENDIF.
*
**Fetching receiver from DOA table
*    SELECT a~name, a~low, a~high,
*            b~expcategoryid, b~userid,
*            b~useremail, b~managerid,
*            b~manageremail
*      FROM tvarvc AS a
*      INNER JOIN zfi_wd_doa AS b
*      ON a~low = b~expcategoryid
*      INTO TABLE @lt_mail
*      WHERE ( high = @lc_capdate
*         OR high = @lc_podate )
*        AND name = @lc_tvarv.
*    IF sy-subrc <> 0.
**      'DOA table not maintained!
*      MESSAGE e000(za2r_projnotify) .
*    ENDIF.
**Fetching sender
*    SELECT SINGLE smtp_addr
*     FROM p_user_addr_email
*     WHERE bname = @sy-uname
*     INTO @DATA(lv_sender).
*    IF sy-subrc <> 0.
**      'Error in fetching sender email!'
*      MESSAGE e001(za2r_projnotify) .
*    ENDIF.
**    Calculating 30 day prior date of capitalization date
*    lwa_durd30-durdd = lc_30.
*    CALL FUNCTION 'HR_99S_DATE_ADD_SUB_DURATION'
*      EXPORTING
*        im_date     = lv_date
*        im_operator = lc_add
*        im_duration = lwa_durd30
*      IMPORTING
*        ex_date     = lv_30date.
**    Calculating 5 day prior date of capitalization date
*    lwa_durd5-durdd = 5.
*    CALL FUNCTION 'HR_99S_DATE_ADD_SUB_DURATION'
*      EXPORTING
*        im_date     = lv_date
*        im_operator = lc_add
*        im_duration = lwa_durd5
*      IMPORTING
*        ex_date     = lv_5date.
**    Calculating 1 day after date of capitalization date to fetch wbs details which has crossed Cap. Date
*    lwa_durd1-durdd = 1.
*    CALL FUNCTION 'HR_99S_DATE_ADD_SUB_DURATION'
*      EXPORTING
*        im_date     = lv_date
*        im_operator = lc_subtract
*        im_duration = lwa_durd1
*      IMPORTING
*        ex_date     = lv_1date.
*
** Start of Changes by CY311688 on 11/03/2025 for INC0562342
**   Build range table for unwanted WO status
*    lr_wo_status = VALUE #( ( sign = 'I' option = 'EQ' low = 'DEFERRED' )
*                            ( sign = 'I' option = 'EQ' low = 'CAN' )
*                            ( sign = 'I' option = 'EQ' low = 'VOID' )
*                            ( sign = 'I' option = 'EQ' low = 'VOIDED' )
*                            ( sign = 'I' option = 'EQ' low = 'CLOSE' ) ).
*
**   Build range table for unwanted PO status
*    lr_po_status = VALUE #( ( sign = 'I' option = 'EQ' low = 'DEFERRED' )
*                            ( sign = 'I' option = 'EQ' low = 'CAN' )
*                            ( sign = 'I' option = 'EQ' low = 'VOID' )
*                            ( sign = 'I' option = 'EQ' low = 'VOIDED' )
*                            ( sign = 'I' option = 'EQ' low = 'CLOSE' ) ).
*
**   Delete entries from table ZA2R_A_POSTATUS with unwanted WO and PO status
*    DELETE FROM za2r_a_postatus WHERE wostatus IN lr_wo_status
*                                  AND po_status IN lr_po_status.
*    IF sy-subrc EQ 0.
*      COMMIT WORK.
*    ELSE.
*      ROLLBACK WORK.
*    ENDIF.
** End of Changes by CY311688 on 11/03/2025 for INC0562342
*
*    SELECT *
*      FROM za2r_i_projnotify
*      WHERE ( aktiv EQ @lv_30date
*         OR  aktiv EQ @lv_5date
*         OR  aktiv EQ @lv_1date
*         OR  usr08 EQ @lv_30date
*         OR  usr08 EQ @lv_5date
*         OR  usr08 EQ @lv_1date
*         OR  usr08 EQ @lv_date )
*      INTO TABLE @DATA(lt_wbsdetails).
*
*    IF sy-subrc = 0.
*      SORT lt_wbsdetails ASCENDING BY pspid.
*      DELETE ADJACENT DUPLICATES FROM lt_wbsdetails COMPARING ALL FIELDS.
**        Prepare header for attachment
*      ##TEXT_POOL
*      CONCATENATE 'Project'(003) 'WBS Element'(004) 'Profile'(005)
*                  'Capitalization Date'(006) 'Project Owner User ID'(007) 'Project Owner Email'(008)
*       INTO lwa_attach SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
*
*      LOOP AT lt_wbsdetails ASSIGNING FIELD-SYMBOL(<lfs_wbsdetails>).
*
**********************Logic for sending notification 30 day prior to Cap. Date*******************************************
*        IF <lfs_wbsdetails>-aktiv = lv_30date AND <lfs_wbsdetails>-personresponsible IS NOT INITIAL AND <lfs_wbsdetails>-accasg = abap_true.
*          DATA(lv_receiver) = <lfs_wbsdetails>-email.
*          DATA(lv_cc) = ''.
*          DATA(lv_noattach) = abap_true.
*          lv_template = 'ZA2R_30DAYCAPNOTIFY'.
*
*******************************Logic for sending notification 5 day prior to Cap. Date*************************************
*        ELSEIF <lfs_wbsdetails>-aktiv = lv_5date AND <lfs_wbsdetails>-personresponsible IS NOT INITIAL  AND <lfs_wbsdetails>-accasg = abap_true.
*
*          lv_receiver = <lfs_wbsdetails>-email.
*          lv_cc = ''.
*          lv_noattach = abap_true.
*          lv_template = 'ZA2R_5DAYCAPNOTIFY'.
*
*************************************Logic for sending notification for project who has crossed Cap. Date****************************
*        ELSEIF <lfs_wbsdetails>-aktiv = lv_1date AND <lfs_wbsdetails>-accasg = abap_true.
**        Prepare line item for attachment
*          CONCATENATE lv_data_string lwa_attach INTO lv_data_string.
*
*          CONCATENATE <lfs_wbsdetails>-pspid <lfs_wbsdetails>-pspnr <lfs_wbsdetails>-profl
*                       <lfs_wbsdetails>-aktiv <lfs_wbsdetails>-bname <lfs_wbsdetails>-email
*                 INTO lwa_attach-line
*         SEPARATED BY cl_abap_char_utilities=>horizontal_tab.
*
*          CONCATENATE lv_data_string lwa_attach-line
*                 INTO lv_data_string
*         SEPARATED BY cl_abap_char_utilities=>newline.
*          CLEAR: lwa_attach.
*
** Converting attachment into binary format
*          TRY.
*              CALL METHOD cl_bcs_convert=>string_to_solix
*                EXPORTING
*                  iv_string   = lv_data_string
*                  iv_codepage = '4103'
*                  iv_add_bom  = abap_true
*                IMPORTING
*                  et_solix    = lt_binary_content1
*                  ev_size     = lv_size.
*            CATCH cx_bcs.
*              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*          ENDTRY.
*
*          DATA(lv_attachrecvr) = <lfs_wbsdetails>-email.
*          DATA(lv_attach) = abap_true.
*          lv_cc = ''.
*          lv_noattach = ''.
*          lv_atchtemplate = 'ZA2R_31DAYCAPNOTIFY'.
*
**************************************Logic for sending notification 30 day prior to Auto close date*************************************
*        ELSEIF <lfs_wbsdetails>-usr08 = lv_30date AND <lfs_wbsdetails>-personresponsible IS NOT INITIAL.
*
*          lv_receiver = <lfs_wbsdetails>-email.
*          lv_cc = ''.
*          lv_noattach = abap_true.
*          lv_template = 'ZA2R_30DAYPOCLOSE'.
*
**********************************Logic for sending notification 5 day prior to Auto close date*******************************************
*        ELSEIF <lfs_wbsdetails>-usr08 = lv_5date AND <lfs_wbsdetails>-personresponsible IS NOT INITIAL.
*
*          lv_receiver = <lfs_wbsdetails>-email.
*          lv_cc = ''.
*          lv_noattach = abap_true.
*          lv_template = 'ZA2R_5DAYPOCLOSE'.
*
*************************************Logic for sending notification for project who has crossed Auto close date and PO are not closed*******************************
*        ELSEIF <lfs_wbsdetails>-usr08 = lv_1date AND <lfs_wbsdetails>-personresponsible IS NOT INITIAL.
*
*          lv_receiver = <lfs_wbsdetails>-email.
*          lv_cc = abap_true.
*          lv_noattach = abap_true.
*          lv_template = 'ZA2R_181DAYPOCLOSE'.
*
*        ELSEIF <lfs_wbsdetails>-usr08 = lv_date AND <lfs_wbsdetails>-personresponsible IS NOT INITIAL.
*
*          DATA(lv_close_flg) = abap_true.
*          lv_noattach = abap_true.
*
*        ELSEIF <lfs_wbsdetails>-personresponsible IS INITIAL.
*          MESSAGE i004(za2r_projnotify) WITH <lfs_wbsdetails>-pspnr.
*        ENDIF.
*        IF lv_noattach = abap_true AND lv_receiver IS NOT INITIAL.
*          CALL METHOD sendmail
*            EXPORTING
*              im_receiver    = lv_receiver
*              im_projprofl   = <lfs_wbsdetails>-profl
*              im_cc_flg      = lv_cc
*              im_wbs         = <lfs_wbsdetails>-pspnr
*              it_doareceiver = lt_mail
*              iv_template    = lv_template
*              im_sender      = lv_sender.
*          CLEAR: lv_receiver, lv_cc, lv_template.
*        ELSEIF lv_close_flg = abap_false AND lv_noattach = abap_true.
*          MESSAGE i004(za2r_projnotify) WITH <lfs_wbsdetails>-pspnr.
*        ENDIF.
*
*      ENDLOOP.
*      IF lv_attach IS NOT INITIAL AND lv_attachrecvr IS NOT INITIAL.
*        CLEAR: lv_cc.
*
*        CALL METHOD sendmail
*          EXPORTING
*            im_receiver    = lv_attachrecvr
*            im_projprofl   = <lfs_wbsdetails>-profl
*            im_attach_flg  = lv_attach
*            im_cc_flg      = lv_cc
*            im_wbs         = <lfs_wbsdetails>-pspnr
*            it_doareceiver = lt_mail
*            iv_template    = lv_atchtemplate
*            im_sender      = lv_sender.
*        CLEAR: lv_receiver, lv_attach, lv_cc, lv_template.
*      ELSEIF lv_close_flg = abap_false AND lv_receiver IS NOT INITIAL.
*        MESSAGE i004(za2r_projnotify) WITH <lfs_wbsdetails>-pspnr.
*      ENDIF.
*
*    ENDIF.
**********************************************Method for Project Auto Close******************************************************************
*    CALL METHOD project_autoclose
*      EXPORTING
*        im_date  = lv_date
*        im_sendr = lv_sender
*        it_wbs   = lt_wbsdetails.
*  ENDMETHOD.
*
*  METHOD sendmail.
*    DATA: lo_recipient TYPE REF TO if_recipient_bcs,
*          lo_sender    TYPE REF TO if_sender_bcs.
*    CONSTANTS : lc_profile TYPE proj-profl VALUE 'Z000001'.
*
*    TRY.
*        CALL METHOD cl_bcs=>create_persistent
*          RECEIVING
*            result = DATA(lo_send_request).
*      CATCH cx_send_req_bcs.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDTRY.
*
**Method for creating document for Email.
*    TRY.
*        DATA(lo_email_api) = cl_smtg_email_api=>get_instance( iv_template_id = iv_template ).
*      CATCH cx_smtg_email_common.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDTRY.
**    Key field value of CDS passing to Email template
*    TRY.
*        DATA(lt_cds_key) = VALUE if_smtg_email_template=>ty_gt_data_key(
*                                               ( name = 'pspnr' value = im_wbs ) ).
*      CATCH cx_document_bcs.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDTRY.
**      If attachment flag is true then adding XLS attachment
*    IF im_attach_flg = abap_true.
*
*      TRY.
*          lo_email_api->render(
*            EXPORTING
*              iv_language  = 'E'
*              it_data_key  = lt_cds_key
*            IMPORTING
*              ev_subject   = DATA(lv_subj)
*              ev_body_text = DATA(lv_txt)
*          ).
*        CATCH cx_smtg_email_common. " E-Mail API Exceptions
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDTRY.
**      Converting email text from string to soli format
*      TRY.
*          CALL METHOD cl_bcs_convert=>string_to_soli
*            EXPORTING
*              iv_string = lv_txt
*            RECEIVING
*              et_soli   = DATA(lt_doctext).
*        CATCH cx_bcs.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDTRY.
*      DATA(lv_convsub) = CONV so_obj_des( lv_subj ).
**      Creating email body
*      TRY.
*          CALL METHOD cl_document_bcs=>create_document
*            EXPORTING
*              i_type    = 'RAW'
*              i_subject = lv_convsub
*              i_text    = lt_doctext
*            RECEIVING
*              result    = DATA(lo_doc).
*        CATCH cx_document_bcs.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDTRY.
**      Creating email attachment
*      TRY.
*          CALL METHOD lo_doc->add_attachment
*            EXPORTING
*              i_attachment_type    = 'xls'
*              i_attachment_subject = TEXT-002
*              i_attachment_size    = lv_size
*              i_att_content_hex    = lt_binary_content1.
*        CATCH cx_document_bcs.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDTRY.
*
*      TRY.
*          CALL METHOD lo_send_request->set_document
*            EXPORTING
*              i_document = lo_doc.
*        CATCH cx_send_req_bcs.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDTRY.
*
*    ELSE.
**      creating email body when there is no attachment
*      TRY.
*          lo_email_api->render_bcs( io_bcs = lo_send_request iv_language = 'E' it_data_key = lt_cds_key ).
*        CATCH cx_smtg_email_common.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDTRY.
*
*    ENDIF.
*
** Adding Sender email
*    TRY.
*        lo_sender = cl_cam_address_bcs=>create_internet_address( im_sender ).
*      CATCH  cx_address_bcs.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDTRY.
*
*    TRY.
*        CALL METHOD lo_send_request->set_sender
*          EXPORTING
*            i_sender = lo_sender.
*      CATCH cx_send_req_bcs.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDTRY.
*
**   Adding Recipients from DOA for 31 day Cap. date escalation
*    IF im_attach_flg = abap_true.
*
*      LOOP AT it_doareceiver ASSIGNING FIELD-SYMBOL(<lfs_mail>) WHERE high = lc_capdate.
*        TRY.
*            lo_recipient = cl_cam_address_bcs=>create_internet_address( <lfs_mail>-useremail ).
*          CATCH  cx_address_bcs.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDTRY.
**     add recipient with its respective attributes to send request
*        TRY.
*            CALL METHOD lo_send_request->add_recipient
*              EXPORTING
*                i_recipient = lo_recipient
*                i_express   = abap_true
*                i_copy      = ''.
*          CATCH cx_send_req_bcs.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDTRY.
*        TRY.
*            lo_recipient = cl_cam_address_bcs=>create_internet_address( <lfs_mail>-manageremail ).
*          CATCH  cx_address_bcs.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDTRY.
**     add recipient with its respective attributes to send request
*        TRY.
*            CALL METHOD lo_send_request->add_recipient
*              EXPORTING
*                i_recipient = lo_recipient
*                i_express   = abap_true
*                i_copy      = ''.
*          CATCH cx_send_req_bcs.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDTRY.
*
*      ENDLOOP.
*
**  Adding reciepients for other cases : Person reponsible for a project
*    ELSE.
*      TRY.
*          lo_recipient = cl_cam_address_bcs=>create_internet_address( im_receiver ).
*        CATCH  cx_address_bcs.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDTRY.
**     add recipient with its respective attributes to send request
*      TRY.
*          CALL METHOD lo_send_request->add_recipient
*            EXPORTING
*              i_recipient = lo_recipient
*              i_express   = abap_true
*              i_copy      = ''.
*        CATCH cx_send_req_bcs.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDTRY.
*    ENDIF.
*
**    CC mail address
*    IF im_projprofl = lc_profile AND im_cc_flg = abap_true.
*
*      LOOP AT it_doareceiver ASSIGNING FIELD-SYMBOL(<lfs_cc_mail>) WHERE high = lc_podate.
*        TRY.
*            lo_recipient = cl_cam_address_bcs=>create_internet_address( <lfs_cc_mail>-useremail ).
*          CATCH  cx_address_bcs.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDTRY.
**     add recipient with its respective attributes to send request
*        TRY.
*            CALL METHOD lo_send_request->add_recipient
*              EXPORTING
*                i_recipient = lo_recipient
*                i_express   = abap_true
*                i_copy      = abap_true.
*          CATCH cx_send_req_bcs.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDTRY.
*        TRY.
*            lo_recipient = cl_cam_address_bcs=>create_internet_address( <lfs_cc_mail>-manageremail ).
*          CATCH  cx_address_bcs.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDTRY.
**     add recipient with its respective attributes to send request
*        TRY.
*            CALL METHOD lo_send_request->add_recipient
*              EXPORTING
*                i_recipient = lo_recipient
*                i_express   = abap_true
*                i_copy      = abap_true.
*          CATCH cx_send_req_bcs.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDTRY.
*
*      ENDLOOP.
*    ENDIF.
** To send email
*    TRY.
*        CALL METHOD lo_send_request->send
*          RECEIVING
*            result = DATA(lv_status).
*      CATCH cx_send_req_bcs.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDTRY.
*    COMMIT WORK.
*  ENDMETHOD.
*
*  METHOD project_autoclose.
*    TYPES : BEGIN OF lty_proj,
*              project  TYPE ps_pspid,
*              wbs      TYPE ps_posid,
*              clsd_flg TYPE char1,
*              projdesc TYPE ps_post1,
*              email    TYPE ad_smtpadr,
*            END OF lty_proj.
*
*    CONSTANTS : lc_x        TYPE c     VALUE 'X',
*                lc_e        TYPE c     VALUE 'E',
*                lc_o        TYPE c     VALUE 'O',
*                lc_clsd(4)  TYPE c     VALUE 'CLSD',
*                lc_i0045(5) TYPE c     VALUE 'I0045'.
*
*    DATA: lt_wbs_clsd  TYPE TABLE OF bapi_wbs_mnt_system_status,
*          lwa_wbs_clsd TYPE bapi_wbs_mnt_system_status,
*          lt_result    TYPE TABLE OF bapi_status_result,
*          lwa_return   TYPE bapireturn1,
*          lwa_return2  TYPE bapireturn1,
*          lv_closed    TYPE c,
*          lt_wbs       TYPE TABLE OF za2r_i_projnotify,
*          lt_proj1     TYPE TABLE OF lty_proj,
*          lwa_proj     TYPE lty_proj,
*          lt_result3   TYPE TABLE OF bapi_status_result,
*          lv_receiver1 TYPE ad_smtpadr,
*          lv_template  TYPE smtg_tmpl_id,
*          lt_mail      TYPE TABLE OF lty_receiver,
*          lv_profl     TYPE profidproj.
*
*    IF im_date IS NOT INITIAL.
**  Get all WBS elements with Auto close date as LV_DATE.
*      lt_wbs = it_wbs.
*      LOOP AT lt_wbs ASSIGNING FIELD-SYMBOL(<lfs_wbs>) WHERE usr08 = im_date.
*        lwa_proj-project = <lfs_wbs>-pspid.
*        lwa_proj-projdesc = <lfs_wbs>-post1.
*        lwa_proj-wbs = <lfs_wbs>-pspnr.
*        lwa_proj-email = <lfs_wbs>-email.
*
*        IF <lfs_wbs>-close_stat = lc_o AND <lfs_wbs>-stat = lc_i0045.
*          lwa_proj-clsd_flg = ''.
*        ELSE.
*          lwa_proj-clsd_flg = lc_x.
*
*        ENDIF.
*        APPEND lwa_proj TO lt_proj1.
*        CLEAR lwa_proj.
*      ENDLOOP.
*
*      LOOP AT lt_proj1 ASSIGNING FIELD-SYMBOL(<lfs_proj>) .
*
*        AT NEW project .    "New Project
*          CLEAR : lv_closed.
*        ENDAT.
*
*        IF <lfs_proj>-clsd_flg = lc_x.
**  When POs are closed for WBS element set blank
*          lwa_wbs_clsd-wbs_element = <lfs_proj>-wbs.
*          lwa_wbs_clsd-set_system_status = lc_clsd.
*          APPEND lwa_wbs_clsd TO lt_wbs_clsd.
*          CLEAR : lwa_wbs_clsd.
*
**  When PO is not closed for single WBS element of Project set OPEN
*        ELSE.
*          lv_closed = lc_o.
*        ENDIF.
** Only closed POs WBS elements are changing to CLSD status
*        AT END OF project.
*          IF lt_wbs_clsd IS NOT INITIAL.
*            CALL FUNCTION 'BAPI_PS_INITIALIZATION' DESTINATION 'NONE'
*              EXCEPTIONS
*                system_failure        = 1
*                communication_failure = 2.
*            IF sy-subrc = 0 .
**  Set system status to CLSD for WBS elements
*              CALL FUNCTION 'BAPI_BUS2054_SET_STATUS' DESTINATION 'NONE'
*                IMPORTING
*                  return                = lwa_return
*                TABLES
*                  i_wbs_system_status   = lt_wbs_clsd
*                  e_result              = lt_result
*                EXCEPTIONS
*                  system_failure        = 1
*                  communication_failure = 2.
*              IF sy-subrc = 0.
*                CALL FUNCTION 'BAPI_PS_PRECOMMIT' DESTINATION 'NONE'
*                  EXCEPTIONS
*                    system_failure        = 1
*                    communication_failure = 2.
*              ENDIF.
**  Closing the Project if all WBS elements are closed
*              IF sy-subrc = 0 AND lv_closed <> lc_o AND lwa_return-type <> lc_e.
*
*                CALL FUNCTION 'BAPI_PS_INITIALIZATION' DESTINATION 'NONE'
*                  EXCEPTIONS
*                    system_failure        = 1
*                    communication_failure = 2.
*                IF sy-subrc = 0.
**  Set system status to CLSD for Project
*                  CALL FUNCTION 'BAPI_BUS2001_SET_STATUS' DESTINATION 'NONE'
*                    EXPORTING
*                      project_definition    = <lfs_proj>-project
*                      set_system_status     = lc_clsd
*                    IMPORTING
*                      return                = lwa_return2
*                    TABLES
*                      e_result              = lt_result3
*                    EXCEPTIONS
*                      system_failure        = 1
*                      communication_failure = 2.
*
*                  IF sy-subrc = 0  AND lwa_return2-type <> lc_e.
**
***  Marking list of Project closed to send emails
*                    lv_receiver1 = <lfs_proj>-email.
*                    DATA(lv_attach) = abap_false.
*                    DATA(lv_cc) = abap_false.
*                    lv_template = 'ZA2R_POCLOSE'.
*
*                    CALL METHOD sendmail
*                      EXPORTING
*                        im_receiver    = lv_receiver1
*                        im_projprofl   = lv_profl
*                        im_attach_flg  = lv_attach
*                        im_cc_flg      = lv_cc
*                        im_wbs         = <lfs_proj>-wbs
*                        it_doareceiver = lt_mail
*                        iv_template    = lv_template
*                        im_sender      = im_sendr.
*                    ##SUBRC_OK
*                    IF sy-subrc = 0.
*                      CALL FUNCTION 'BAPI_PS_PRECOMMIT' DESTINATION 'NONE'
*                        EXCEPTIONS
*                          system_failure        = 1
*                          communication_failure = 2.
*                      IF  sy-subrc = 0.
*                        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION 'NONE'
*                          EXPORTING
*                            wait                  = lc_x
*                          EXCEPTIONS
*                            system_failure        = 1
*                            communication_failure = 2.
*                        CLEAR: lv_receiver1 .
*                        IF sy-subrc = 0.
*                          MESSAGE s002(za2r_projnotify) WITH <lfs_proj>-project.
*                        ENDIF.
*                      ELSE.
*                        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*                        MESSAGE e003(za2r_projnotify) WITH <lfs_proj>-project.
*                      ENDIF.
*                      CLEAR : lt_wbs_clsd, lwa_return, lt_result.
*                    ENDIF.
*                  ENDIF.
*                ENDIF.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*          CLEAR : lt_wbs_clsd, lwa_return, lt_result.
*        ENDAT.
*      ENDLOOP.
*    ENDIF.
*  ENDMETHOD.
*
*ENDCLASS.
*
*-------------------------
*ZA2R_R_SEND_NOTIFICATIONS_SEL
*
**&---------------------------------------------------------------------*
**& Include          ZA2R_R_SEND_NOTIFICATIONS_SEL
**&---------------------------------------------------------------------*
** PROGRAM ID          : ZA2R_R_SEND_NOTIFICATIONS_SEL
** DESCRIPTION         : The objective of this program is to send notifications on
**                       30th and 5th day on before the planned capitalization date
**
** AUTHOR              : SH311655/AK311653
** CREATE DATE         : 08/28/2024
** Transport Request   : FSDK901013
** Initial Change Req# :
**
** VERSION CONTROL
**
** Date        Name       Change Req#   Description of change    Issue#
**======================================================================
*
*SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
*  PARAMETERS: p_date TYPE datum DEFAULT sy-datum.
*SELECTION-SCREEN END OF BLOCK b1.
*
*--------------------------------------
*
*FUNCTION GROUP - ZA2R_FG_PROJ_CLSD
*
*FUNCTION - ZA2R_FM_PROJ_CLSD_VIA_EVENT
*
*FUNCTION za2r_fm_proj_clsd_via_event
*  IMPORTING
*    VALUE(sender) TYPE sibflporb
*    VALUE(event) TYPE sibfevent
*    VALUE(rectype) TYPE swferectyp
*    VALUE(handler) TYPE sibflporb
*    VALUE(exceptions_allowed) TYPE sweflags-exc_ok DEFAULT space
*    VALUE(xml_size) TYPE swf_xmlsiz
*    VALUE(event_container) TYPE swf_xmlcnt
*  EXPORTING
*    VALUE(result) TYPE swfrevrslt
*  EXCEPTIONS
*    read_failed
*    create_failed.
*
*
*
**----------------------------------------------------------------------*
** Written By   : SH311655
** Date         : 31/10/2024
** TR           : FSDK902248
** Ticket Number:
** RICEFW ID    : E016
** Description  : Project Closure : To update auto close date of the WBS elements of project
*************************************************************************
** Amendments:
**Version|Chg.Date |User id     |Ticket number and brief of change
**----------------------------------------------------------------------*
**      |          |            |
**----------------------------------------------------------------------*
*
*  DATA: lv_xstring TYPE xstring,
*        lt_tab     TYPE TABLE OF smum_xmltb,
*        lwa_tab    TYPE smum_xmltb,
*        lt_return  TYPE STANDARD TABLE OF bapiret2,
*        lv_project TYPE char255,
*        lv_proj_id TYPE ps_pspid,
*        lv_return  TYPE bapiret2.
*  CONSTANTS : lc_swo TYPE char255 VALUE 'SWO_TYPEID'.
*
*  "Concatenate xml data in internal table event_container into xstring
*  CONCATENATE LINES OF event_container INTO lv_xstring IN BYTE MODE.
*
*  "parse the xstring and get that into internal table
*  CALL FUNCTION 'SMUM_XML_PARSE'
*    EXPORTING
*      xml_input = lv_xstring
*    TABLES
*      xml_table = lt_tab
*      return    = lt_return.
*
*  "get the change document number
*  READ TABLE lt_tab INTO lwa_tab WITH KEY cname = lc_swo.
*  SPLIT lwa_tab-cvalue AT space INTO lv_proj_id lv_project.
*
*  "To update auto close date for all WBS elements of Project
*  za2r_cl_project_closure=>set_auto_close_date(
*  EXPORTING
*    im_proj_id = lv_proj_id
*   IMPORTING
*     ex_return = lv_return
*     ).
*
*ENDFUNCTION.
*
*
*-------------------------
*CLASS - ZA2R_CL_PROJECT_CLOSURE
*
*class ZA2R_CL_PROJECT_CLOSURE definition
*  public
*  final
*  create public .
*
*public section.
*
*  class-methods SET_AUTO_CLOSE_DATE
*    importing
*      value(IM_PROJ_ID) type PS_PSPID
*    exporting
*      !EX_RETURN type BAPIRET2 .
*protected section.
*private section.
*ENDCLASS.
*
*
*
*CLASS ZA2R_CL_PROJECT_CLOSURE IMPLEMENTATION.
*
*
*  METHOD set_auto_close_date.
*
*    DATA : lv_date        TYPE datum,
*           lv_days        TYPE psen_duration,
*           lv_autoclose   TYPE datum,
*           lv_project_def TYPE bapi_bus2001_new-project_definition,
*           lt_wbs_chg     TYPE TABLE OF bapi_bus2054_chg,
*           lt_wbs_upd     TYPE TABLE OF bapi_bus2054_upd,
*           lwa_wbs_chg    TYPE  bapi_bus2054_chg,
*           lwa_wbs_upd    TYPE  bapi_bus2054_upd,
*           lt_return2     TYPE TABLE OF bapiret2,
*           lv_msg2        TYPE  bapi_status_result-message_text.
*
*    CONSTANTS : lc_plus TYPE adsub VALUE '+',
*                lc_s    TYPE c VALUE 'S',
*                lc_x    TYPE c VALUE 'X'.
*
*
*    lv_date = sy-datum.   "current date
*    lv_days-durmm = '6'.  "6 months
*
** To caluclate auto close date which is 6 months later the current date
*
*    CALL FUNCTION 'HR_99S_DATE_ADD_SUB_DURATION'
*      EXPORTING
*        im_date     = lv_date
*        im_operator = lc_plus
*        im_duration = lv_days
*      IMPORTING
*        ex_date     = lv_autoclose.
*    ##FM_SUBRC_OK
*    IF sy-subrc = 0.
*
**to get the list of WBS element for given project
*      SELECT WBSElement
*         FROM i_wbselement
*         WHERE project = @im_proj_id
*         AND ismarkedfordeletion <> 'X'
*          INTO TABLE @DATA(lt_wbs).
*
*      IF sy-subrc = 0.
*        CALL FUNCTION 'BAPI_PS_INITIALIZATION'.
*
** Filling the BAPI structure data
*        lv_project_def = im_proj_id.
*        LOOP AT lt_wbs ASSIGNING FIELD-SYMBOL(<lfs_wbs>).
*
*          lwa_wbs_chg-wbs_element = <lfs_wbs>-wbselement.
*          lwa_wbs_chg-user_field_date1 = lv_autoclose.
*          APPEND lwa_wbs_chg TO lt_wbs_chg.
*
*          lwa_wbs_upd-wbs_element = <lfs_wbs>-wbselement.
*          lwa_wbs_upd-user_field_date1 = lc_x.
*          APPEND lwa_wbs_upd TO lt_wbs_upd.
*
*          CLEAR : lwa_wbs_upd, lwa_wbs_chg.
*
*        ENDLOOP.
*
** Updating auto close date for all WBS element
*
*        CALL FUNCTION 'BAPI_BUS2054_CHANGE_MULTI'
*          EXPORTING
*            i_project_definition  = lv_project_def
*          TABLES
*            it_wbs_element        = lt_wbs_chg
*            it_update_wbs_element = lt_wbs_upd
*            et_return             = lt_return2.
*        ##FM_SUBRC_OK
*        IF sy-subrc = 0.
*
** Pre commit once WBS element change is successful
*          CALL FUNCTION 'BAPI_PS_PRECOMMIT'.
*          DELETE lt_return2 WHERE type <> lc_s.
*          IF lt_return2 IS NOT INITIAL.
*            READ TABLE lt_return2 ASSIGNING FIELD-SYMBOL(<lfs_return2>) INDEX 1.
*            IF sy-subrc = 0.
*              CONCATENATE TEXT-001  lv_autoclose TEXT-002 lv_project_def
*              INTO ex_return-message SEPARATED BY space.
*              ex_return-type = <lfs_return2>-type.
*              ex_return-id = <lfs_return2>-id.
*            ENDIF.
*          ENDIF.
*        ELSE.
*
**  Rollback if WBS element change is failed
*          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
*          READ TABLE lt_return2 ASSIGNING <lfs_return2> INDEX 1.
*          IF sy-subrc = 0.
*            CONCATENATE TEXT-003 lv_project_def
*            INTO ex_return-message SEPARATED BY space.
*            ex_return-type = <lfs_return2>-type.
*            ex_return-id = <lfs_return2>-id.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*  ENDMETHOD.
*ENDCLASS.
*
*----
*
*------------------------------
*DOMAINS
*
*ZZPONUM - char12
*ZZPOSTATUS - char20
*ZZWONUM - char12
*ZZWOSTATUS - char16
*
*---------------------------
*DATABASE TABLE
*
*@EndUserText.label : 'Datasphere PO Status'
*@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
*@AbapCatalog.tableCategory : #TRANSPARENT
*@AbapCatalog.deliveryClass : #A
*@AbapCatalog.dataMaintenance : #ALLOWED
*define table za2r_a_postatus {
*
*  key mandt      : abap.clnt not null;
*  key wbs        : zza2r_wbs not null;
*  key costcenter : kostl not null;
*  key wonum      : zzwonum not null;
*  key po_num     : zzponum not null;
*  wostatus       : zzwostatus;
*  po_status      : zzpostatus;
*
*}
*
*-----------------------
*DATA ELEMENTS
*
*ZZA2R_WBS - char24
*ZZPONUM -ZZPONUM  - char12
*ZZPOSTATUS- ZZPOSTATUS - char20
*ZZWONUM- ZZWONUM - char12
*ZZWOSTATUS - char16
*
*------------------------------
*FITT:A2R:I082- API Call to DS,E016 & E065- Proj close notify
*
*Below managed behaviour is only used for EML statements
*
*@AccessControl.authorizationCheck: #NOT_REQUIRED
*@EndUserText.label: 'WBS Po Status'
*@Metadata.allowExtensions: true
*define root view entity ZA2R_WBS_PO
*  as select from za2r_a_postatus
*{
*  key wbs,
*  key costcenter,
*  key wonum,
*  key po_num,
*      wostatus,
*      po_status
*}
*
*---------------------------------
*
*managed implementation in class zbp_a2r_wbs_po unique;
*strict ( 2 );
*
*define behavior for ZA2R_WBS_PO //alias <alias_name>
*persistent table za2r_a_postatus
*lock master
*authorization master ( instance )
*//etag master <field_name>
*{
*  create;
*  update;
*  delete;
*
*}
*
*----------------------------------
*
*CLASS lhc_za2r_wbs_po DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR za2r_wbs_po RESULT result.
*
*ENDCLASS.
*
*CLASS lhc_za2r_wbs_po IMPLEMENTATION.
*
*  METHOD get_instance_authorizations.
*  ENDMETHOD.
*
*ENDCLASS.
*
*---------------------------------------
*FITT:A2R:I082- API Call to DS,E016 & E065- Proj close notify
*
*
*@AccessControl.authorizationCheck: #NOT_REQUIRED
*@EndUserText.label: 'WBS Status'
*define root view entity ZA2R_WBS_STATUS
*
*  as select from P_ObjectStatus   as _wbs
*    inner join   I_WBSElementData as _prps on _prps.WBSElementInternalID = _wbs.WBSElementInternalID
*{
*  key _prps.WBSElementExternalID,
*      cast(_wbs.WBSElementInternalID as abap.char(8)) as WBS,
*      _prps.WBSDescription
*
*}
*where
*  _wbs.Status = 'I0045'
*//Get PO with TECO status only.
*
*-----------------------------------------------
*
*@EndUserText.label: 'WBS Status'
*define service ZA2R_API_WBS_STATUS {
*  expose ZA2R_WBS_STATUS;
*}
*
*
*---------------------------------------------
*
*@EndUserText.label: 'WBS Po Status Custom Entity'
*define custom entity ZA2R_I_WBS_PO
*{
*  key Fileid     : abap.char(30);
*  key wbs        : abap.char(24);
*  key costcenter : kostl;
*  key wonum      : zzwonum;
*  key po_num     : zzponum;
*      wostatus   : zzwostatus;
*      po_status  : zzpostatus;
*      _file      : association to parent ZA2R_I_WBS_PO_FILE on _file.Fileid = $projection.Fileid;
*}
*
*---------------------------------------------
*
*@EndUserText.label: 'WBS Po Status File'
*define root custom entity ZA2R_I_WBS_PO_FILE
*{
*  key Fileid : abap.char(10);
*
*      _wbspo : composition [1..*] of ZA2R_I_WBS_PO;
*
*}
*
*----------------------------------
*
*@EndUserText.label: 'WBS Po Status Custom Entity'
*define custom entity ZA2R_I_WBS_PO
*{
*  key Fileid     : abap.char(30);
*  key wbs        : abap.char(24);
*  key costcenter : kostl;
*  key wonum      : zzwonum;
*  key po_num     : zzponum;
*      wostatus   : zzwostatus;
*      po_status  : zzpostatus;
*      _file      : association to parent ZA2R_I_WBS_PO_FILE on _file.Fileid = $projection.Fileid;
*}
*
*----------------
*
*BEHAVIOUR DEF
*
*unmanaged implementation in class zbp_a2r_i_wbs_po_file unique;
*strict ( 2 );
*
*define behavior for ZA2R_I_WBS_PO_FILE
*lock master
*authorization master ( instance )
*{
*  create;
*  update;
*  delete;
*  field ( readonly ) Fileid;
*  association _wbspo { create; }
*}
*
*define behavior for ZA2R_I_WBS_PO
*lock dependent by _file
*authorization dependent by _file
*//etag master <field_name>
*{
*  create;
*  update;
*  delete;
*  field ( readonly ) Fileid;
*  association _file;
*}
*----------------------------
*
*behaviour impl
*
*CLASS lhc_za2r_i_wbs_po_file DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR za2r_i_wbs_po_file RESULT result.
*
*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE za2r_i_wbs_po_file.
*
*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE za2r_i_wbs_po_file.
*
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE za2r_i_wbs_po_file.
*
*    METHODS read FOR READ
*      IMPORTING keys FOR READ za2r_i_wbs_po_file RESULT result.
*
*    METHODS lock FOR LOCK
*      IMPORTING keys FOR LOCK za2r_i_wbs_po_file.
*
*    METHODS rba_wbspo FOR READ
*      IMPORTING keys_rba FOR READ za2r_i_wbs_po_file\_wbspo FULL result_requested RESULT result LINK association_links.
*
*    METHODS cba_wbspo FOR MODIFY
*      IMPORTING entities_cba FOR CREATE za2r_i_wbs_po_file\_wbspo.
*
*ENDCLASS.
*
*CLASS lhc_za2r_i_wbs_po_file IMPLEMENTATION.
*
*  METHOD get_instance_authorizations.
*  ENDMETHOD.
*
*  METHOD create.
*  ENDMETHOD.
*
*  METHOD update.
*  ENDMETHOD.
*
*  METHOD delete.
*  ENDMETHOD.
*
*  METHOD read.
*  ENDMETHOD.
*
*  METHOD lock.
*  ENDMETHOD.
*
*  METHOD rba_wbspo.
*  ENDMETHOD.
*
*  METHOD cba_wbspo.
*    DATA : lt_create TYPE TABLE FOR CREATE za2r_wbs_po,
*           lt_wbs_po TYPE TABLE FOR CREATE za2r_i_wbs_po,
*           lt_delete TYPE TABLE FOR DELETE za2r_wbs_po.
*
** Start of comment for defect FITT-15332
**    ""Get All record form Custom table and delete it before updating new PO status.
**    SELECT * FROM  za2r_wbs_po INTO CORRESPONDING FIELDS OF TABLE @lt_delete.
**    IF lt_delete IS NOT INITIAL.
**      MODIFY ENTITIES OF za2r_wbs_po ENTITY za2r_wbs_po DELETE FROM lt_delete.
**    ENDIF.
** End of comment for defect FITT-15332
*
*    "Fetch line items into internal table
*    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<fs_wbs_po>).
*      APPEND LINES OF <fs_wbs_po>-%target TO lt_wbs_po.
*    ENDLOOP.
*
*    ""Fill = WBS and PO details for create new data
*    LOOP AT lt_wbs_po ASSIGNING FIELD-SYMBOL(<fs_create>).
*      INSERT VALUE #(
*                       wbs          = <fs_create>-wbs
*                       costcenter   = <fs_create>-costcenter
*                       wonum        = <fs_create>-wonum
*                       po_num       = <fs_create>-po_num
*                       wostatus     = <fs_create>-wostatus
*                       po_status    = <fs_create>-po_status
*                       ) INTO TABLE lt_create.
*    ENDLOOP.
*
** Start of changes for defect FITT-15332
** Get data from custom table for the records received in the request
*    IF lt_create IS NOT INITIAL.
*      SELECT *
*      FROM za2r_wbs_po
*      INTO CORRESPONDING FIELDS OF TABLE @lt_delete
*      FOR ALL ENTRIES IN @lt_create
*      WHERE wbs = @lt_create-wbs
*      AND costcenter = @lt_create-costcenter
*      AND wonum = @lt_create-wonum
*      AND po_num = @lt_create-po_num.
*      IF sy-subrc = 0.
*        "Delete data from custom table received in the request
*        MODIFY ENTITIES OF za2r_wbs_po ENTITY za2r_wbs_po DELETE FROM lt_delete.
*      ENDIF.
*    ENDIF.
** End of changes for defect FITT-15332
*
*    ""Update WBS Po details into Custom table
*    MODIFY ENTITIES OF za2r_wbs_po ENTITY za2r_wbs_po CREATE AUTO FILL CID WITH
*      VALUE #( FOR lwa_insert IN lt_create (
*                                       %key                 = lwa_insert-%key
*                                       wbs                  = lwa_insert-wbs
*                                       costcenter           = lwa_insert-costcenter
*                                       wonum                = lwa_insert-wonum
*                                       po_num               = lwa_insert-po_num
*                                       wostatus             = lwa_insert-wostatus
*                                       po_status            = lwa_insert-po_status
*                                       %control-wbs         = if_abap_behv=>mk-on
*                                       %control-costcenter  = if_abap_behv=>mk-on
*                                       %control-wonum      = if_abap_behv=>mk-on
*                                       %control-po_num      = if_abap_behv=>mk-on
*                                       %control-po_status   = if_abap_behv=>mk-on
*                                       %control-wostatus   = if_abap_behv=>mk-on ) )
*                                       MAPPED DATA(lt_mapping)
*                                       REPORTED DATA(lt_reorted)
*                                       FAILED DATA(lt_failed).
*
*    IF lt_reorted IS INITIAL.
*      "If Exp.category details are created in custom table,display success message
*      DATA(lt_createmsg) = new_message_with_text(
*       severity  = if_abap_behv_message=>severity-information
*       text      = TEXT-001 )
*                   .
*      INSERT VALUE #( %msg = lt_createmsg
*                    ) INTO TABLE reported-za2r_i_wbs_po_file.
*    ELSE.
*      ""Send error message
*      LOOP AT lt_reorted-za2r_wbs_po INTO DATA(ls_report).
*        APPEND VALUE #( fileid = ls_report-%cid
*                              %create = if_abap_behv=>mk-on
*                              %msg = ls_report-%msg ) TO reported-za2r_i_wbs_po_file.
*
*      ENDLOOP.
*    ENDIF.
*
*
*  ENDMETHOD.
*
*ENDCLASS.
*
*CLASS lhc_za2r_i_wbs_po DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE za2r_i_wbs_po.
*
*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE za2r_i_wbs_po.
*
*    METHODS read FOR READ
*      IMPORTING keys FOR READ za2r_i_wbs_po RESULT result.
*
*    METHODS rba_file FOR READ
*      IMPORTING keys_rba FOR READ za2r_i_wbs_po\_file FULL result_requested RESULT result LINK association_links.
*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE za2r_i_wbs_po.
*
*ENDCLASS.
*
*CLASS lhc_za2r_i_wbs_po IMPLEMENTATION.
*
*  METHOD update.
*  ENDMETHOD.
*
*  METHOD delete.
*  ENDMETHOD.
*
*  METHOD read.
*  ENDMETHOD.
*
*  METHOD rba_file.
*  ENDMETHOD.
*
*  METHOD create.
*  ENDMETHOD.
*
*ENDCLASS.
*
*CLASS lsc_za2r_i_wbs_po_file DEFINITION INHERITING FROM cl_abap_behavior_saver.
*  PROTECTED SECTION.
*
*    METHODS finalize REDEFINITION.
*
*    METHODS check_before_save REDEFINITION.
*
*    METHODS save REDEFINITION.
*
*    METHODS cleanup REDEFINITION.
*
*    METHODS cleanup_finalize REDEFINITION.
*
*ENDCLASS.
*
*CLASS lsc_za2r_i_wbs_po_file IMPLEMENTATION.
*
*  METHOD finalize.
*  ENDMETHOD.
*
*  METHOD check_before_save.
*  ENDMETHOD.
*
*  METHOD save.
*  ENDMETHOD.
*
*  METHOD cleanup.
*  ENDMETHOD.
*
*  METHOD cleanup_finalize.
*  ENDMETHOD.
*
*ENDCLASS.
*-----------------------------------
*
*
*ZA2R_API_WBS_PO
*
*@EndUserText.label: 'WBS PO Status'
*define service ZA2R_API_WBS_PO {
*  expose ZA2R_I_WBS_PO_FILE;
*  expose ZA2R_I_WBS_PO;
*}
*
*----------------------------
*
*@AbapCatalog.viewEnhancementCategory: [#NONE]
*@AccessControl.authorizationCheck: #NOT_REQUIRED
*@EndUserText.label: 'Project and WBS Notification'
*@Metadata.ignorePropagatedAnnotations: true
*@ObjectModel.usageType:{
*    serviceQuality: #X,
*    sizeCategory: #S,
*    dataClass: #MIXED
*}
*define view entity za2r_i_projnotify
*  as select from    I_WBSElement      as prps
*    left outer join ania              as ania     on ania.objnr = prps.WBSElementObject
*    left outer join I_ACMObjectStatus as jest     on jest.StatusObject = prps.WBSElementObject
*    left outer join I_ProjectData     as proj     on proj.ProjectExternalID = prps.Project
*    left outer join tcj04             as usr21    on usr21.vernr = proj.ResponsiblePerson
*    left outer join P_USER_ADDR_EMAIL as email    on usr21.s_usrnam = email.bname
*    left outer join za2r_a_postatus   as postatus on postatus.wbs = prps.WBSElement
*
*{
*  key prps.WBSElement                    as pspnr,
*      prps.WBSElementObject              as objnr,
*      prps.WBSIsAccountAssignmentElement as accasg,
*      case
*      when jest.StatusCode        = 'I0045'
*      then
*      prps.FreeDefinedDate1
*      end                                as usr08,
*      case
*      when jest.StatusCode        = 'I0045'
*      then
*      cast(
*      concat(
*      concat(
*      concat(substring(prps.FreeDefinedDate1, 7, 2), '/'),
*      concat(substring(prps.FreeDefinedDate1, 5, 2), '/')
*      ),
*      substring(prps.FreeDefinedDate1, 1, 4)
*      )
*      as char10 preserving type)
*      end                                as ZCONVERTED_usr08,
*      prps.InvestmentProfile             as imprf,
*      jest.StatusCode                    as stat,
*      proj.Project                       as pspid,
*      proj.ProjectDescription            as post1,
*      proj.ProjectProfileCode            as profl,
*      usr21.s_usrnam                     as personresponsible,
*      email.bname                        as bname,
*      email.smtp_addr                    as email,
*      case
*      when jest.StatusCode        = 'I0002'
*      then
*      ania.aktiv
*      end                                as aktiv,
*      case
*      when jest.StatusCode        = 'I0002'
*      then
*      cast(
*      concat(
*      concat(
*      concat(substring(ania.aktiv, 7, 2), '/'),
*      concat(substring(ania.aktiv, 5, 2), '/')
*      ),
*      substring(ania.aktiv, 1, 4)
*      )
*      as char10 preserving type)
*      end                                as ZCONVERTED_aktiv,
*      case
*      when jest.StatusCode        = 'I0002'
*      then
*      case
*      when  prps.InvestmentProfile = 'Z00001'    then 'C'
*       when  prps.InvestmentProfile = 'Z00002'    then 'C'
*        when  prps.InvestmentProfile = 'Z00003'    then 'C'
*        end
*      end                                as InvestProf,
*      case
*      when prps.FreeDefinedDate1 is not initial
*         then
*           case
*             when postatus.wbs is initial then 'X'
*             when postatus.wbs is not initial then 'O'
*           end
*      end                                as close_stat
*}
*where
*  //  (
*  //       prps.InvestmentProfile = 'Z00001'
*  //    or prps.InvestmentProfile = 'Z00002'
*  //    or prps.InvestmentProfile = 'Z00003'
*  //  )
*  //  and
*  (
*       jest.StatusCode       = 'I0002'
*    or jest.StatusCode       = 'I0045'
*  )
*  and  jest.StatusIsInactive = ''
*
*
*-------------------------------------------
*
*@AccessControl.authorizationCheck: #NOT_REQUIRED
*@EndUserText.label: 'Interface view for PO STATUS Display'
*@Metadata.ignorePropagatedAnnotations: true
*@ObjectModel.usageType.serviceQuality: #X
*@ObjectModel.usageType.sizeCategory: #S
*@ObjectModel.usageType.dataClass: #MIXED
*@Metadata.allowExtensions: true
*define root view entity ZA2R_I_PO_STATUS as select from za2r_a_postatus
*{
*    key wbs as Wbs,
*    key costcenter as Costcenter,
*    key wonum as Wonum,
*    key po_num as PoNum,
*    wostatus as Wostatus,
*    po_status as PoStatus
*}
*
*---------------------------------------
*
*@AccessControl.authorizationCheck: #NOT_REQUIRED
*@EndUserText.label: 'Projection view for PO STATUS Display'
*@Metadata.ignorePropagatedAnnotations: true
*@ObjectModel.usageType.serviceQuality: #X
*@ObjectModel.usageType.sizeCategory: #S
*@ObjectModel.usageType.dataClass: #MIXED
*@Metadata.allowExtensions: true
*define root view entity ZA2R_C_PO_STATUS
*provider contract transactional_query
*as projection on ZA2R_I_PO_STATUS
*{
*    key Wbs,
*    key Costcenter,
*    key Wonum,
*    key PoNum,
*    Wostatus,
*    PoStatus
*}
*
*--------------------------
*
*@Metadata.layer: #CORE
*@UI: {
*  headerInfo: {
*    typeName: 'PO Status',
*    typeNamePlural: 'PO Status'
*  }
*}
*annotate view ZA2R_C_PO_STATUS
*    with
*{
*     @UI.facet: [ {
*  id: 'idIdentification',
*  type: #IDENTIFICATION_REFERENCE,
*  label: 'PO Status',
*  position: 10
*  } ]
*  @UI.lineItem: [ {
*    position: 10 ,
*    importance: #MEDIUM,
*    label: ''
*  } ]
*  @UI.identification: [ {
*    position: 10 ,
*    label: ''
*  } ]
*  Wbs;
*  @UI.lineItem: [ {
*    position: 20 ,
*    importance: #MEDIUM,
*    label: ''
*  } ]
*  @UI.identification: [ {
*    position: 20 ,
*    label: ''
*  } ]
*  Costcenter;
*  @UI.lineItem: [ {
*    position: 30 ,
*    importance: #MEDIUM,
*    label: ''
*  } ]
*  @UI.identification: [ {
*    position: 30 ,
*    label: ''
*  } ]
*  Wonum;
*  @UI.lineItem: [ {
*   position: 40 ,
*   importance: #MEDIUM,
*   label: ''
*  } ]
*  @UI.identification: [ {
*    position: 40 ,
*    label: ''
*  } ]
*  Wostatus;
*  @UI.lineItem: [ {
*   position: 50 ,
*   importance: #MEDIUM,
*   label: ''
*  } ]
*  @UI.identification: [ {
*    position: 50 ,
*    label: ''
*  } ]
*  PoNum;
*  @UI.lineItem: [ {
*   position: 60 ,
*   importance: #MEDIUM,
*   label: ''
*  } ]
*  @UI.identification: [ {
*    position: 60 ,
*    label: ''
*  } ]
*  PoStatus;
*
*}
*
*------------------------------------
*
*managed implementation in class zbp_a2r_i_po_status unique;
*strict ( 2 );
*
*define behavior for ZA2R_I_PO_STATUS //alias <alias_name>
*persistent table za2r_a_postatus
*lock master
*authorization master ( instance )
*//etag master <field_name>
*{
*  create;
*  update;
*  delete;
*  mapping for za2r_a_postatus
*    {
*      Costcenter = costcenter;
*      PoNum      = po_num;
*      PoStatus   = po_status;
*      Wbs        = wbs;
*      Wonum      = wonum;
*      Wostatus   = wostatus;
*    }
*}
*
*-------------------------------
*
*projection;
*strict ( 2 );
*
*define behavior for ZA2R_C_PO_STATUS //alias <alias_name>
*{
*//  use create;
*//  use update;
*//  use delete;
*}
*
*--------------------------------
*
*CLASS lhc_ZA2R_I_PO_STATUS DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR za2r_i_po_status RESULT result.
*
*ENDCLASS.
*
*CLASS lhc_ZA2R_I_PO_STATUS IMPLEMENTATION.
*
*  METHOD get_instance_authorizations.
*  ENDMETHOD.
*
*ENDCLASS.
*
*---------------------------------
*
*@EndUserText.label: 'Service definition for PO STATUS'
*define service ZA2R_UI_PO_STATUS {
*  expose ZA2R_C_PO_STATUS;
*}
*--------------------------------
*
*ZA2R_API_WBS_PO_O2
*ZA2R_UI_PO_STATUS_O2
*ZA2R_WBS_STATUS_02
*
*-----------------------------
*
*Extended Standard BO for TECO event
*ZBUS2001.TECO
*  ENDMETHOD.
*
*
*-----------------------------
*Email Templated
*
*ZA2R_181DAYPOCLOSE
*ZA2R_30DAYCAPNOTIFY
*ZA2R_30DAYPOCLOSE
*ZA2R_31DAYCAPNOTIFY
*ZA2R_5DAYCAPNOTIFY
*ZA2R_5DAYPOCLOSE
*ZA2R_POCLOSE
*------------------------------
*
*ZA2R_181DAYPOCLOSE
*Name                 1 day after auto close date
*CDS View             ZA2R_I_PROJNOTIFY
*
*---------------------------------
*Email Subject        {{pspnr}}: Missed Close PO notification
*Body HTML
*
*<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
*    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
*
*<html xmlns="http://www.w3.org/1999/xhtml">
*<head>
*  <meta content="HTML Tidy for SAP R/3 (vers 25 March 2009), see www.w3.org" name="generator" />
*
*  <title></title>
*</head>
*
*<body>
*<p>Dear Business User, </p>
*
*<p>Project:  {{pspid}}, Description: {{post1}}, WBS Element: {{pspnr}}, is slated to automatically close on date: {{ZCONVERTED_usr08}} </p>
*
*<p>The above Project/WBS did not close since assigned PO(s) have not been closed.<br>
*Please work with the person responsible for the project to close out the PO.</p>
*
*<p>Thanks for your Attention!</p>
*<p>Best Regards!</p>
*
*
*<p><b>***** This is an Auto-generated mail. Please do not respond back to this email. *****</b></p>
*
*</body>
*</html>
*
*-----------------------------------
*Body Plain TEXT
*
*Dear Business User,
*
*Project:  {{pspid}}, Description: {{post1}}, WBS Element: {{pspnr}}, is slated to automatically close on date: {{ZCONVERTED_usr08}}
*
*The above Project/WBS did not close since assigned PO(s) have not been closed.
*Please work with the person responsible for the project to close out the PO.
*
*Thanks for your Attention!
*Best Regards!
****** This is an Auto-generated mail. Please do not respond back to this email. *****
*
*-----------------------------------------
*
*subject - {{pspnr}}: 30-Day left from Planned Capitalization Date
*
*BOdy HTML
*
*<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
*    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
*
*<html xmlns="http://www.w3.org/1999/xhtml">
*<head>
*  <meta content="HTML Tidy for SAP R/3 (vers 25 March 2009), see www.w3.org" name="generator" />
*
*  <title></title>
*</head>
*
*<body>
*<p>Dear Business User, </p>
*
*<p>Project:  {{pspid}}, Description: {{post1}}, WBS Element: {{pspnr}}, Planned Capitalization Date: {{ZCONVERTED_aktiv}} </p>
*
*<p>Please review the Project/WBS elements and complete/update the fields that will be used to create the final asset record for capitalizing the project costs. <br>
*If the project is ready to be place in service – initiate TECO Project Approval Workflow.<br>
*Otherwise, please update the planned capitalization date of the WBS Element.</p>
*
*<p>Thanks for your Attention!</p>
*<p>Best Regards!</p>
*
*
*<p><b>***** This is an Auto-generated mail. Please do not respond back to this email. *****</b></p>
*
*</body>
*</html>

enDMETHOD.
ENDCLASS.
