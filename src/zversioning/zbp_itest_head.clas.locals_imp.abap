CLASS lsc_zi_itest_head DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_itest_head IMPLEMENTATION.

  METHOD save_modified.

  DATA:
*        ls_upd    TYPE STRUCTURE FOR UPDATE zi_itest_item,
        lv_max_v2 TYPE ztest_itms-version,
        lv_minor  TYPE string,
        lv_next   TYPE i VALUE 0,
        lv_newver TYPE ztest_itms-version,
        lv_uuid   TYPE sysuuid_x16,
        ls_itm type ztest_itms,
        lt_itm type STANDARD TABLE OF ztest_itms.

  "Process UPDATED items from the request
  LOOP AT update-zi_itest_item INTO data(ls_upd1).

*    "Only version V1 should create history row, and V1 must remain unchanged
*    IF ls_upd-version <> 'V1'.
*      CONTINUE.
*    ENDIF.
    select single * from
        ztest_itms
        where itemuuid = @ls_upd1-itemuuid
        inTO @data(ls_upd).

    "Find current max V2.* for same HEADID + QUARTER (or use ITEMID if that’s your grouping)
    CLEAR lv_max_v2.
    SELECT MAX( version )
      FROM ztest_itms
      WHERE headid  = @ls_upd-headid
        AND quarter = @ls_upd-quarter
        AND version LIKE 'V2.%'
      INTO @lv_max_v2.

    if sy-subrc = 0.
        "Only version V1 should create history row, and V1 must remain unchanged
    IF ls_upd-version <> 'V1'.
      CONTINUE.
    ENDIF.
    endif.

    lv_next = 0.
    IF lv_max_v2 IS NOT INITIAL.
      SPLIT lv_max_v2 AT '.' INTO DATA(lv_v2txt) lv_minor.
      lv_next = lv_minor.
    ENDIF.
    lv_next = lv_next + 1.
    lv_newver = |V2.{ lv_next }|.

    "New UUID for the new version row
    lv_uuid = cl_system_uuid=>create_uuid_x16_static( ).

    ls_itm = VALUE #(
      client   = sy-mandt
      itemuuid = lv_uuid
      headid   = ls_upd-headid
      itemid   = ls_upd-itemid
      quarter  = ls_upd-quarter
      version  = lv_newver
      amount   = ls_upd1-amount
      waers    = ls_upd1-waers
    ).
*    append ls_itm to lt_itm.
    "INSERT snapshot row (V2.x) using edited values
    inSERT ztest_itms frOM @ls_itm.
*    INSERT ztest_itms FROM VALUE #(
*      client   = sy-mandt
*      itemuuid = lv_uuid
*      headid   = ls_upd-headid
*      itemid   = ls_upd-itemid
*      quarter  = ls_upd-quarter
*      version  = lv_newver
*      amount   = ls_upd-amount
*      waers    = ls_upd-waers
*    ).

    "IMPORTANT: do NOT UPDATE the original V1 row -> it remains unchanged

  ENDLOOP.

ENDMETHOD.

