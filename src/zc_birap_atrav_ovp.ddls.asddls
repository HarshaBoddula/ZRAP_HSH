@EndUserText.label: 'Travel OVP Analytics'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Analytics.dataCategory: #CUBE
@VDM.viewType: #CONSUMPTION
@Metadata.allowExtensions: true
define view entity ZC_BIRAP_ATRAV_OVP
  as select from ZR_BIRAP_ATRAV
{
  key OverallStatus,

//  @Analytics.measure: true
  @Semantics.amount.currencyCode: 'CurrencyCode'
  sum( BookingFee ) as BookingFeeSum,

  CurrencyCode
}
group by OverallStatus, CurrencyCode;
