@EndUserText.label: 'Travel KPI Consumption (DMO)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@Analytics.query: true
@UI.headerInfo: {
  typeName: 'Travel KPI',
  typeNamePlural: 'Travel KPIs',
  title: { value: 'AgencyID' }
}
define view entity ZC_DMO_TRAVEL_KPI as select from ZI_DMO_TRAVEL_KPI_CUBE
{
  AgencyID,
  CustomerID,
  Status,
  CurrencyCode,
  TotalPrice,
  BookingFee,
  TravelCount
}
