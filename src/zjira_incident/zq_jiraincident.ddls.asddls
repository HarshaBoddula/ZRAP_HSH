@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'JIRA Incident – Analytical List Page'
@VDM.viewType: #CONSUMPTION
//@Analytics.query: true
@Metadata.allowExtensions: true
define view entity ZQ_JiraIncident
  as select from ZC_JiraIncident
{
  /* Keys */
  key incident_id,

  /* === Selection Fields (Filters + Visual Filters) === */
  @UI.selectionField: [{ position: 10 }]
  @UI.lineItem: [{ position: 20 }]
  priority,

  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem: [{ position: 30 }]
  status,

  @UI.selectionField: [{ position: 30 }]
  @UI.lineItem: [{ position: 40 }]
  assignment_group,

  @UI.selectionField: [{ position: 40 }]
  application,

  /* === Table Columns === */
  @UI.lineItem: [{ position: 10 }]
  short_text,

  @UI.lineItem: [{ position: 50 }]
  assignee,

  @UI.lineItem: [{ position: 60, criticality: 'sla_criticality' }]
  sla_status,
  @DefaultAggregation: #SUM
  @UI.lineItem: [{ position: 70 }]
  incident_age_hrs,
  @DefaultAggregation: #SUM
  incident_cnt,
  sla_criticality
}
