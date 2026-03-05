@Metadata.allowExtensions: true
@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label: 'Projection View Travel Analytical Table'
@OData.applySupportedForAggregation: #FULL

define root view entity ZC_Travel_ANA
  provider contract transactional_query
  as projection on ZI_TRAVEL_ANA
{
  key TravelUuid,
      TravelId,
      AgencyId,
      CustomerId,
      BeginDate,
      EndDate,
      @Aggregation.default: #AVG
      @EndUserText.label: 'Booking Fee (#AVG)'
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Aggregation.default: #MIN
      @EndUserText.label: 'Min Booking Fee (#MIN)'
      @Semantics.amount.currencyCode: 'CurrencyCode'
      MinBookingFee,
      @Aggregation.default: #MAX
      @EndUserText.label: 'Max Booking Fee (#MAX)'
      @Semantics.amount.currencyCode: 'CurrencyCode'
      MaxBookingFee,
      @Aggregation.default: #SUM
      @EndUserText.label: 'Total Price (#SUM)'
      TotalPrice,
      @Aggregation.default: #COUNT_DISTINCT
      @EndUserText.label: 'Different Currencies (#COUNT_DISTINCT)'
      @Aggregation.referenceElement: ['CurrencyCode']
      differentCurrencies,
      CurrencyCode,
      Description,
      OverallStatus
}