*METHOD save_modified.
*
*  DATA:
**        ls_upd     TYPE STRUCTURE FOR UPDATE zi_itest_item,
*        ls_db      TYPE ztest_itms,
*        ls_new     TYPE ztest_itms,
*        lv_uuid    TYPE sysuuid_x16,
*        lv_max_v2  TYPE ztest_itms-version,
*        lv_minor   TYPE string,
*        lv_next    TYPE i,
*        lv_newver  TYPE ztest_itms-version.
*
*  LOOP AT update-zi_itest_item INTO data(ls_upd).
*
*    "Only if user edited V1
*    IF ls_upd-version <> 'V1'.
*      CONTINUE.
*    ENDIF.
*
*    "---------------------------------------
*    "1) Read full base row from DB using ITEMUUID
*    "   (draft-aware: read from draft table if needed)
*    "---------------------------------------
*    CLEAR ls_db.
*
*    IF ls_upd-%is_draft = abap_true.
*      SELECT SINGLE *
*        FROM ztest_itms_d
*        WHERE itemuuid = @ls_upd-itemuuid
*        INTO CORRESPONDING FIELDS OF @ls_db.
*      "If not found in draft, fallback to active
*      IF sy-subrc <> 0.
*        SELECT SINGLE *
*          FROM ztest_itms
*          WHERE itemuuid = @ls_upd-itemuuid
*          INTO @ls_db.
*      ENDIF.
*    ELSE.
*      SELECT SINGLE *
*        FROM ztest_itms
*        WHERE itemuuid = @ls_upd-itemuuid
*        INTO @ls_db.
*    ENDIF.
*
*    IF sy-subrc <> 0.
*      CONTINUE.
*    ENDIF.
*
*    "Base snapshot row = DB row (so headid/itemid/quarter always present)
*    ls_new = ls_db.
*
*    "---------------------------------------
*    "2) Overlay ONLY changed fields using %control
*    "---------------------------------------
*    IF ls_upd-%control-amount = if_abap_behv=>mk-on.
*      ls_new-amount = ls_upd-amount.
*    ENDIF.
*
*    IF ls_upd-%control-waers = if_abap_behv=>mk-on.
*      ls_new-waers = ls_upd-waers.
*    ENDIF.
*
*    "Add any other editable fields same way...
*
*    "---------------------------------------
*    "3) Next version V2.x for same headid+quarter
*    "---------------------------------------
*    CLEAR lv_max_v2.
*    SELECT MAX( version )
*      FROM ztest_itms
*      WHERE headid  = @ls_db-headid
*        AND quarter = @ls_db-quarter
*        AND version LIKE 'V2.%'
*      INTO @lv_max_v2.
*
*    lv_next = 0.
*    IF lv_max_v2 IS NOT INITIAL.
*      SPLIT lv_max_v2 AT '.' INTO DATA(lv_v2txt) lv_minor.
*      lv_next = lv_minor.
*    ENDIF.
*    lv_next = lv_next + 1.
*    lv_newver = |V2.{ lv_next }|.
*
*    "---------------------------------------
*    "4) Insert new version row with new UUID
*    "---------------------------------------
*    lv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
*
*    ls_new-client   = sy-mandt.
*    ls_new-itemuuid = lv_uuid.
*    ls_new-version  = lv_newver.
*
**    IF ls_upd-%is_draft = abap_true.
**      "Insert into draft table so it appears immediately in Edit mode
**      INSERT ztest_itms_d FROM CORRESPONDING #( ls_new ).
**    ELSE.
*      "Insert into active table
*      INSERT ztest_itms FROM @ls_new.
**    ENDIF.
*
*    "V1 remains unchanged because we never UPDATE it.
*
*  ENDLOOP.
*
*ENDMETHOD.

*METHOD save_modified.
*
*  DATA:
**        ls_upd     TYPE STRUCTURE FOR UPDATE zi_itest_item,
*        ls_db      TYPE ztest_itms,
*        ls_new     TYPE ztest_itms,
*        lv_max_v2  TYPE ztest_itms-version,
*        lv_minor   TYPE string,
*        lv_next    TYPE i,
*        lv_newver  TYPE ztest_itms-version,
*        lv_uuid    TYPE sysuuid_x16.
*
*
*  LOOP AT update-zi_itest_item INTO data(ls_upd).
*
*    "Only V1 edits should create history
*    IF ls_upd-version <> 'V1'.
*      CONTINUE.
*    ENDIF.
*
*    "1) Read full current V1 row from DB using key (itemuuid)
*    CLEAR ls_db.
*    SELECT SINGLE *
*      FROM ztest_itms
*      WHERE itemuuid = @ls_upd-itemuuid
*      INTO @ls_db.
*
*    IF sy-subrc <> 0.
*      CONTINUE.
*    ENDIF.
*
*    "2) Base snapshot row = DB row (this ensures headid/itemid/quarter are NOT missing)
*    ls_new = ls_db.
*
*    "3) Overlay ONLY the changed fields using %control [1](https://abappractice.blogspot.com/2025/08/mandatory-fields-and-validations-in-rap.html)[2](https://myoffice.accenture.com/personal/mohammad_a_yusuf_accenture_com/Documents/Microsoft%20Teams%20Cha
*"t%20Files/TransactionalAppsRAP.pdf)
*    IF ls_upd-%control-amount = if_abap_behv=>mk-on.
*      ls_new-amount = ls_upd-amount.
*    ENDIF.
*
*    IF ls_upd-%control-waers = if_abap_behv=>mk-on.
*      ls_new-waers = ls_upd-waers.
*    ENDIF.
*
*    "Add other editable fields here using same pattern:
*    "IF ls_upd-%control-<field> = if_abap_behv=>mk-on.
*    "  ls_new-<field> = ls_upd-<field>.
*    "ENDIF.
*
*    "4) Determine next V2.x for same headid+quarter
*    CLEAR lv_max_v2.
*    SELECT MAX( version )
*      FROM ztest_itms
*      WHERE headid  = @ls_db-headid
*        AND quarter = @ls_db-quarter
*        AND version LIKE 'V2.%'
*      INTO @lv_max_v2.
*
*    lv_next = 0.
*    IF lv_max_v2 IS NOT INITIAL.
*      SPLIT lv_max_v2 AT '.' INTO DATA(lv_v2txt) lv_minor.
*      lv_next = lv_minor.
*    ENDIF.
*    lv_next = lv_next + 1.
*    lv_newver = |V2.{ lv_next }|.
*
*    "5) Insert new history row (new UUID, new version)
*    lv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
*
*    ls_new-client   = sy-mandt.
*    ls_new-itemuuid = lv_uuid.
*    ls_new-version  = lv_newver.
*
*    INSERT ztest_itms FROM @ls_new.
*
*    "IMPORTANT: Do NOT UPDATE original V1 row -> remains unchanged
*
*  ENDLOOP.
*
*ENDMETHOD.

