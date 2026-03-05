@Metadata.allowExtensions: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZBIRAP_ATRAV'
}
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
define root view entity ZC_BIRAP_ATRAV
  provider contract transactional_query
  as projection on ZR_BIRAP_ATRAV
  association [1..1] to ZR_BIRAP_ATRAV as _BaseEntity on $projection.TravelID = _BaseEntity.TravelID
{
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.90
  key TravelID,
  @Search.defaultSearchElement: true
  @ObjectModel.text.element: [ 'AgencyName' ]
  @Consumption.valueHelpDefinition: [{ entity : { name: '/DMO/I_Agency_StdVH', element: 'AgencyID' } }]
  AgencyID,
  _Agency.Name as AgencyName,
  @Search.defaultSearchElement: true
  @ObjectModel.text.element: [ 'CustomerName' ]
  @Consumption.valueHelpDefinition: [{ entity : { name: '/DMO/I_Customer_StdVH', element: 'CustomerID' } }]
  CustomerID,
  _Customer.LastName as CustomerName,
  BeginDate,
  EndDate,
  @Semantics: {
    amount.currencyCode: 'CurrencyCode'
  }
  BookingFee,
  @Semantics: {
    amount.currencyCode: 'CurrencyCode'
  }
  TotalPrice,
//  @Semantics: {
//    amount.currencyCode: 'CurrencyCode'
//  }
//  BookingOutOfTotal,
  @Consumption: {
    valueHelpDefinition: [ {
      entity.element: 'Currency', 
      entity.name: 'I_CurrencyStdVH', 
      useForValidation: true
    } ]
  }
  CurrencyCode,
  Description,
  @Search.defaultSearchElement: true
  @ObjectModel.text.element: [ 'OverallStatusText' ]
  @Consumption.valueHelpDefinition: [{ entity : { name: '/DMO/I_Overall_Status_VH', element: 'OverallStatus' } }]
  OverallStatus,
  _OverallStatus._Text.Text as OverallStatusText : localized,
  @Semantics.largeObject: { mimeType: 'MimeType',
  fileName: 'FileName',
  acceptableMimeTypes: [ 'image/png', 'image/jpeg' ],
  contentDispositionPreference: #ATTACHMENT
  }
  
  Attachment,
  MimeType,
  FileName,
  
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZBI_CL_CALC'
  virtual traveldays: abap.int1,
  @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  CreatedAt,
  @Semantics: {
    user.localInstanceLastChangedBy: true
  }
  LastChangedBy,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LastChangedAt,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LocalLastChangedAt,
  _BaseEntity
}
