@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Lineitem interface view'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZIlineitem_VERSION as select from zlineitm_version
    association to parent ZIHEAD_VERSION as _Header on $projection.Id = _Header.Id
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
    last_changed_by as LastChangedBy,
    _Header
}
