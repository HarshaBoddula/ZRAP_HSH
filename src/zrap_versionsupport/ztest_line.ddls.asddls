@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZTEST_LINE'
//@Metadata.ignorePropagatedAnnotations: true
define root view entity ZTEST_LINE as select from zlineitm_version
{
    key id as Id,
    key version as Version,
    key quarter as Quarter,
    key fiscal_year as FiscalYear,
    owner as Owner,
    owning_business as OwningBusiness,
    name as Name,
    @Semantics.amount.currencyCode: 'Waers'
    forecast as Forecast,
    waers as Waers,
    created_at as CreatedAt,
    created_by as CreatedBy,
    last_changed_at as LastChangedAt,
    last_changed_by as LastChangedBy
}
