@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZBIRAP_ATRAV'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_BIRAP_ATRAV
  as select from zbi_rap_atrav
  association [0..1] to /DMO/I_Agency as _Agency on $projection.AgencyID = _Agency.AgencyID
  association [0..1] to /DMO/I_Customer as _Customer on $projection.CustomerID = _Customer.CustomerID
  association [1..1] to /DMO/I_Overall_Status_VH as _OverallStatus on $projection.OverallStatus = _OverallStatus.OverallStatus
  association [0..1] to I_Currency as _Currency on $projection.CurrencyCode = _Currency.Currency
{
  key travel_id as TravelID,
  agency_id as AgencyID,
  cast( concat( cast(agency_id as abap.char(6)) , concat( '-', _Agency.Name ) ) as abap.char( 256 ) ) as AgencyDisplay,
//  cast( concat( concat( cast(agency_id as abap.char(6)) , cast('-' as abap.char(1)) ) , cast(_Agency.Name as abap.char(20) )  as abap.string( 256 ) ) as AgencyDisplay,
//  concat( concat( agency_id, '-' ) , _Agency.Name )
//  cast( concat( concat( agency_id, '-' ) , _Agency.Name ) as abap.string(256) )   as AgencyDisplay,
  customer_id as CustomerID,
  begin_date as BeginDate,  
  end_date as EndDate,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  booking_fee as BookingFee,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  total_price as TotalPrice,
//  @Semantics.amount.currencyCode: 'CurrencyCode'
//  booking_fee as BookingOutOfTotal,
  @Consumption.valueHelpDefinition: [ {
    entity.name: 'I_CurrencyStdVH', 
    entity.element: 'Currency', 
    useForValidation: true
  } ]
  @ObjectModel.foreignKey.association: '_Currency'
  currency_code as CurrencyCode,
  description as Description,
  overall_status as OverallStatus,
  @Semantics.largeObject: { mimeType: 'MimeType',
  fileName: 'FileName',
  acceptableMimeTypes: [ 'image/png', 'image/jpeg' ],
  contentDispositionPreference: #ATTACHMENT
  }
  
  attachment as Attachment,
  @Semantics.mimeType: true
  mime_type as MimeType,
  file_name as FileName,
//  @Semantics.systemDateTime.createdAt: true
//  creation_date as CreationDate,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,     
   cast( substring( cast( created_at as abap.char(30) ), 1, 8 ) as abap.dats ) as created_date,
   cast( case
   when cast( dats_days_between(  cast( substring( cast( created_at as abap.char(30) ), 1, 8 ) as abap.dats ), $session.system_date ) as abap.int2) = 0
   then 'TODAY'
   when cast( dats_days_between(  cast( substring( cast( created_at as abap.char(30) ), 1, 8 ) as abap.dats ), $session.system_date ) as abap.int2) <= 10
   then 'WITHIN10D'
   when cast( dats_days_between(  cast( substring( cast( created_at as abap.char(30) ), 1, 8 ) as abap.dats ), $session.system_date ) as abap.int2) > 10
   then 'OLDER'
   end as abap.char(10) )
    as Status,
  _Agency,
  _Customer,
  _Currency,
  _OverallStatus
}