ENDCLASS.

CLASS lhc_zi_itest_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS set_item_ids FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_itest_item~set_item_ids.

ENDCLASS.

CLASS lhc_zi_itest_item IMPLEMENTATION.

  METHOD set_item_ids.

  "-----------------------------------------
  "Declarations
  "-----------------------------------------
  DATA:
*        lt_items      TYPE STANDARD TABLE OF zi_itest_item,
*        ls_item       TYPE zi_itest_item,
        lt_update     TYPE TABLE FOR UPDATE zi_itest_item.
*        DATA(lt_update[ 1 ]) = VALUE LINE OF lt_update( ).
*        insert iniTIAL LINE INTO lt_update at index 1.

*        data: lt_update[ 1 ]     TYPE strcture FOR UPDATE zi_itest_item.

  DATA: lv_uuid       TYPE sysuuid_x16,
        lv_max_active TYPE ztest_itms-itemid,
        lv_max_draft  TYPE ztest_itms-itemid,
        lv_max        TYPE ztest_itms-itemid,
        lv_next       TYPE i VALUE 0,
        lv_itemid     TYPE ztest_itms-itemid.

  "-----------------------------------------
  "Read newly created items from buffer
  "-----------------------------------------
  READ ENTITIES OF zi_itest_head IN LOCAL MODE
    ENTITY zi_itest_item
    FIELDS ( itemuuid itemid headid )
    WITH CORRESPONDING #( keys )
    RESULT data(lt_items).

  LOOP AT lt_items INTO data(ls_item).

    "-------------------------------------
    "1) Generate ITEMUUID if initial
    "-------------------------------------
    IF ls_item-itemuuid IS INITIAL.
      lv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
    ELSE.
      lv_uuid = ls_item-itemuuid.
    ENDIF.

    "-------------------------------------
    "2) Get MAX ITEMID per HEADID
    "-------------------------------------
    CLEAR: lv_max_active, lv_max_draft, lv_max, lv_next.

    SELECT MAX( itemid )
      FROM ztest_itms
      WHERE headid = @ls_item-headid
      INTO @lv_max_active.

    SELECT MAX( itemid )
      FROM ztest_itms_d
      WHERE headid = @ls_item-headid
      INTO @lv_max_draft.

    lv_max = lv_max_active.
    IF lv_max_draft > lv_max.
      lv_max = lv_max_draft.
    ENDIF.

    IF lv_max IS NOT INITIAL.
      lv_next = lv_max.
    ENDIF.

    lv_next = lv_next + 1.

    IF lv_next > 9999.
      CONTINUE. "optional error handling
    ENDIF.

    lv_itemid = |{ lv_next WIDTH = 4 ALIGN = RIGHT PAD = '0' }|.

    "-------------------------------------
    "3) Update transactional buffer
    "-------------------------------------
