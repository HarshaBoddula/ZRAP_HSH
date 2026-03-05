CLASS lhc_zr_birap_atrav DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF travel_status,
        open     TYPE c LENGTH 1 VALUE 'O', "Open
        accepted TYPE c LENGTH 1 VALUE 'A', "accepted
        rejected TYPE c LENGTH 1 VALUE 'X', "rejected
      END OF travel_status.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrBirapAtrav
        RESULT result,
      setStatusToOpen FOR DETERMINE ON MODIFY
        IMPORTING keys FOR ZrBirapAtrav~setStatusToOpen,
      validateCustomer FOR VALIDATE ON SAVE
        IMPORTING keys FOR ZrBirapAtrav~validateCustomer.

    METHODS validateDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZrBirapAtrav~validateDate.
    METHODS deductDiscount FOR MODIFY
      IMPORTING keys FOR ACTION ZrBirapAtrav~deductDiscount RESULT result.
    METHODS copyTravel FOR MODIFY
      IMPORTING keys FOR ACTION ZrBirapAtrav~copyTravel.
    METHODS createTravel FOR MODIFY
      IMPORTING keys FOR ACTION ZrBirapAtrav~createTravel.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZrBirapAtrav RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION ZrBirapAtrav~acceptTravel RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION ZrBirapAtrav~rejectTravel RESULT result.
    METHODS CheckSideeffect FOR DETERMINE ON SAVE
      IMPORTING keys FOR ZrBirapAtrav~CheckSideeffect.
    METHODS defaultDiscount FOR MODIFY
      IMPORTING keys FOR ACTION ZrBirapAtrav~defaultDiscount RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE ZrBirapAtrav.
ENDCLASS.

CLASS lhc_zr_birap_atrav IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD setStatusToOpen.
    READ ENTITIES OF zr_birap_atrav IN LOCAL MODE
    ENTITY ZrBirapAtrav
    FIELDS ( OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels)
    FAILED DATA(read_failed).

    DELETE travels WHERE OverallStatus IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.

    MODIFY ENTITIES OF zr_birap_atrav IN LOCAL MODE
    ENTITY ZrBirapAtrav
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR travel IN travels ( %key = travel-%key
    OverallStatus = travel_status-open ) )
    REPORTED DATA(update_reported).

*    reported = CORRESPONDING #( DEEP update_reported ).
  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF zr_birap_atrav IN LOCAL MODE
      ENTITY ZrBirapAtrav
      FIELDS ( OverallStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels)
      FAILED DATA(read_failed).

    DATA: customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    "optimization of select: extract distinct non initial customer ids
    customers = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING customer_id = CustomerID EXCEPT * ).
    DELETE customers WHERE customer_id IS INITIAL.

    IF customers IS NOT INITIAL.

      "check if customer id exists
      SELECT FROM /dmo/customer FIELDS customer_id
                                FOR ALL ENTRIES IN @customers
                                WHERE customer_id = @customers-customer_id
                                INTO TABLE @DATA(valid_customers).

    ENDIF.
    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #( %tky = travel-%tky
      %state_area = 'VALIDATE_CUSTOMER' ) TO reported-zrbirapatrav.

      IF travel-CustomerID IS INITIAL OR not line_exists( valid_customers[ customer_id = travel-CustomerID ] ) .

        APPEND VALUE #( %tky = travel-%tky ) TO failed-zrbirapatrav.

        APPEND VALUE #( %tky = travel-%tky
        %state_area = 'VALIDATE_CUSTOMER'
        %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>customer_unkown
        customer_id  =  travel-CustomerID

        severity = if_abap_behv_message=>severity-error )
        %element-CustomerID = if_abap_behv=>mk-on ) TO reported-zrbirapatrav.

      ENDIF.



    ENDLOOP.


  ENDMETHOD.

  METHOD validateDate.

  READ ENTITIES OF zr_birap_atrav IN LOCAL MODE
      ENTITY ZrBirapAtrav
      FIELDS ( BeginDate EndDate TravelID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels)
      FAILED DATA(read_failed).

