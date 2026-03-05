@EndUserText.label: 'Travel KPI Cube (DMO)'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Analytics.dataCategory: #CUBE
//@Analytics.query: true
define view entity ZI_DMO_TRAVEL_KPI_CUBE
  as select from /dmo/travel
{
  /* Dimensions */
  key travel_id as TravelID,
  key agency_id     as AgencyID,
  key customer_id   as CustomerID,
  key status        as Status,          // DMO travel status (N/P/B/X) - optional

  currency_code     as CurrencyCode,

  /* Measures */
  @Semantics.amount.currencyCode: 'CurrencyCode'
  @DefaultAggregation: #SUM
  total_price       as TotalPrice,

  @Semantics.amount.currencyCode: 'CurrencyCode'
  @DefaultAggregation: #SUM
  booking_fee       as BookingFee,

  @DefaultAggregation: #COUNT_DISTINCT
  travel_id         as TravelCount
}
