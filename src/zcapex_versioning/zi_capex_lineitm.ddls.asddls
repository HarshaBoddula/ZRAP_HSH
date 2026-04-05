@EndUserText.label : 'Interface View - CAPEX Line Item'
@AccessControl.authorizationCheck : #NOT_REQUIRED
@Metadata.allowExtensions : true
define view entity ZI_CAPEX_LINEITM
  as select from zcapex_lineitm
{
  key lineitm_uuid,
      capex_uuid,
      version,
      quarter,
      owner,
      name,
      forecast,
      waers,
      created_at,
      created_by,
      last_changed_at,
      last_changed_by

//  _Header : association to parent ZI_CAPEX_HDR
//    on $projection.capex_uuid = _Header.capex_uuid
}