LOOP AT travels INTO DATA(travel).

      APPEND VALUE #( %tky = travel-%tky
      %state_area = 'VALIDATE_DATE' ) TO reported-zrbirapatrav.

      IF travel-BeginDate IS INITIAL OR travel-BeginDate < cl_Abap_context_info=>get_system_date( ).

        APPEND VALUE #( %tky = travel-%tky ) TO failed-zrbirapatrav.

        APPEND VALUE #( %tky = travel-%tky
        %state_area = 'VALIDATE_DATE'
        %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
        begin_date  =  travel-BeginDate

        severity = if_abap_behv_message=>severity-error )
        %element-BeginDate = if_abap_behv=>mk-on ) TO reported-zrbirapatrav.

      ENDIF.
      IF travel-EndDate IS INITIAL.

        APPEND VALUE #( %tky = travel-%tky ) TO failed-zrbirapatrav.

        APPEND VALUE #( %tky = travel-%tky
        %state_area = 'VALIDATE_DATE'
        %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>enter_end_date
        end_date  =  travel-EndDate

        severity = if_abap_behv_message=>severity-error )
        %element-EndDate = if_abap_behv=>mk-on ) TO reported-zrbirapatrav.

      ENDIF.
      IF travel-EndDate < travel-BeginDate.

        APPEND VALUE #( %tky = travel-%tky ) TO failed-zrbirapatrav.

        APPEND VALUE #( %tky = travel-%tky
        %state_area = 'VALIDATE_DATE'
        %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>begin_date_bef_end_date
        begin_date  =  travel-BeginDate
        end_date = travel-EndDate

        severity = if_abap_behv_message=>severity-error )
        %element-EndDate = if_abap_behv=>mk-on
        %element-BeginDate = if_abap_behv=>mk-on ) TO reported-zrbirapatrav.

      ENDIF.


    ENDLOOP.

  ENDMETHOD.

  METHOD deductDiscount.

  DATA: travels_for_update type taBLE FOR UPDATE zr_birap_atrav.

  data(keys_with_valid_discount) = keys.

  loop at keys_with_valid_discount asSIGNING fIELD-SYMBOL(<key_with_valid_discount>)
    wHERE %param-discount_percent is iNITIAL or %param-discount_percent > 100 or %param-discount_percent <= 0.

    "Invalid discount
    apPEND vaLUE #( %tky = <key_with_valid_discount>-%tky ) to failed-zrbirapatrav.

    APPEND VALUE #( %tky = <key_with_valid_discount>-%tky
        %msg = NEW /dmo/cm_flight_messages( textid = /dmo/cm_flight_messages=>discount_invalid
        severity = if_abap_behv_message=>severity-error )
        %element-TotalPrice = if_abap_behv=>mk-on
        %op-%action-deductDiscount = if_abap_behv=>mk-on ) TO reported-zrbirapatrav.

    delETE keys_with_valid_discount.

  eNDLOOP.

  cheCK keys_with_valid_discount is noT inITIAL.

  READ ENTITIES OF zr_birap_atrav IN LOCAL MODE
      ENTITY ZrBirapAtrav
      FIELDS ( BookingFee )
      WITH CORRESPONDING #( keys_with_valid_discount )
      RESULT DATA(travels)
      FAILED DATA(read_failed).

  loop at travels asSIGNING fIELD-SYMBOL(<travel>).

    data percentage tyPE decfloat16.
    data(discount_percentage) = keys_with_valid_discount[ key draft %tky = <travel>-%tky ]-%param-discount_percent.
    percentage = discount_percentage / 100.
    daTA(reduced_fee) = <travel>-BookingFee * ( 1 - percentage ).

    apPEND vaLUE #( %tky = <travel>-%tky
                    BookingFee = reduced_fee
                     ) to travels_for_update.

    moDIFY enTITIES OF zr_birap_atrav iN LOCAL MODE
    ENTITY ZrBirapAtrav
    upDATE fIELDS ( BookingFee )
    wiTH travels_for_update.

    READ ENTITIES OF zr_birap_atrav IN LOCAL MODE
      ENTITY ZrBirapAtrav
      all FIELDS
      WITH CORRESPONDING #( travels )
      RESULT DATA(travels_with_discount).

    result = vaLUE #( for travel in travels_with_discount ( %tky = travel-%tky
    %param = travel ) ).


  endLOOP.

  ENDMETHOD.

  METHOD copyTravel.

  daTA: travels tyPE taBLE FOR crEATE zr_birap_atrav.

  "remove travel instances with initial %cid (i.e., not set by caller API)
  reAD tABLE keys with KEY %cid = '' inTO data(key_with_initial_cid).
  assERT key_with_initial_cid is iNITIAL.

  READ ENTITIES OF zr_birap_atrav IN LOCAL MODE
      ENTITY ZrBirapAtrav
      alL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(travel_read_result)
      FAILED failed.

      loop at travel_read_result asSIGNING fIELD-SYMBOL(<travel>).

      "fill in travel container for creating new instance
      appEND vaLUE #( %cid = keys[ key entity %key = <travel>-%key ]-%cid
      %is_draft = keys[ key entity %key = <travel>-%key ]-%param-%is_draft
      %data = correspONDING #( <travel> exCEPT TravelID ) ) to Travels aSSIGNING fIELD-SYMBOL(<new_travel>).

      "adjust the copied travel instance
      "begindate must be on or after system date
      <new_travel>-BeginDate = cl_Abap_context_info=>get_system_date(  ).
      "End Date must be after begin date
      <new_travel>-EndDate = cl_Abap_context_info=>get_system_date(  ) + 30.
      "Overall status for new travel will be Open 'O'.
      <new_travel>-OverallStatus = travel_status-open.


      endLOOP.

      modiFY enTITIES OF zr_birap_atrav in loCAL MODE
      enTITY ZrBirapAtrav
      cREATE fIELDS ( AgencyID CustomerID BeginDate EndDate BookingFee
        TotalPrice CurrencyCode OverallStatus Description )
        with travels
        mapped data(mapped_create).

        mapped-zrbirapatrav = mapped_create-zrbirapatrav.

  ENDMETHOD.

  METHOD createTravel.

  if keys is not inITIAL.

  modify enTITIES OF zr_birap_atrav in loCAL MODE
  enTITY ZrBirapAtrav
      cREATE fIELDS ( AgencyID CustomerID BeginDate EndDate Description )
        with vaLUE #( for key in keys ( %cid = key-%cid
        %is_draft = key-%param-%is_draft
        CustomerID = key-%param-customer_id
        AgencyID = key-%param-Agency_id
        BeginDate = key-%param-Begin_date
        EndDate = key-%param-End_date
        Description = 'own create implementation'
         ) )
        mapped mapped.
  endif.

  ENDMETHOD.

  METHOD get_instance_features.

    read ENTITIES OF zr_birap_atrav in LOCAL MODE
    eNTITY ZrBirapAtrav
    fIELDS ( OverallStatus TravelID )
    wiTH correSPONDING #( keys )
    resULT data(travels)
    failed failed.

    result = value #( foR travel in travels
                            ( %tky = travel-%tky
                            %features-%update = conD #( when travel-OverallStatus = travel_status-accepted
                            then if_abap_behv=>fc-o-disabled else if_abap_behv=>fc-o-enabled )
                            %features-%delete = conD #( when travel-OverallStatus = travel_status-open
                            then if_abap_behv=>fc-o-enabled else if_abap_behv=>fc-o-disabled )
                            %action-Edit = conD #( when travel-OverallStatus = travel_status-accepted
                            then if_abap_behv=>fc-o-disabled else if_abap_behv=>fc-o-enabled )
                            %action-acceptTravel = conD #( when travel-OverallStatus = travel_status-accepted
                            then if_abap_behv=>fc-o-disabled else if_abap_behv=>fc-o-enabled )
                            %action-rejectTravel = conD #( when travel-OverallStatus = travel_status-rejected
                            then if_abap_behv=>fc-o-disabled else if_abap_behv=>fc-o-enabled )
                            %action-deductDiscount = conD #( when travel-OverallStatus = travel_status-open
                            then if_abap_behv=>fc-o-enabled else if_abap_behv=>fc-o-disabled )

                             ) ).

  ENDMETHOD.

  METHOD acceptTravel.

  moDIFY enTITIES OF zr_birap_atrav in loCAL MODE
    entity ZrBirapAtrav
    UPDATE fIELDS ( OverallStatus )
    wiTH vaLUE #( for key in keys ( %tky = key-%tky
    OverallStatus = travel_status-accepted ) )
    faILED failed
    REPORTED reported.

    reAD ENTITIES OF zr_birap_atrav iN LOCAL MODE
    enTITY ZrBirapAtrav
    aLL FIELDS WITH
    corrESPONDING #( keys )
    reSULT data(travels).

    result = value #( for travel in travels ( %tky = travel-%tky
    %param = travel ) ).

  ENDMETHOD.

  METHOD rejectTravel.

    moDIFY enTITIES OF zr_birap_atrav in loCAL MODE
    entity ZrBirapAtrav
    UPDATE fIELDS ( OverallStatus )
    wiTH vaLUE #( for key in keys ( %tky = key-%tky
    OverallStatus = travel_status-rejected ) )
    faILED failed
    REPORTED reported.

    reAD ENTITIES OF zr_birap_atrav iN LOCAL MODE
    enTITY ZrBirapAtrav
    aLL FIELDS WITH
    corrESPONDING #( keys )
    reSULT data(travels).

    result = value #( for travel in travels ( %tky = travel-%tky
    %param = travel ) ).

  ENDMETHOD.

  METHOD earlynumbering_create.

    data: entity tyPE strUCTURE FOR creATE zr_birap_atrav,
          travel_id_max type /dmo/travel_id,
          use_number_range type abap_bool value abap_true.

    looP AT entities inTO entity wHERE TravelID is not inITIAL.

        appEND corrESPONDING #( entity ) to mapped-zrbirapatrav.
    endLOOP.

    data(entities_wo_travelid) = entities.

    delete entities_wo_travelid wheRE TravelID is nOT inITIAL.

    if use_number_range = abap_true.

        try.
            cl_numberrange_runtime=>number_get(
              EXPORTING
*                ignore_buffer     =
                nr_range_nr       = '01'
                object            = '/DMO/TRV_M'
                quantity          = CONV #( LINES( entities_wo_travelid ) )
*                subobject         =
*                toyear            =
              IMPORTING
                number            = data(number_range_key)
                returncode        = data(number_range_return_code)
                returned_quantity = data(number_range_returned_quantity)
            ).
            CATCH cx_nr_object_not_found.
            CATCH cx_number_ranges inTO data(lx_number_ranges).
                loop AT entities_wo_travelid inTO entity.
                    append vaLUE #( %cid = entity-%cid
                    %key = entity-%key
                    %is_draft = entity-%is_draft
                    %msg = lx_number_ranges
                     ) to reported-zrbirapatrav.
                    append vaLUE #( %cid = entity-%cid
                    %key = entity-%key
                    %is_draft = entity-%is_draft
                     ) to failed-zrbirapatrav.
                endLOOP.
            exIT.
            enDTRY.

    travel_id_max = number_range_key - number_range_returned_quantity.

    else.
        select siNGLE frOM zbi_rap_atrav fiELDS max( travel_id ) as travelID inTO @travel_id_max.

        selECT siNGLE from zbirap_atrav_d fIELDS maX( travelid ) as travelID inTO @data(max_travelid_draft).
        if max_travelid_draft > travel_id_max.
            travel_id_max = max_travelid_draft.
        endIF.

    endif.

    loop at entities_wo_travelid inTO entity.
        travel_id_max += 1.
        entity-TravelID = travel_id_max.

        apPEND vaLUE #( %cid = entity-%cid
        %key = entity-%key
        %is_Draft = entity-%is_draft
         ) to mapped-zrbirapatrav.
    endloop.

  ENDMETHOD.

