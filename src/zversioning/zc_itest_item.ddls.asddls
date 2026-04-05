@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cTEST item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity zc_itest_item as projection on zi_itest_item
{
    key itemuuid,
    headid,
    itemid,
    quarter,
    version,
    @Semantics.amount.currencyCode: 'waers'
    amount,
    waers,
is_history,
    created_by,
    created_at,
    last_changed_by,
    last_changed_at,
    local_last_changed_at,
    
    version_sort_rank,
    
    /* Associations */
    _head: redirected to parent ZC_ITEST_HEAD
}
