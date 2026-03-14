CLASS zcl_load_jira_dummy_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_load_jira_dummy_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.


    DATA: ls_incident TYPE ztjira_incident.

    "Optional: clean old data
    DELETE FROM ztjira_incident.
    COMMIT WORK.

    DO 50 TIMES.

      CLEAR ls_incident.

      ls_incident-client        = sy-mandt.
      ls_incident-incident_id   = |INC-{ sy-index }|.
      ls_incident-short_text    = |Dummy Incident { sy-index }|.

      ls_incident-priority = COND #(
        WHEN sy-index MOD 3 = 0 THEN 'P1'
        WHEN sy-index MOD 2 = 0 THEN 'P2'
        ELSE 'P3'
      ).

      ls_incident-status = COND #(
        WHEN sy-index MOD 3 = 0 THEN 'OPEN'
        WHEN sy-index MOD 2 = 0 THEN 'IN_PROGRESS'
        ELSE 'RESOLVED'
      ).

      ls_incident-assignment_group = |TEAM-{ sy-index MOD 4 }|.
      ls_incident-assignee         = |USER-{ sy-index MOD 5 }|.
      ls_incident-application      = |APP-{ sy-index MOD 3 }|.

      "Created timestamp (past days)

DATA: lv_tstmp TYPE timestampl.
GET TIME STAMP FIELD lv_tstmp.

data(lv_date) = cl_abap_context_info=>get_system_date(  ) .
data(lv_time) = cl_abap_context_info=>get_system_time(  ).
*      lv_date = lv_Date - sy-index.
CONVERT TIME STAMP lv_tstmp TIME ZONE 'UTC'
  INTO DATE lv_Date TIME lv_time.

DATA: lv_created_at TYPE timestampl.

ls_incident-created_at =
  cl_abap_tstmp=>add(
    tstmp = lv_tstmp
    secs  = - ( sy-index * 3600 )   "each incident 1 hour older
  ).

ls_incident-sla_due_at =
  cl_abap_tstmp=>add(
    tstmp = lv_tstmp
    secs  = 24 * 3600   " +1 day
  ).
**      ls_incident-created_at =
**        tstmp_from_date_time(
**          sy-datum - sy-index,
**          sy-uzeit
**        ).
*
*      "SLA due timestamp (future)
*      ls_incident-sla_due_at =
*        tstmp_from_date_time(
*          sy-datum + 1,
*          sy-uzeit
*        ).

      INSERT ztjira_incident FROM @ls_incident.

    ENDDO.

    COMMIT WORK.

    out->write( |✅ 50 dummy JIRA incidents loaded successfully.| ).

  ENDMETHOD.

ENDCLASS.