*    CLEAR lt_update[ 1 ].
*    lt_update[ 1 ]-%tky = ls_item-itemid.
    appEND INITIAL LINE TO lt_update.
    lt_update[ 1 ]-itemuuid = lv_uuid.
    lt_update[ 1 ]-itemid   = lv_itemid.
    lt_update[ 1 ]-%control-itemuuid = if_abap_behv=>mk-on.
    lt_update[ 1 ]-%control-itemid   = if_abap_behv=>mk-on.

*    APPEND lt_update[ 1 ] TO lt_update.

  ENDLOOP.

  IF lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF zi_itest_head IN LOCAL MODE
      ENTITY zi_itest_item
      UPDATE FIELDS ( itemuuid itemid )
      WITH lt_update
      FAILED   DATA(failed)
      REPORTED DATA(reported1).
  ENDIF.

ENDMETHOD.

ENDCLASS.

CLASS lhc_zi_itest_head DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_itest_head RESULT result.

*    METHODS earlynumbering_create FOR NUMBERING
*      IMPORTING entities FOR CREATE zi_itest_head.

    METHODS create_default_items FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_itest_head~create_default_items.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_itest_head.

    METHODS earlynumbering_cba_item FOR NUMBERING
      IMPORTING entities FOR CREATE zi_itest_head\_item.

ENDCLASS.

CLASS lhc_zi_itest_head IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.



  METHOD create_default_items.

  DATA lt_create_items TYPE TABLE FOR CREATE zi_itest_head\_item.

*  LOOP AT keys INTO DATA(ls_key).
*
*    lt_create_items = VALUE #(
*      (
*        %is_draft = abap_true
*        %target   = VALUE #(
*          ( quarter = 'Q1' version = 'V1' %is_draft = abap_true )
*          ( quarter = 'Q2' version = 'V1' %is_draft = abap_true )
*          ( quarter = 'Q3' version = 'V1' %is_draft = abap_true )
*          ( quarter = 'Q4' version = 'V1' %is_draft = abap_true )
*        )
*      )
*    ).
*
*    MODIFY ENTITIES OF zi_itest_head IN LOCAL MODE
*      ENTITY zi_itest_head
*      CREATE BY \_item
*      AUTO FILL CID
*      wiTH lt_create_items
*      FAILED   DATA(failed)
*      REPORTED DATA(reported1)
*      MAPPED   DATA(mapped).
*
*  ENDLOOP.

ENDMETHOD.

  METHOD earlynumbering_create.
    "---- 1) Determine current MAX from active + draft
    SELECT MAX( headid ) FROM ztest_head   INTO @DATA(lv_max_active).

SELECT MAX( headid ) FROM ztest_head_d INTO @DATA(lv_max_draft).

    "Assumption: headid is NUMC4/CHAR4 containing digits with leading zeros
    DATA(lv_max) = lv_max_active.
    IF lv_max_draft > lv_max.
      lv_max = lv_max_draft.
    ENDIF.

    DATA: lv_next_int TYPE i.
    IF lv_max IS INITIAL.
      lv_next_int = 0.
    ELSE.
      lv_next_int = CONV i( lv_max ).  "e.g. '0042' -> 42
    ENDIF.


"---- 2) Assign numbers for each create request row
    LOOP AT entities INTO DATA(ls_entity).

      "If consumer already sent headid, accept it (optional)
      IF ls_entity-headid IS NOT INITIAL.
        "Make sure %key contains the key
        ls_entity-%key-headid = ls_entity-headid.

        APPEND VALUE #( %cid      = ls_entity-%cid
                        %key      = ls_entity-%key
                        %is_draft = ls_entity-%is_draft ) TO mapped-zi_itest_head.
        CONTINUE.
      ENDIF.

      lv_next_int += 1.


"Overflow protection for 4 digits
      IF lv_next_int > 9999.
        "Report + fail this row
        APPEND VALUE #( %cid      = ls_entity-%cid
                        %key      = ls_entity-%key
                        %is_draft = ls_entity-%is_draft
                        %msg      = new_message(
                                      id       = 'ZMSG'          "your msg class
                                      number   = '001'           "e.g. 'No more IDs'
                                      severity = if_abap_behv_message=>severity-error
                                      v1       = 'headid range exhausted (9999)'
                                    ) ) TO reported-zi_itest_head.

        APPEND VALUE #( %cid      = ls_entity-%cid
                        %key      = ls_entity-%key
                        %is_draft = ls_entity-%is_draft ) TO failed-zi_itest_head.
        CONTINUE.
      ENDIF.

