@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'JIRA Incident – Interface View'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_JiraIncident as select from ztjira_incident

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
      sla_due_at
}

