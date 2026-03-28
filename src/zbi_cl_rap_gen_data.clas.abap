CLASS zbi_cl_rap_gen_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZBI_CL_RAP_GEN_DATA IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA: attachment TYPE /dmo/attachment,
          file_name  TYPE /dmo/filename,
          mime_type  TYPE /dmo/mime_type.
    deLETE from ztstatus.

"Insert exactly 3 records
INSERT ztstatus FROM TABLE @(
  VALUE #( ( client = sy-mandt staus = 'TODAY'     )
           ( client = sy-mandt staus = 'WITHIN10D' )
           ( client = sy-mandt staus = 'OLDER'     ) )
).



*    "clear data
*    DELETE FROM zbi_rap_atrav.
*
*    "Insert New DATA.
*    INSERT zbi_rap_atrav FROM (
*     SELECT FROM /dmo/travel AS travel
*      FIELDS travel~travel_id AS travel_id,
*      travel~agency_id AS agency_id,
*      travel~customer_id AS customer_id,
*      travel~begin_date AS begin_date,
*      travel~end_Date AS end_date,
*      travel~booking_fee AS booking_fee,
*      travel~total_price AS total_price,
*      travel~currency_code AS currency_code,
*      travel~description AS description,
*      CASE travel~status  "N[NEW], P[PLANNED], B[BOOKED], X[CANCELLED]
*      WHEN 'N' THEN 'O'
*      WHEN 'P' THEN 'O'
*      WHEN 'B' THEN 'A'
*      ELSE 'X'
*      END AS overall_status,
*      @attachment AS attachment,
*      @mime_type AS mime_type,
*      @file_name AS file_name,
*      travel~createdby AS created_by,
*      travel~createdat AS created_at,
*      travel~lastchangedby AS last_Changed_by,
*      travel~lastchangedat AS last_changed_At,
*
*      travel~lastchangedat AS local_last_changed_at
*      ORDER BY travel_id UP TO 10 ROWS
*      ).

    COMMIT WORK.
    out->write( 'Demo data generated'
    ).

  ENDMETHOD.
ENDCLASS.
