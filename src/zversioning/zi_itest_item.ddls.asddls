@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ITest Item'
define view entity zi_itest_item
  as select from ztest_itms
  association to parent zi_itest_head as _head
    on $projection.headid = _head.headid
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
    local_last_changed_at,
  _head
}
