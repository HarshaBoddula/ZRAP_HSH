@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OVP - FILTER BAR'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
//@Analytics.query: true
@Analytics.dataCategory: #CUBE
define view entity ZEO_C_OVP as select from /dmo/booking
inner join /dmo/customer on /dmo/customer.customer_id = /dmo/booking.customer_id
{
    key /dmo/booking.travel_id as TravelId,
    key /dmo/booking.booking_id as BookingId,
    /dmo/booking.customer_id as CustomerId,
    /dmo/customer.first_name as customer_name,
    /dmo/booking.carrier_id as CarrierId,
    /dmo/booking.connection_id as ConnectionId,
    @DefaultAggregation: #SUM
    @Semantics.amount.currencyCode: 'CurrencyCode'
    /dmo/booking.flight_price as flight_price,
    /dmo/booking.currency_code as CurrencyCode
}
