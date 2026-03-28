@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'JIRA Incident – Analytical View'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE

@Analytics.dataCategory: #CUBE
//@Analytics.dataExtraction.enabled: true

define view entity ZC_JiraIncident
  as select from ZI_JiraIncident
{
  key incident_id,
      short_text,
      priority,
      status,
      assignment_group,
      assignee,
      application,
      created_at,
      resolved_at,
      sla_due_at,
      //      tstmpl_from_utcl( created_at, 'NULL' ) as tstmp,
      //      tstmp_current_utctimestamp() as test

      /* Incident Age (Hours) */
      @EndUserText.label: 'Incident Age (Hours)'
      //  tstmp_seconds_between
      //(
      //created_at,
      //
      //dats_tims_to_tstmp( $session.system_date, , time_zone, client, on_error )
      //
      //'NULL'
      //)as ZDIFF_SECONDS
      cast(
        div(
          tstmp_seconds_between(
            created_at,
            tstmp_current_utctimestamp(),
            'NULL'
          ),
          3600
        )
        as abap.int4
      )                      as incident_age_hrs,

      @EndUserText.label: 'Incident Count'
      cast( 1 as abap.int4 ) as incident_cnt,

      //  cast(
      //    div( tstmpl_from_utcl( created_at, created_at ), 3600 )
      ////    seconds_between( created_at, $session.system_date ) / 3600
      //    as abap.int4
      //  ) as incident_age_hrs,

      /* SLA Status */
      @EndUserText.label: 'SLA Status'
      case
        when sla_due_at < tstmp_current_utctimestamp()  then 'BREACHED'
        else 'ON_TRACK'
      end                    as sla_status,
      @EndUserText.label: 'SLA Criticality'
      case
        when sla_due_at < tstmp_current_utctimestamp()
          then 1   -- Red
        else 3     -- Green
      end                    as sla_criticality
}
