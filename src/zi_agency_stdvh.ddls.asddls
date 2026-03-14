@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Agency ValueHelp'
@Search.searchable: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_AGENCY_STDVH
  as select from /DMO/I_Agency as Agency
{
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['Name']
      @UI.textArrangement: #TEXT_SEPARATE
      @UI.hidden: true
      //      @UI.lineItem: [{ position: 10, importance: #HIGH }]
  key AgencyID,

      @UI.lineItem: [{ position: 10, importance: #HIGH }]
      cast( concat( cast(AgencyID as abap.char(6)) , concat( ' - ', Name ) ) as abap.char( 256 ) ) as AgencyDisplay,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      @UI.hidden: true
      //      @UI.lineItem: [{ position: 20, importance: #HIGH }]
      Name,

      //      @UI.lineItem: [{ position: 30, importance: #LOW }]
      @UI.hidden: true
      Street,

      //      @UI.lineItem: [{ position: 40, importance: #MEDIUM }]
      @UI.hidden: true
      PostalCode,

      @Search.defaultSearchElement: true
      //      @UI.lineItem: [{ position: 50, importance: #MEDIUM }]
      @UI.hidden: true
      City,

      @Consumption.valueHelpDefinition: [{entity: { name: 'I_CountryVH', element: 'Country' }, useForValidation: true }]
      @ObjectModel.text.element: ['CountryCodeText']
      @UI.textArrangement: #TEXT_ONLY
      @UI.hidden: true
      //      @UI.lineItem: [{ position: 60, importance: #MEDIUM }]
      CountryCode,

      @UI.hidden: true
      _Country._Text[1:Language = $session.system_language].CountryName                            as CountryCodeText,

      //      @UI.lineItem: [{ position: 70, importance: #LOW }]
      @UI.hidden: true
      PhoneNumber,

      //      @UI.lineItem: [{ position: 80, importance: #LOW }]
      @UI.hidden: true
      EMailAddress,

      @UI.hidden: true
      //      @UI.lineItem: [{ position: 90, importance: #LOW }]
      WebAddress
}
