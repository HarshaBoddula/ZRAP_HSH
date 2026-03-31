@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test table interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zitesttable as select from ztesttable
{
    key name as Name,
    description as Description
}