*  METHOD CheckSideeffect.
*
*  READ ENTITIES OF zr_birap_atrav IN LOCAL MODE
*    ENTITY ZrBirapAtrav
*    FIELDS ( BookingFee TotalPrice )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(travels)
*    FAILED DATA(read_failed).
*
**    DELETE travels WHERE OverallStatus IS NOT INITIAL.
*    CHECK travels IS NOT INITIAL.
*
*    MODIFY ENTITIES OF zr_birap_atrav IN LOCAL MODE
*    ENTITY ZrBirapAtrav
*    UPDATE FIELDS ( TotalPrice )
*    WITH VALUE #( FOR travel IN travels ( %key = travel-%key
*    TotalPrice = 100 ) )
*    REPORTED DATA(update_reported).
*
*    reported = CORRESPONDING #( DEEP update_reported ).
*
*  ENDMETHOD.

METHOD checksideeffect.

  "1. Read ONLY the fields involved in side effects
  READ ENTITIES OF zr_birap_atrav IN LOCAL MODE
    ENTITY zrbirapatrav
    FIELDS ( BookingFee TotalPrice )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

  CHECK travels IS NOT INITIAL.

  "2. Calculate new values and update ONLY if different
*  MODIFY ENTITIES OF zr_birap_atrav IN LOCAL MODE
*    ENTITY zrbirapatrav
*    UPDATE FIELDS ( TotalPrice )
*    WITH VALUE #( FOR travel IN travels ( %key = travel-%key
*    TotalPrice = travel-BookingFee * 2 ) )
*    REPORTED DATA(update_reported).

    travels[ 1 ]-TotalPrice = 123.

    MODIFY ENTITIES OF zr_birap_atrav IN LOCAL MODE
    ENTITY zrbirapatrav
         UPDATE FIELDS ( TotalPrice )
         WITH CORRESPONDING #( travels ).
