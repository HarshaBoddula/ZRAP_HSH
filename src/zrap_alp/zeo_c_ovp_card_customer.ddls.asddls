@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Analytical card - customer'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZEO_C_OVP_card_Customer as select from /dmo/booking
    inner join /dmo/customer on /dmo/customer.customer_id = /dmo/booking.customer_id
{
    key /dmo/booking.customer_id,
    /dmo/customer.first_name as customer_name,
    @Semantics.amount.currencyCode: 'currency_code'
    @DefaultAggregation: #SUM
    sum( /dmo/booking.flight_price ) as flight_price,
    /dmo/booking.currency_code
}
group by /dmo/booking.customer_id,/dmo/customer.first_name, /dmo/booking.currency_code
