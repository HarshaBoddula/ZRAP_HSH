@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for status of record'
@Search.searchable: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZI_STATUSTRAVEL_VH as select from ztstatus
{
     @Search.defaultSearchElement: true
    key staus as Status
}
