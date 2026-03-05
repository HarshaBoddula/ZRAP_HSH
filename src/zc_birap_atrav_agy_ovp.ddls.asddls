@EndUserText.label: 'Total Price by Agency (OVP)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Analytics.dataCategory: #CUBE
@VDM.viewType: #CONSUMPTION
@Metadata.allowExtensions: true
define view entity ZC_BIRAP_ATRAV_AGY_OVP
  as select from ZR_BIRAP_ATRAV
{
  key AgencyID,

//  @Analytics.measure: true
  @Semantics.amount.currencyCode: 'CurrencyCode'
  sum( TotalPrice ) as TotalPriceSum,

  CurrencyCode
}
group by AgencyID, CurrencyCode;
