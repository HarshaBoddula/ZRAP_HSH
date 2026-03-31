@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Lineitem projection view'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZClineitem_VERSION as projection on ZIlineitem_VERSION
{
    key Id,
    key Version,
    key Quarter,
    key FiscalYear,
    Owner,
    OwningBusiness,
    Name,
    Forecast,
    Waers,
    CreatedAt,
    CreatedBy,
    LastChangedAt,
    LastChangedBy,
    /* Associations */
    _Header : redirected to parent ZCHEAD_VERSION
}