"Format to 4 digits with leading zeros: 1 -> '0001'
*    DATA: lv_new_headid TYPE numc4.
*lv_new_headid = |{ lv_next_int ALPHA = IN }|.
    DATA(lv_new_headid) = |{ lv_next_int WIDTH = 4 ALIGN = RIGHT PAD = '0' }|.
*      DATA(lv_new_headid) = |{ lv_next_int WIDTH = 4 PAD = '0' }|.

      "Fill the key for mapping
      ls_entity-%key-headid = lv_new_headid.

      APPEND VALUE #( %cid      = ls_entity-%cid
                      %key      = ls_entity-%key
                      %is_draft = ls_entity-%is_draft ) TO mapped-zi_itest_head.

    ENDLOOP.


  ENDMETHOD.

  METHOD earlynumbering_cba_item.

  "Counter per HEADID so multiple target lines get sequential itemid
  TYPES: BEGIN OF ty_cnt,
           headid   TYPE ztest_head-headid,
           next_int TYPE i,
         END OF ty_cnt.
  DATA lt_cnt TYPE soRTED TABLE OF  ty_cnt WITH UNIQUE KEY headid.

  "-------------------------
  "1) Initialize counter per headid (MAX from active + draft)
  "-------------------------
  LOOP AT entities INTO DATA(ls_ent).

    "In CBA derived type, parent key fields are usually available directly
    "If headid is not filled here, you cannot generate per-head sequence
    IF ls_ent-headid IS INITIAL.
      CONTINUE.
    ENDIF.

    READ TABLE lt_cnt WITH TABLE KEY headid = ls_ent-headid TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.

      SELECT MAX( itemid )
        FROM ztest_itms
        WHERE headid = @ls_ent-headid
        INTO @DATA(lv_max_active).

      SELECT MAX( itemid )
        FROM ztest_itms_d
        WHERE headid = @ls_ent-headid
        INTO @DATA(lv_max_draft).

      DATA(lv_max) = lv_max_active.
      IF lv_max_draft > lv_max.
        lv_max = lv_max_draft.
      ENDIF.

      DATA: lv_next TYPE i VALUE 0.
      IF lv_max IS NOT INITIAL.
        lv_next = CONV i( lv_max ).  "e.g. '0003' -> 3
      ENDIF.

      INSERT VALUE ty_cnt( headid = ls_ent-headid next_int = lv_next )
        INTO TABLE lt_cnt.

    ENDIF.

  ENDLOOP.

  "-------------------------
  "2) Assign itemuuid + itemid for EACH target row
  "-------------------------
  LOOP AT entities INTO ls_ent.

    IF ls_ent-headid IS INITIAL.
      "Report error for each target line (needs %cid from target!) [1](https://engage.cloud.microsoft/main/threads/eyJfdHlwZSI6IlRocmVhZCIsImlkIjoiNjY5NzM2NDkwIn0)
      LOOP AT ls_ent-%target INTO DATA(ls_tgt_err).
        INSERT VALUE #(
          %cid      = ls_tgt_err-%cid
          %is_draft = ls_tgt_err-%is_draft
          %msg      = new_message(
                        id       = 'ZMSG'
                        number   = '020'
                        severity = if_abap_behv_message=>severity-error
                        v1       = 'HEADID missing for item numbering'
                      )
        ) INTO TABLE reported-zi_itest_item.

        INSERT VALUE #(
          %cid      = ls_tgt_err-%cid
          %is_draft = ls_tgt_err-%is_draft
        ) INTO TABLE failed-zi_itest_item.
      ENDLOOP.
      CONTINUE.
    ENDIF.

    READ TABLE lt_cnt WITH TABLE KEY headid = ls_ent-headid INTO DATA(ls_cnt).
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    LOOP AT ls_ent-%target INTO DATA(ls_tgt).

      "Generate UUID if not supplied
      DATA: lv_uuid TYPE sysuuid_x16.
      IF ls_tgt-itemuuid IS INITIAL.
        lv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      ELSE.
        lv_uuid = ls_tgt-itemuuid.
      ENDIF.

      "Generate itemid if not supplied
      DATA :lv_itemid TYPE ztest_itms-itemid.
      IF ls_tgt-itemid IS INITIAL.
        ls_cnt-next_int += 1.

        IF ls_cnt-next_int > 9999.
          INSERT VALUE #(
            %cid      = ls_tgt-%cid
            %is_draft = ls_tgt-%is_draft
            %msg      = new_message(
                          id       = 'ZMSG'
                          number   = '021'
                          severity = if_abap_behv_message=>severity-error
                          v1       = 'ITEMID range exhausted (9999)'
                        )
          ) INTO TABLE reported-zi_itest_item.

          INSERT VALUE #(
            %cid      = ls_tgt-%cid
            %is_draft = ls_tgt-%is_draft
          ) INTO TABLE failed-zi_itest_item.

          CONTINUE.
        ENDIF.

        lv_itemid = |{ ls_cnt-next_int WIDTH = 4 ALIGN = RIGHT PAD = '0' }|.
      ELSE.
        lv_itemid = ls_tgt-itemid.
      ENDIF.

      "Return mapping: %cid (child) -> %key (child)
      "Assuming itemuuid is the key field of item entity
      INSERT VALUE #(
        %cid      = ls_tgt-%cid
        %is_draft = ls_tgt-%is_draft
        %key      = VALUE #( itemuuid = lv_uuid )
      ) INTO TABLE mapped-zi_itest_item.

      "If you also want to push itemid into instance data:
      "Do NOT try to write to entities here; set it via a determination on create/update instead.
      "OR make itemid part of key if you truly want FOR NUMBERING to own it.

    ENDLOOP.

