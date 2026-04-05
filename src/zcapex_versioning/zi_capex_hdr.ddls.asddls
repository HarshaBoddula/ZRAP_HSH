@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - CAPEX Header'
@Metadata.allowExtensions : true
define root view entity ZI_CAPEX_HDR as select from zcapex_hdr
//composition of ZI_CAPEX_ as _association_name
{
    
 key capex_uuid,
      capex_name,
      business_unit,
      fiscal_year,
      created_at,
      created_by,
      last_changed_at,
      last_changed_by

//  _Items : composition [0..*] of ZI_CAPEX_LINEITM
}
