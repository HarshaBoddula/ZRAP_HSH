CLASS zbi_cl_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
    CLASS-METHODS:
      calculate_days_to_Flight
        IMPORTING is_orginal_Data TYPE zc_birap_atrav
        RETURNING VALUE(result)   TYPE zc_birap_Atrav.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZBI_CL_CALC IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    IF it_requested_calc_elements IS INITIAL.
      EXIT.
    ENDIF.

    DATA lt_travel_orginal_Data TYPE STANDARD TABLE OF zc_birap_atrav WITH DEFAULT KEY.
    lt_travel_orginal_Data = CORRESPONDING #( it_original_data ).
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_req_calc_elements>).


      CASE <fs_req_calc_elements>.
        WHEN 'TRAVELDAYS'.
*          DATA lt_travel_orginal_Data TYPE STANDARD TABLE OF zc_birap_atrav WITH DEFAULT KEY.
*          lt_travel_orginal_Data = CORRESPONDING #( it_original_data ).

          LOOP AT lt_travel_orginal_data ASSIGNING FIELD-SYMBOL(<fs_travel_orginal_Data>).
                    <fs_travel_orginal_data> = zbi_cl_calc=>calculate_days_to_flight( is_orginal_data = <fs_travel_orginal_data> ).
          ENDLOOP.
          ct_calculated_data = CORRESPONDING #( lt_travel_orginal_data ).

        whEN 'CREATIONDATE'.
*          lt_travel_orginal_Data = CORRESPONDING #( it_original_data ).

          LOOP AT lt_travel_orginal_data ASSIGNING FIELD-SYMBOL(<fs_travel_orginal_Data1>).
                    <fs_travel_orginal_Data1>-CreationDate = substring(
                                                               val   = CONV STRING( <fs_travel_orginal_Data1>-CreatedAt )
*                                                               sub   =
*                                                               regex =
*                                                               pcre  =
*                                                               occ   =
                                                               off   = 0
                                                               len   = 8
*                                                               case  =
                                                             ).
*                    <fs_travel_orginal_data1> = zbi_cl_calc=>calculate_days_to_flight( is_orginal_data = <fs_travel_orginal_data> ).
          ENDLOOP.
          ct_calculated_data = CORRESPONDING #( lt_travel_orginal_data ).

          whEN 'STATUS'.
*          lt_travel_orginal_Data = CORRESPONDING #( it_original_data ).

          LOOP AT lt_travel_orginal_data ASSIGNING FIELD-SYMBOL(<fs_travel_orginal_Data2>).
                    <fs_travel_orginal_Data2>-Status = coND #( WHEN <fs_travel_orginal_Data2>-CreationDate = cl_abap_context_info=>get_system_date( )
                                                        thEN 'TODAY'
                                                        when cl_abap_context_info=>get_system_date( ) - <fs_travel_orginal_Data2>-CreationDate <= 10
                                                        tHEN 'WITHIN10D'
                                                        whEN cl_abap_context_info=>get_system_date( ) - <fs_travel_orginal_Data2>-CreationDate > 10
                                                        then 'OLDER' ).

*                    <fs_travel_orginal_data1> = zbi_cl_calc=>calculate_days_to_flight( is_orginal_data = <fs_travel_orginal_data> ).
          ENDLOOP.
          ct_calculated_data = CORRESPONDING #( lt_travel_orginal_data ).

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    IF iv_entity = 'ZC_BIRAP_ATRAV'.
      LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_booking_Calc_element>).
        CASE <fs_booking_calc_element>.
          WHEN 'TRAVELDAYS'.
            COLLECT CONV string( 'BEGINDATE' ) INTO et_requested_orig_elements.
            COLLECT CONV string( 'ENDDATE' ) INTO et_requested_orig_elements.
        ENDCASE.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD calculate_days_to_flight.
    daTa: days type zc_birap_atrav-traveldays.
    result = corrESPONDING #( is_orginal_data ).

    if result-BeginDate is not inITIAL and result-enddate is nOT iNITIAL.
        days = result-EndDate - result-BeginDate.

        result-traveldays = days.
        else.
        result-traveldays = 0.
    endif.
  ENDMETHOD.
ENDCLASS.