*    data:
*
*    "update counter back
*          "Create entries into DOA table using lt_create
*      MODIFY ENTITIES OF zi_itest_head in LOCAL MODE
*                     ENTITY zi_itest_head
*                     CREATE  AUTO FILL CID WITH VALUE #(  FOR lwa_insert IN lt_create (
*                                                          %key = lwa_insert-%key
*                                                           userid = lwa_insert-userid
*                                                           useremail = lwa_insert-useremail
*                                                           managerid = lwa_insert-managerid
*                                                           manageremail = lwa_insert-manageremail
*                                                           currency = lwa_insert-currency
*                                                           companycode = lwa_insert-companycode
*                                                           updateddate = sy-datum
*                                                           updatedby = sy-uname
*                                                           amount = lwa_insert-amount
*                                                           expcategoryid = lwa_insert-expcategoryid
*                                                           %control-userid = if_abap_behv=>mk-on
*                                                           %control-useremail = if_abap_behv=>mk-on
*                                                           %control-managerid = if_abap_behv=>mk-on
*                                                           %control-manageremail = if_abap_behv=>mk-on
*                                                           %control-currency = if_abap_behv=>mk-on
*                                                           %control-companycode = if_abap_behv=>mk-on
*                                                           %control-updateddate = if_abap_behv=>mk-on
*                                                           %control-updatedby = if_abap_behv=>mk-on
*                                                            %control-expcategoryid = if_abap_behv=>mk-on
*                                                             %control-amount = if_abap_behv=>mk-on
*                                                            ) )
*
*                     MAPPED DATA(lt_mapped_status)
*                     REPORTED DATA(lt_reported_status)
*                     FAILED DATA(lt_failed_status).
*    MODIFY lt_cnt FROM ls_cnt.

  ENDLOOP.

ENDMETHOD.

