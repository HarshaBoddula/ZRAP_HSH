CLASS zbi_cl_eml1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS:
      is_draft  TYPE if_abap_behv=>t_xflag VALUE if_abap_behv=>mk-on, "draft = 01
      is_active TYPE if_abap_behv=>t_xflag VALUE if_abap_behv=>mk-off. "active = 00

    CLASS-DATA:
      travel_id      TYPE /dmo/travel_id, "travel id
      instance_state TYPE if_abap_behv=>t_xflag, "active or draft
      console_output TYPE REF TO if_oo_adt_classrun_out.

    METHODS:
      read_travel,
      update_travel,
      create_travel,
      delete_travel.

ENDCLASS.



CLASS ZBI_CL_EML1 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    "set console output instance
    console_output = out.

    "specify the operations to be excecuted
    DATA(execute) = 1.

    "Read a travel BO entity instance
    IF execute = 1.
      travel_id = '00000199'.
      instance_state = is_Active.
      read_travel(  ).
    ENDIF.

    IF execute = 2.
      travel_id = '00000199'.
      instance_state = is_Active.
      update_travel( ).
    ENDIF.

    IF execute = 3.
      instance_state = is_Active.
      create_travel( ).
    ENDIF.

    IF execute = 4.
      travel_id = '00000199'.
      instance_state = is_Active.
      delete_travel( ).
    ENDIF.

  ENDMETHOD.


  METHOD create_travel.
    "Create in the transactional buffer
    MODIFY ENTITIES OF zr_birap_atrav
        ENTITY ZrBirapAtrav
        CREATE FIELDS ( TravelID CustomerID AgencyID BeginDate EndDate Description )
        WITH VALUE #( (  %cid = 'create_travel'
        %is_draft = instance_state
        TravelID = '00000200'
        CustomerID = '10'
        AgencyID = '070019'
        BeginDate = cl_abap_context_info=>get_system_date(  )
        EndDate = cl_abap_context_info=>get_system_date(  ) + 10
        Description = | Created on { cl_abap_context_info=>get_system_time(  ) } |
        ) )
        MAPPED DATA(mapped)
        FAILED DATA(failed)
        REPORTED DATA(reported).

    "persist changes
    COMMIT ENTITIES
       RESPONSE OF zr_birap_atrav
       FAILED DATA(failed_commit)
       REPORTED DATA(reported_commit).

    "console output
    console_output->write(
      EXPORTING
        data   = mapped-zrbirapatrav
*         name   =
*       RECEIVING
*         output =
    ).

    IF failed IS NOT INITIAL.
      console_output->write( |- Cause for failed create: { failed-zrbirapatrav[ 1 ]-%fail-cause }| ).
    ELSEIF failed_commit IS NOT INITIAL.
      console_output->write( |- Cause for failed commit: { failed_commit-zrbirapatrav[ 1 ]-%fail-cause }| ).
    ENDIF.

  ENDMETHOD.


  METHOD delete_travel.

    "Delete in the transactional buffer
    MODIFY ENTITIES OF zr_birap_atrav
    ENTITY ZrBirapAtrav
    DELETE FROM VALUE #( ( TravelID = travel_id
                         %is_draft = instance_state ) )
    FAILED DATA(failed)
    REPORTED DATA(reported).

    "Commit Entities
    COMMIT ENTITIES
        RESPONSE OF zr_birap_atrav
        FAILED DATA(failed_commit)
        REPORTED DATA(reported_commit).

    "console output
    console_output->write( |- TravelID = { travel_id }| ).
    IF failed IS NOT INITIAL.
      console_output->write( |- Cause for failed delete: { failed-zrbirapatrav[ 1 ]-%fail-cause }| ).
    ELSEIF failed_commit IS NOT INITIAL.
      console_output->write( |- Cause for failed commit: { failed_commit-zrbirapatrav[ 1 ]-%fail-cause }| ).
    else.
        console_output->write( |Deleted Travel id| ).
    ENDIF.



  ENDMETHOD.


  METHOD read_travel.

    "declare internal table  using derived type
    DATA travels TYPE TABLE FOR READ IMPORT zr_birap_atrav.

    "fill the data for read request
    travels = VALUE #( ( TravelID = travel_id %is_draft = instance_state ) ).

    "read from transactional buffer
    READ ENTITIES OF zr_birap_atrav
        ENTITY ZrBirapAtrav
        ALL FIELDS
        WITH travels
    RESULT DATA(lt_travels_read)
    FAILED DATA(failed)
    REPORTED DATA(reported).

    "console output
    console_output->write( |- TravelID = { travel_id }| ).
    IF failed IS NOT INITIAL.
      console_output->write( |- Cause for failed read: { failed-zrbirapatrav[ 1 ]-%fail-cause }| ).
    else.
        console_output->write( lt_travels_read ).
    ENDIF.

  ENDMETHOD.


  METHOD update_travel.

    MODIFY ENTITIES OF zr_birap_atrav
      ENTITY ZrBirapAtrav
      UPDATE FIELDS ( Description )
      WITH VALUE #( ( %is_draft =  instance_state
                      TravelID = travel_id
                      Description = | Vacation { cl_abap_context_info=>get_system_time(  ) }| ) )
    FAILED DATA(failed)
    REPORTED DATA(reported).

    "Commit Entities
    COMMIT ENTITIES
        RESPONSE OF zr_birap_atrav
        FAILED DATA(failed_commit)
        REPORTED DATA(reported_commit).

    "console output
    console_output->write( |- TravelID = { travel_id }| ).
    IF failed IS NOT INITIAL.
      console_output->write( |- Cause for failed delete: { failed-zrbirapatrav[ 1 ]-%fail-cause }| ).
    ELSEIF failed_commit IS NOT INITIAL.
      console_output->write( |- Cause for failed commit: { failed_commit-zrbirapatrav[ 1 ]-%fail-cause }| ).
    else.
        console_output->write( |Updated Description in Travel id| ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
