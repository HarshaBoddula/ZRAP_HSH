@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZC_ITEST_HEAD'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_ITEST_HEAD
  provider contract transactional_query as projection on zi_itest_head
{
    key headid,
    description,
//    @Semantics.largeObject : {
//            mimeType: 'Mimetype',
//            fileName: 'Filename',
//            contentDispositionPreference: #INLINE
//          }
    @Semantics.largeObject: {
//  acceptableMimeTypes: [ 'image/*', 'application/*' ],
//  cacheControl.maxAge: #MEDIUM,
  contentDispositionPreference: #INLINE , // #ATTACHMENT - download as file
                                              // #INLINE - open in new window
  mimeType: 'Mimetype',
            fileName: 'Filename'
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
    /* Associations */
    _item : redirected to composition child zc_itest_item
}