*  METHOD earlynumbering_cba_item.
*
*  "We keep a counter per HEADID (so multiple items in same request get 0001,0002,...)
*  TYPES: BEGIN OF ty_cnt,
*           headid    TYPE ztest_head-headid,
*           next_int  TYPE i,
*         END OF ty_cnt.
*  DATA lt_cnt TYPE HASHED TABLE OF ty_cnt WITH UNIQUE KEY headid.
*
*  "-------------------------------
*  "1) Prepare start counter per headid (MAX from active + draft)
*  "-------------------------------
*  LOOP AT entities INTO DATA(ls_ent).
*
*    IF ls_ent-headid IS INITIAL.
*      "Without headid we cannot create itemid sequence
*      INSERT VALUE #(
*        %cid      = ls_ent-%cid_ref
*        %is_draft = ls_ent-%is_draft
*        %msg      = new_message(
*                      id       = 'ZMSG'
*                      number   = '020'
*                      severity = if_abap_behv_message=>severity-error
*                      v1       = 'HEADID missing for item numbering'
*                    )
*      ) INTO TABLE reported-zi_itest_item.
*
*      INSERT VALUE #(
*        %cid      = ls_ent-%cid_ref
*        %is_draft = ls_ent-%is_draft
*      ) INTO TABLE failed-zi_itest_item.
*
*      CONTINUE.
*    ENDIF.
*
*    READ TABLE lt_cnt WITH TABLE KEY headid = ls_ent-headid TRANSPORTING NO FIELDS.
*    IF sy-subrc <> 0.
*
*      "MAX(itemid) per headid from active + draft
*      SELECT MAX( itemid )
*        FROM ztest_itms
*        WHERE headid = @ls_ent-headid
*        INTO @DATA(lv_max_active).
*
*      SELECT MAX( itemid )
*        FROM ztest_itms_d
*        WHERE headid = @ls_ent-headid
*        INTO @DATA(lv_max_draft).
*
*      DATA(lv_max) = lv_max_active.
*      IF lv_max_draft > lv_max.
*        lv_max = lv_max_draft.
*      ENDIF.
*
*      DATA: lv_next TYPE i VALUE 0.
*      IF lv_max IS NOT INITIAL.
*        lv_next = CONV i( lv_max ).
*      ENDIF.
*
*      INSERT VALUE ty_cnt(
*        headid   = ls_ent-headid
*        next_int = lv_next
*      ) INTO TABLE lt_cnt.
*
*    ENDIF.
*
*  ENDLOOP.
*
*  "-------------------------------
*  "2) Assign ITEMUUID + ITEMID and fill mapped
*  "-------------------------------
*  LOOP AT entities INTO ls_ent.
*
*    "Skip already failed ones (optional)
*    IF ls_ent-headid IS INITIAL.
*      CONTINUE.
*    ENDIF.
*
*    READ TABLE lt_cnt WITH TABLE KEY headid = ls_ent-headid INTO DATA(ls_cnt).
*    IF sy-subrc <> 0.
*      CONTINUE.
*    ENDIF.
*
*    "Generate UUID key if initial
*    IF ls_ent-%target[ 1 ]-itemuuid IS INITIAL.
*      TRY.
*          ls_ent-%target[ 1 ]-itemuuid = cl_system_uuid=>create_uuid_x16_static( ).
*        CATCH cx_uuid_error.
*          "handle exception
*      ENDTRY.
*    ENDIF.
*
*    "Generate ITEMID if initial (NUMC4)
*    IF ls_ent-%target[ 1 ]-itemid IS INITIAL.
*      ls_cnt-next_int += 1.
*
*      IF ls_cnt-next_int > 9999.
*        INSERT VALUE #(
*          %cid      = ls_ent-%cid_ref
*          %is_draft = ls_ent-%is_draft
*          %msg      = new_message(
*                        id       = 'ZMSG'
*                        number   = '021'
*                        severity = if_abap_behv_message=>severity-error
*                        v1       = 'ITEMID range exhausted (9999)'
*                      )
*        ) INTO TABLE reported-zi_itest_item.
*
*        INSERT VALUE #(
*          %cid      = ls_ent-%cid_ref
*          %is_draft = ls_ent-%is_draft
*        ) INTO TABLE failed-zi_itest_item.
*
*        CONTINUE.
*      ENDIF.
*
*      ls_ent-%target[ 1 ]-itemid = |{ ls_cnt-next_int WIDTH = 4 ALIGN = RIGHT PAD = '0' }|.
**      MODIFY lt_cnt FROM ls_cnt.
*    ENDIF.
*
*    "Return mapping (key = ITEMUUID)
**    ls_ent-%target[ 1 ]-itemuuid =  ls_ent-itemuuid.
**    ls_ent-%key-itemuuid = ls_ent-itemuuid.
*
*    INSERT VALUE #(
*      %cid      = ls_ent-%cid_ref
*      %key      = ls_ent-%target[ 1 ]-%key
*      %is_draft = ls_ent-%is_draft
*    ) INTO TABLE mapped-zi_itest_item.
*
*  ENDLOOP.
*
*ENDMETHOD.

ENDCLASS.
