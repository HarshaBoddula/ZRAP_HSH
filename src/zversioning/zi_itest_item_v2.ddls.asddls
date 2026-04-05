@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ITest Item'
define root view entity ZI_ITEST_ITEM_v2
  as select from ztest_itms
{
  key itemuuid,          

  headid,
  itemid,
  quarter,
  version,

  @Semantics.amount.currencyCode: 'Waers'
  amount,
  waers,
  
case
  when version <> 'V1' then 1
  else 0
end as is_history,
  
  created_by,
    created_at,
    last_changed_by,
    last_changed_at,
    local_last_changed_at
}
