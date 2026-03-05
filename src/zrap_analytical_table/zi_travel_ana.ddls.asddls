@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View Travel Analytical Table'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_TRAVEL_ANA
  as select from /dmo/a_travel_d
{
  key travel_uuid             as TravelUuid,
      travel_id               as TravelId,
      agency_id               as AgencyId,
      customer_id             as CustomerId,
      begin_date              as BeginDate,
      end_date                as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee             as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee             as MinBookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee             as MaxBookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price             as TotalPrice,
      cast ( 1 as abap.int4 ) as differentCurrencies,
      currency_code           as CurrencyCode,
      description             as Description,
      overall_status          as OverallStatus
}


