CLASS lhc_ZTEST_LINE DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ztest_line RESULT result.


ENDCLASS.

CLASS lhc_ZTEST_LINE IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.


ENDCLASS.
