@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Version Header interface view'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZIHEAD_VERSION as select from zhead_version
composition[1..*] of ZIlineitem_VERSION as _Details 
{
    key id as Id,
    name as Name,
    created_at as CreatedAt,
    created_by as CreatedBy,
    last_changed_at as LastChangedAt,
    last_changed_by as LastChangedBy,
    _Details // Make association public
}
