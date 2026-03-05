"! @testing BDEF:ZR_BIRAP_ATRAV
CLASS zbi_cl_aut1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC
for teSTING
risK LEVEL HARMLESS
dURATION sHORT.

  PUBLIC SECTION.
  PROTECTED SECTION.
  PRIVATE SECTION.
    clASS-DATA:
              cds_test_environment tYPE ref TO if_cds_test_environment,
              sql_test_environment tyPE REF TO if_osql_test_environment,
              begin_Date type /dmo/begin_Date,
              end_Date tyPE /dmo/end_date,
              agency_mock_Data tYPE stANDARD TABLE OF /dmo/agency,
              customer_mock_Data tYPE staNDARD TABLE OF /dmo/customer.

    clASS-mETHODS:
     class_setup, "setup test double framework
     class_teardown. "stop test doubles

    meTHODS:
        setup, "reset test doubles
        teardown. "rollback any changes

    meTHODS:
        "CUT: create with action call and commit
        create_with_Action for tesTING rAISING cx_static_Check.



ENDCLASS.



CLASS zbi_cl_aut1 IMPLEMENTATION.
  METHOD class_setup.
    "CREATE TEST DOUBLES FOR UNDERLYING CDS ENTITIES
    cds_test_environment = cl_cds_test_environment=>create_for_multiple_cds(
                        i_for_entities = vaLUE #( (
                            i_for_entity = 'ZR_BIRAP_ATRAV'
                            ) ) ).
    "CREATE TEST DOUBLES FOR ADDITIONAL USED TABLES
    sql_test_environment = cl_osql_test_environment=>create(
                i_dependency_list = vaLUE #( ( '/DMO/AGENCY' )
                                              ( '/DMO/CUSTOMER' ) )  ).

    "PREPARE THE TEST DATA
    begin_Date = cl_abap_context_info=>get_system_date(  ) + 10.
    end_date = cl_abap_context_info=>get_system_date(  ) + 30.

    agency_mock_Data = vaLUE #( ( agency_id = '070041' name = 'Agency 070041' ) ).
    customer_mock_Data = vaLUE #( ( customer_id = '000093' last_name = 'Customer 000093' ) ).



  ENDMETHOD.

  METHOD class_teardown.

  "remove test doubles
  cds_test_environment->destroy( ).
  sql_test_environment->destroy( ).

  ENDMETHOD.

  METHOD create_with_action.

    MODIFY ENTITIES OF zr_birap_atrav
        ENTITY ZrBirapAtrav
        CREATE FIELDS ( TravelID CustomerID AgencyID BeginDate EndDate Description TotalPrice BookingFee CurrencyCode )
        WITH VALUE #( (  %cid = 'ROOT001'
        CustomerID = customer_mock_data[ 1 ]-customer_id
        AgencyID = agency_mock_data[ 1 ]-agency_id
        BeginDate = begin_date
        EndDate = end_date
        Description = 'Travel Entity 001'
        TotalPrice = '1000'
        BookingFee = '10'
        CurrencyCode = 'INR'
        ) )

        ENTITY ZrBirapAtrav
            EXECUTE acceptTravel
                frOM vaLUE #( ( %cid_ref = 'ROOT001' ) )

        ENTITY ZrBirapAtrav
            EXECUTE deductDiscount
                FROM VALUE #( ( %cid_ref = 'ROOT001'
                                %param-discount_percent = '10' ) )
        MAPPED DATA(mapped)
        FAILED DATA(failed)
        REPORTED DATA(reported).

        "expect no failures and messages
        cl_abap_unit_assert=>assert_initial( msg = 'failed'  act = failed ).
        cl_abap_unit_assert=>assert_initial( msg = 'reported'  act = reported ).

        "expect a newly created record in mapped tables
        cl_abap_unit_assert=>assert_not_initial(
          EXPORTING
            act              = mapped-zrbirapatrav
            msg              = 'mapped-travel'
*            level            = if_abap_unit_constant=>severity-medium
*            quit             = if_abap_unit_constant=>quit-test
*          RECEIVING
*            assertion_failed =
        ).

        "persist changes in database (using test doubles)
        commit enTITIEs reSPONSes
            fAILED data(commit_failed)
            rePORTED data(commit_reported).

        "no failures expected
        cl_abap_unit_assert=>assert_initial( msg = 'commit_failed'  act = commit_failed ).
        cl_abap_unit_assert=>assert_initial( msg = 'commit_reported'  act = commit_reported ).


        selECT * from zr_birap_atrav into taBLE @DATA(lt_travel).

        cl_abap_unit_assert=>assert_initial( msg = 'travel from db'  act = lt_travel ).
        cl_abap_unit_assert=>assert_initial( msg = 'travel-id'  act = lt_travel[ 1 ]-TravelID ).
        cl_abap_unit_assert=>assert_equals(
          EXPORTING
            act                  = lt_travel
            exp                  = '16'
*            ignore_hash_sequence = abap_false
*            tol                  =
            msg                  = 'discounted booking_fee'
*            level                = if_abap_unit_constant=>severity-medium
*            quit                 = if_abap_unit_constant=>quit-test
*          RECEIVING
*            assertion_failed     =
        ).


  ENDMETHOD.

  METHOD setup.

  "clear the test doubles per test
  cds_test_environment->clear_doubles( ).
  sql_test_environment->clear_doubles( ).
  "insert test data into test doubles
  sql_test_environment->insert_test_data( agency_mock_data ).
  sql_test_environment->insert_test_data( customer_mock_data ).


  ENDMETHOD.

  METHOD teardown.
    "clean up any involved entities
    ROLLBACK ENTITIES.
  ENDMETHOD.

ENDCLASS.


