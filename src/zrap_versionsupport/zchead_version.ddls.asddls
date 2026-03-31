@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Version Header projection view'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCHEAD_VERSION
    provider contract transactional_query
 as projection on ZIHEAD_VERSION
{
    key Id,
    Name,
    CreatedAt,
    CreatedBy,
    LastChangedAt,
    LastChangedBy,
    /* Associations */
    _Details : redirected to composition child ZClineitem_VERSION
}
