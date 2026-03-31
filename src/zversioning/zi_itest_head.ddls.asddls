@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ITest Header'
define root view entity zi_itest_head
  as select from ztest_head
  composition [0..*] of zi_itest_item as _item
{
  key headid,
  description,
  @Semantics.largeObject : {
            mimeType: 'Mimetype',
            fileName: 'Filename',
            contentDispositionPreference: #INLINE
          }
      attachment,
      filename,
      @Semantics.mimeType: true
      mimetype,
  created_by,
    created_at,
    last_changed_by,
    last_changed_at,
    local_last_changed_at,
  _item
}
