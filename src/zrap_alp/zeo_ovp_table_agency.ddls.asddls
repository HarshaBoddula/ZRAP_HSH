@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZEO_OVP_TABLE_AGENCY'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZEO_OVP_TABLE_AGENCY as select from /dmo/booking
    inner join /dmo/carrier as Carrier on Carrier.carrier_id = /dmo/booking.carrier_id
{
    key Carrier.carrier_id as CarrierID,
    Carrier.name as CarrierName,
//    customer_id as CustomerID,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    sum( /dmo/booking.flight_price ) as FlightPrice,
    /dmo/booking.currency_code as CurrencyCode
    
} group by Carrier.carrier_id, 
Carrier.name,
//customer_id,
 /dmo/booking.currency_code