*         rePORTED daTA(update_reported).

  "3. Pass reported changes back to framework
*  reported = CORRESPONDING #( DEEP update_reported ).

ENDMETHOD.

  METHOD defaultDiscount.
  DATA: travels_for_update type taBLE FOR UPDATE zr_birap_atrav.
  READ ENTITIES OF zr_birap_atrav IN LOCAL MODE
      ENTITY ZrBirapAtrav
      FIELDS ( BookingFee )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels)
      FAILED DATA(read_failed).

  loop at travels asSIGNING fIELD-SYMBOL(<travel>).

*    data percentage tyPE decfloat16.
*    data(discount_percentage) = keys_with_valid_discount[ key draft %tky = <travel>-%tky ]-%param-discount_percent.
*    percentage = discount_percentage / 100.
*    daTA(reduced_fee) = <travel>-BookingFee * ( 1 - percentage ).

    apPEND vaLUE #( %tky = <travel>-%tky
                    BookingFee = 100
                     ) to travels_for_update.

    moDIFY enTITIES OF zr_birap_atrav iN LOCAL MODE
    ENTITY ZrBirapAtrav
    upDATE fIELDS ( BookingFee )
    wiTH travels_for_update.

    READ ENTITIES OF zr_birap_atrav IN LOCAL MODE
      ENTITY ZrBirapAtrav
      all FIELDS
      WITH CORRESPONDING #( travels )
      RESULT DATA(travels_with_discount).

    result = vaLUE #( for travel in travels_with_discount ( %tky = travel-%tky
    %param = travel ) ).

    endLOOP.

  ENDMETHOD.

ENDCLASS.
