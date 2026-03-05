CLASS zbackup_mbt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  methODS: test.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zbackup_mbt IMPLEMENTATION.

  METHOD test.

"Package - ZTRM_MASS_BANKTRANSFER
*
"Database tables
*ZTRM_A_BANKFILE
*
*@EndUserText.label : 'User File Table for Bank transfer'
*@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
*@AbapCatalog.tableCategory : #TRANSPARENT
*@AbapCatalog.deliveryClass : #A
*@AbapCatalog.dataMaintenance : #RESTRICTED
*define table ztrm_a_bankfile {
*
*  key client            : abap.clnt not null;
*  key end_user          : uname not null;
*  status                : abap.char(1);
*  attachment            : xstringval;
*  mimetype              : abap.char(128);
*  filename              : abap.char(128);
*  local_created_by      : abp_creation_user;
*  local_created_at      : abp_creation_tstmpl;
*  local_last_changed_by : abp_locinst_lastchange_user;
*  local_last_changed_at : abp_locinst_lastchange_tstmpl;
*  last_changed_at       : abp_lastchange_tstmpl;
*  title                 : char200;
*
*}


*ZTRM_A_BANKDATA
*
*@EndUserText.label : 'Bank data table for Bank Transfer'
*@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
*@AbapCatalog.tableCategory : #TRANSPARENT
*@AbapCatalog.deliveryClass : #A
*@AbapCatalog.dataMaintenance : #RESTRICTED
*define table ztrm_a_bankdata {
*
*  key client        : abap.clnt not null;
*  key end_user      : uname not null;
*  key created_on    : dats not null;
*  key created_at    : tims not null;
*  key snro          : zztrm_snro not null;
*  status_icon       : icon_d;
*  rpcode            : rpcode;
*  @Semantics.amount.currencyCode : 'ztrm_a_bankdata.waers'
*  rwbtr             : rwbtr;
*  waers             : waers;
*  rp_text           : rpcode_text;
*  keyno             : prq_keyno not null;
*  message           : bapi_msg;
*  release_status    : bapi_msg;
*  run_date          : prq_paymrundate;
*  run_id            : prq_paymrunid;
*  valut             : valut;
*  pdate             : budat_f111;
*  payment_status    : bapi_msg;
*  title             : char200;
*  criticalitystatus : abap.char(1);
*  relcriticality    : abap.char(1);
*  paycriticality    : abap.char(1);
*
*}
*
*ZTRM_D_BANKFILE
*
*@EndUserText.label : 'Draft table for entity ZTRM_I_BANKFILE'
*@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
*@AbapCatalog.tableCategory : #TRANSPARENT
*@AbapCatalog.deliveryClass : #A
*@AbapCatalog.dataMaintenance : #RESTRICTED
*define table ztrm_d_bankfile {
*
*  key mandt             : mandt not null;
*  key end_user          : xubname not null;
*  status                : abap.char(1);
*  filestatus            : abap.char(20);
*  criticalitystatus     : abap.char(1);
*  hideexcel             : boolean;
*  attachment            : xstringval;
*  mimetype              : abap.char(128);
*  filename              : abap.char(128);
*  local_created_by      : abp_creation_user;
*  local_created_at      : abp_creation_tstmpl;
*  local_last_changed_by : abp_locinst_lastchange_user;
*  local_last_changed_at : abp_locinst_lastchange_tstmpl;
*  last_changed_at       : abp_lastchange_tstmpl;
*  title                 : abap.char(200);
*  "%admin"              : include sych_bdl_draft_admin_inc;
*
*}
*
*ZTRM_D_BANKDATA
*
*@EndUserText.label : 'Draft table for entity ZTRM_I_BANKDATA'
*@AbapCatalog.enhancement.category : #EXTENSIBLE_ANY
*@AbapCatalog.tableCategory : #TRANSPARENT
*@AbapCatalog.deliveryClass : #A
*@AbapCatalog.dataMaintenance : #RESTRICTED
*define table ztrm_d_bankdata {
*
*  key mandt         : mandt not null;
*  key end_user      : uname not null;
*  key createdon     : dats not null;
*  key createdat     : tims not null;
*  key snro          : zztrm_snro not null;
*  statusicon        : icon_d;
*  rpcode            : rpcode;
*  @Semantics.amount.currencyCode : 'ztrm_d_bankdata.waers'
*  rwbtr             : rwbtr;
*  waers             : waers;
*  rptext            : rpcode_text;
*  keyno             : prq_keyno;
*  message           : bapi_msg;
*  releasestatus     : bapi_msg;
*  rundate           : prq_paymrundate;
*  runid             : prq_paymrunid;
*  valut             : valut;
*  pdate             : budat_f111;
*  paymentstatus     : bapi_msg;
*  title             : abap.char(200);
*  criticalitystatus : abap.char(1);
*  relcriticality    : abap.char(1);
*  paycriticality    : abap.char(1);
*  "%admin"          : include sych_bdl_draft_admin_inc;
*
*}
*
*Dataelement - ZZTRM_SNRO
*
*NUMC - length 6
*
*TABLE TYPE - ZTT_T018V
*T018V
*
*Core Data Services
*------------------------
*Data Definitions
*-------------------------
*ZTRM_I_BANKFILE
*
*@AccessControl.authorizationCheck: #NOT_REQUIRED
*@EndUserText.label: 'Interface view for File table Bank transfer'
*@ObjectModel.usageType: { dataClass: #TRANSACTIONAL, sizeCategory: #XL, serviceQuality: #A }
*define root view entity ZTRM_I_BANKFILE
*  as select from    I_User           as _user
*left outer join ztrm_a_bankfile as _bank_file on _user.UserID = _bank_file.end_user
*  composition [0..*] of ZTRM_I_BANKDATA as _bank_excel
*{
*  key _user.UserID                                                                                            as end_user,
*      _bank_file.status                                                                                         as status,
*
*      cast( case when _bank_file.filename is initial then 'File Not Uploaded'
*                 when _bank_file.filename is not initial and  _bank_file.status is initial  then 'File Uploaded'
*                 when  _bank_file.status is not initial then 'File Processed' else ' ' end as abap.char( 20 ) ) as FileStatus,
*      cast( case when _bank_file.filename is initial then '1'
*                 when _bank_file.filename is not initial and  _bank_file.status is initial  then '2'
*                 when  _bank_file.status is not initial then '3' else ' ' end as abap.char( 1 ) )               as CriticalityStatus,
*      cast( case when _bank_file.filename is not initial then ' ' else 'X' end as boolean preserving type  )    as HideExcel,
*      @Semantics.largeObject:
*      { mimeType: 'MimeType',
*      fileName: 'Filename',
*      acceptableMimeTypes: [ 'text/csv', 'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
*      contentDispositionPreference: #INLINE }  // This will store the File into our table
*      _bank_file.attachment                                                                                     as Attachment,
*      @Semantics.mimeType: true
*      _bank_file.mimetype                                                                                       as MimeType,
*      _bank_file.filename                                                                                       as Filename,
*      @Semantics.user.createdBy: true
*      _bank_file.local_created_by                                                                               as Local_Created_By,
*      @Semantics.systemDateTime.createdAt: true
*      _bank_file.local_created_at                                                                               as Local_Created_At,
*      @Semantics.user.lastChangedBy: true
*      _bank_file.local_last_changed_by                                                                          as Local_Last_Changed_By,
*      //local ETag field --> OData ETag
*      @Semantics.systemDateTime.localInstanceLastChangedAt: true
*      _bank_file.local_last_changed_at                                                                          as Local_Last_Changed_At,
*      //total ETag field
*      @Semantics.systemDateTime.lastChangedAt: true
*      _bank_file.last_changed_at                                                                                as Last_Changed_At,
*
*      cast( 'Funding Wire Upload' as abap.char(200) ) as Title,
*
*      _bank_excel
*}
*where
*  _user.UserID = $session.user
*
*
*--------------------------------------
*
*ZTRM_I_BANKDATA
*
*@AccessControl.authorizationCheck: #NOT_REQUIRED
*@EndUserText.label: 'Interface view for Bank transfer table'
*@Metadata.allowExtensions: true
*@ObjectModel.usageType: { dataClass: #TRANSACTIONAL, sizeCategory: #XL, serviceQuality: #A }
*define view entity ZTRM_I_BANKDATA as select from ztrm_a_bankdata
*    association to parent ZTRM_I_BANKFILE as _bank_file on $projection.end_user = _bank_file.end_user
*{
*    key end_user as end_user,
*    key created_on as CreatedOn,
*    key created_at as CreatedAt,
*    key snro as Snro,
*    status_icon as StatusIcon,
*    rpcode as Rpcode,
*    rwbtr,
*    waers as Waers,
*    rp_text as RpText,
*    keyno as Keyno,
*    message as Message,
*    release_status as ReleaseStatus,
*    run_date as RunDate,
*    run_id as RunId,
*    valut as Valut,
*    pdate as Pdate,
*    payment_status as PaymentStatus,
*    cast( 'Funding Wire Upload' as abap.char(200) ) as Title,
*    cast ( case status_icon
*                 when 'S'  then '3'
*                 when 'E' then '1'
*                 else '0' end as abap.char(1) ) as CriticalityStatus,
*    cast ( case when release_status = 'Released' then '3'
*                 when release_status is initial then '0'
*                 else '1' end as abap.char(1) ) as RelCriticality,
*    cast ( case
*                 when run_id is not initial then '3'
*                 else '0' end as abap.char(1) ) as PayCriticality,
*    _bank_file
*}
*
*------------------------------------
*
*ZTRM_C_BANKFILE
*
*@EndUserText.label: 'Consumption view for File table Bank transfer'
*@AccessControl.authorizationCheck: #NOT_REQUIRED
*@Metadata.allowExtensions: true
*@ObjectModel.usageType: { dataClass: #TRANSACTIONAL, sizeCategory: #XL, serviceQuality: #A }
*define root view entity ZTRM_C_BANKFILE
*  provider contract transactional_query
*  as projection on ZTRM_I_BANKFILE
*{
*  key end_user,
*      @EndUserText.label: 'Processing Status'
*      FileStatus as status,
*      Attachment,
*      MimeType,
*      Filename,
*      Local_Created_By,
*      Local_Created_At,
*      Local_Last_Changed_By,
*      @EndUserText.label: 'Last Action On'
*      Local_Last_Changed_At,
*      Last_Changed_At,
*      CriticalityStatus,
*      HideExcel,
*      Title,
*
*      /* Associations */
*      _bank_excel : redirected to composition child ZTRM_C_BANKDATA
*}
*
*
*---------------------------
*
*ZTRM_C_BANKDATA
*
*@EndUserText.label: 'Consumption view for Bank transfer data table'
*@AccessControl.authorizationCheck: #NOT_REQUIRED
*@Metadata.allowExtensions: true
*@ObjectModel.usageType: { dataClass: #TRANSACTIONAL, sizeCategory: #XL, serviceQuality: #A }
*define view entity ZTRM_C_BANKDATA
*  as projection on ZTRM_I_BANKDATA
*{
*    key end_user,
*    key CreatedOn,
*    key CreatedAt,
*    key Snro,
*    StatusIcon,
*    Rpcode,
*    rwbtr,
*    Waers,
*    RpText,
*    Keyno,
*    Message,
*    ReleaseStatus,
*    RunDate,
*    RunId,
*    Valut,
*    Pdate,
*    PaymentStatus,
*    Title,
*    CriticalityStatus,
*    RelCriticality,
*    PayCriticality,
*    /* Associations */
*    _bank_file : redirected to parent ZTRM_C_BANKFILE
*}
*
*-------------------------
*ZTRM_I_PAYRQ
*
*@AbapCatalog.viewEnhancementCategory: [#NONE]
*@AccessControl.authorizationCheck: #NOT_REQUIRED
*@EndUserText.label: 'Payment request details with country'
*@Metadata.ignorePropagatedAnnotations: true
*@ObjectModel.usageType:{
*    serviceQuality: #X,
*    sizeCategory: #S,
*    dataClass: #MIXED
*}
*define view entity ZTRM_I_PAYRQ as select from P_PaymentRequests as payrq
*            left outer join I_CompanyCode as compcode on payrq.PayingCompanyCode = compcode.CompanyCode
*{
*    key payrq.PaymentRequest,
*    payrq.PayingCompanyCode,
*    payrq.PaymentMethod,
*    compcode.Country
*}
*
*
*-------------------------------
*ZTRM_I_RPCODE
*
*@AbapCatalog.viewEnhancementCategory: [#NONE]
*@AccessControl.authorizationCheck: #NOT_REQUIRED
*@EndUserText.label: 'Repetative code with account transfer'
*@Metadata.ignorePropagatedAnnotations: true
*@ObjectModel.usageType:{
*    serviceQuality: #X,
*    sizeCategory: #S,
*    dataClass: #MIXED
*}
*define view entity ZTRM_I_RPCODE as
*    select from fibl_rpcode as rpcode
*    left outer join I_CompanyCode as compcode on rpcode.bukrs = compcode.CompanyCode
*    inner join I_BankForBusinessPartner as bnka on rpcode.banks = bnka.BankCountry
*                          and rpcode.bankl = bnka.BankInternalID
*    inner join I_HouseBankAccount as HBacc on rpcode.pbukr = HBacc.CompanyCode
*                and rpcode.partn = HBacc.HouseBank
*                and rpcode.parta = HBacc.HouseBankAccount
*    right outer join t018v as clearingacct on rpcode.pbukr = clearingacct.bukrs
*{
*    key rpcode.bukrs as Bukrs,
*    key rpcode.hbkid as Hbkid,
*    key rpcode.rpcode as Rpcode,
*    key compcode.CompanyCode,
*    rpcode.hktid as Hktid,
*    rpcode.chain as Chain,
*    rpcode.banks as Banks,
*    rpcode.bankl as Bankl,
*    rpcode.bankn as Bankn,
*    rpcode.bkont as Bkont,
*    rpcode.bkref as Bkref,
*    rpcode.koinh as Koinh,
*    rpcode.ptype as Ptype,
*    rpcode.partn as Partn,
*    rpcode.parta as Parta,
*    rpcode.pbukr as Pbukr,
*    rpcode.zlsch as Zlsch,
*    rpcode.waers as Waers,
*    rpcode.dcrea as Dcrea,
*    rpcode.ucrea as Ucrea,
*    rpcode.drele as Drele,
*    rpcode.urele as Urele,
*    rpcode.drel1 as Drel1,
*    rpcode.urel1 as Urel1,
*    rpcode.zpayment_system as ZpaymentSystem,
*    rpcode.zalias_type as ZaliasType,
*    rpcode.zbank_alias as ZbankAlias,
*    clearingacct.bukrs as AccBukrs,
*    clearingacct.hbkid as AccHbkid,
*    clearingacct.zlsch as AccZlsch,
*    clearingacct.waers as AccWaers,
*    clearingacct.hktid as AccHktid,
*    clearingacct.sland as AccSland,
*    clearingacct.gehvk as Gehvk,
*    compcode.Country,
*    bnka.Region,
*    bnka.SWIFTCode as swift_code,
*    bnka.Bank as bank_no,
*    HBacc.CompanyCode as HBBukrs,
*    HBacc.HouseBank,
*    HBacc.HouseBankAccount,
*    HBacc.GLAccount
*
*}
*
*--------------------------------
*
*ZTRM_C_BANKFILE
*
*@Metadata.layer: #CORE
*@UI.headerInfo: {
*    typeName: 'Upload Funding Wire template',
*    typeNamePlural: 'Upload Funding Wire template',
*    title: {
*        value: 'Title',
*        type: #STANDARD
*    },
*    description: { value: 'Filename' }
*}
*annotate entity ZTRM_C_BANKFILE with
*{
*  @UI.facet: [
*      /* Header Fecets and Datapoints */
*      { purpose: #HEADER,             id:'HDR_USER',        type: #DATAPOINT_REFERENCE,      position: 10, targetQualifier: 'end_user'                                             },
*      { purpose: #HEADER,             id:'HDR_FILE',        type: #DATAPOINT_REFERENCE,      position: 20, targetQualifier: 'Local_Last_Changed_At'                                },
*      { purpose: #HEADER,             id:'HDR_STATUS',      type: #DATAPOINT_REFERENCE,      position: 30, targetQualifier: 'status'                                               },
*  //**----  Body facets
*      { label: 'File Information',    id: 'Attachment',     type: #COLLECTION,               position: 10                                                                        },
*      { label: 'Invoice Details',     id: 'Invoicedet',     type: #IDENTIFICATION_REFERENCE, position: 10,                             parentId: 'File',        purpose: #STANDARD },
*      {                               id: 'Upload',         type: #FIELDGROUP_REFERENCE,     position: 20  ,targetQualifier: 'Upload', parentId: 'Attachment',  purpose: #STANDARD },
*
*  //** --- Excel data Facet **
*      { label: 'Excel Data',          id: 'Data',           type: #LINEITEM_REFERENCE,       position: 30,  targetElement: '_bank_excel', purpose: #STANDARD } ]// , hidden: #(HideExcel) } ]
*
*
*  @UI: { lineItem:       [ { position: 10, importance: #HIGH , label: 'Person Responsible'}  ] ,
*         identification: [ { position: 10 , label: 'Person Responsible' } ],
*         dataPoint:        { title: 'Responsible Person', targetValueElement: 'end_user' } }
*  end_user;
*  @UI: { lineItem:       [ { position: 20, importance: #HIGH , label: 'Processing Status'} ] ,
*         identification: [ { position: 20 , label: 'Processing Status' } ] ,
*         dataPoint:        { title: 'Processing Status', targetValueElement: 'status' ,criticality: 'CriticalityStatus' ,criticalityRepresentation: #WITHOUT_ICON} }
*  status;
*  @UI: { fieldGroup:     [ { position: 50, qualifier: 'Upload' , label: 'Attachment'} ]}
*  @UI: { identification: [ { position: 30 , label: 'File' } ] }
*  Attachment;
*
*  @UI.hidden: true
*  MimeType;
*
*  @UI.hidden: true
*  Filename;
*  @UI: { dataPoint:{ title: 'Last Action On', targetValueElement: 'Local_Last_Changed_At' } }
*  Local_Last_Changed_At;
*
*}
*
*------------------------------
*
*
*ZTRM_C_BANKDATA
*
*@Metadata.layer: #CORE
*@UI.headerInfo: {
*    typeName: 'Upload the Bank transfer file',
*    typeNamePlural: 'Upload the Bank transfer file',
*    title: {
*        value: 'Title',
*        type: #STANDARD
*    },
*    description: { value: 'StatusIcon' }
*}
*annotate entity ZTRM_C_BANKDATA with
*{
*
*  @UI.facet: [{
*      id: 'BNK',
*      type: #FIELDGROUP_REFERENCE,
*      purpose: #STANDARD,
*      label: 'Payment request details',
*      targetQualifier: 'PaymentDetails'
*   }]
*
*   @UI.lineItem: [ { navigationAvailable: false } ]
*
*   @UI.lineItem: [{ position: 1 }]
*   end_user;
*
*   @UI.lineItem: [{ position: 10 , label: 'Serial Number', navigationAvailable: false },
*      { type: #FOR_ACTION, dataAction: 'createReq', invocationGrouping: #CHANGE_SET, label: 'Create Payment Request' }]
*      @UI.fieldGroup: [{ position: 10 , label: 'Serial Number', qualifier: 'PaymentDetails' }]
*   Snro;
*
*
*   @UI.lineItem: [{ position: 20 , label: 'Request Status', navigationAvailable: false, criticality: 'CriticalityStatus', criticalityRepresentation: #WITH_ICON }]
*   @UI.fieldGroup: [{ position: 20 , label: 'Request Status', qualifier: 'PaymentDetails' }]
*   StatusIcon;
*
*   @UI.lineItem: [{ position: 30 , label: 'Funding Template', navigationAvailable: false }]
*   @UI.fieldGroup: [{ position: 30 , label: 'Funding Template', qualifier: 'PaymentDetails' }]
*   Rpcode;
*
*   @UI.lineItem: [{ position: 40 , label: 'Amount', navigationAvailable: false }]
*   @UI.fieldGroup: [{ position: 40 , label: 'Amount', qualifier: 'PaymentDetails' }]
*   rwbtr;
*
*   @UI.hidden: true
*   @UI.lineItem: [{ position: 50 , label: 'Currency', navigationAvailable: false }]
*   @UI.fieldGroup: [{ position: 50 , label: 'Currency', qualifier: 'PaymentDetails' }]
*   Waers;
*
*   @UI.lineItem: [{ position: 60 , label: 'Reference text', navigationAvailable: false }]
*   @UI.fieldGroup: [{ position: 60 , label: 'Reference text', qualifier: 'PaymentDetails' }]
*   RpText;
*
*   @UI.lineItem: [{ position: 70 , label: 'Key Number', navigationAvailable: false },
*      { type: #FOR_ACTION, dataAction: 'releasePayment', invocationGrouping: #CHANGE_SET, label: 'Release Payment' }]
*      @UI.fieldGroup: [{ position: 70 , label: 'Key Number', qualifier: 'PaymentDetails' }]
*   Keyno;
*
*   @UI.lineItem: [{ position: 80 , label: 'Message', navigationAvailable: false, criticality: 'CriticalityStatus', criticalityRepresentation: #WITH_ICON  }]
*   @UI.fieldGroup: [{ position: 80 , label: 'Message', qualifier: 'PaymentDetails' }]
*   Message;
*
*   @UI.lineItem: [{ position: 90 , label: 'Release Status', navigationAvailable: false, criticality: 'RelCriticality', criticalityRepresentation: #WITH_ICON }]
*   @UI.fieldGroup: [{ position: 90 , label: 'Release Status', qualifier: 'PaymentDetails' }]
*   ReleaseStatus;
*
*   @UI.lineItem: [{ position: 100 , label: 'Run Date', navigationAvailable: false }]
*   @UI.fieldGroup: [{ position: 100 , label: 'Run Date', qualifier: 'PaymentDetails' }]
*   RunDate;
*
*   @UI.lineItem: [{ position: 110 , label: 'Run ID', navigationAvailable: false },
*   { type: #FOR_ACTION, dataAction: 'payPayrq', invocationGrouping: #CHANGE_SET, label: 'Pay Requested Payment' }]
*   @UI.fieldGroup: [{ position: 110 , label: 'Run ID', qualifier: 'PaymentDetails' }]
*   RunId;
*
*   @UI.lineItem: [{ position: 120 , label: 'Payment status', navigationAvailable: false, criticality: 'PayCriticality', criticalityRepresentation: #WITH_ICON }]
*    @UI.fieldGroup: [{ position: 120 , label: 'Payment status', qualifier: 'PaymentDetails' }]
*   PaymentStatus;
*
*   @UI.lineItem: [{ position: 130 , label: 'Value date for payment request', navigationAvailable: false }]
*    @UI.fieldGroup: [{ position: 130 , label: 'Value date for payment request', qualifier: 'PaymentDetails' }]
*   Valut;
*
*   @UI.lineItem: [{ position: 140 , label: 'Posting date', navigationAvailable: false }]
*    @UI.fieldGroup: [{ position: 140 , label: 'Posting date', qualifier: 'PaymentDetails' }]
*   Pdate;
*
*   @UI.lineItem: [{ position: 150 , label: 'Created on', navigationAvailable: false }]
*    @UI.fieldGroup: [{ position: 150 , label: 'Created on', qualifier: 'PaymentDetails' }]
*    CreatedOn;
*
*    @UI.lineItem: [{ position: 160 , label: 'Created at', navigationAvailable: false }]
*    @UI.fieldGroup: [{ position: 160 , label: 'Created at', qualifier: 'PaymentDetails' }]
*    CreatedAt;
*
*
*
*}
*
*--------------------------
*
*Behaviour Definitions
*
*ZTRM_I_BANKFILE
*
*
*managed implementation in class zbp_trm_i_bankfile unique;
*strict ( 2 );
*with draft;
*
*define behavior for ZTRM_I_BANKFILE alias File
*persistent table ztrm_a_bankfile
*lock master
*total etag end_user
*draft table ztrm_d_bankfile
*authorization master ( instance )
*etag master end_user
*{
*  create ( features : global );
*  update ( features : global );
*  delete ( features : global );
*
*  // Logic to convert uploaded excel into internal table and save to the child entity is written here
*  action ( features : instance ) uploadExcelData  result [1] $self;
*
*  association _bank_excel { create ( features : global ); with draft; }
*
*  // Logic to trigger action uploadExcelData
*  determination UploadAttachment on modify { field Filename ; }
*  draft action Edit ;
*  draft action Activate;
*  draft action Discard;
*  draft action Resume;
*  draft determine action Prepare ;
*
*  mapping for ztrm_a_bankfile {
*    Attachment = attachment;
*    Filename = filename;
*    Last_Changed_At = last_changed_at;
*    Local_Created_At = local_created_at;
*    Local_Created_By = local_created_by;
*    Local_Last_Changed_At = local_last_changed_at;
*    Local_Last_Changed_By = local_last_changed_by;
*    MimeType = mimetype;
*    end_user = end_user;
*    status = status;
*  }
*}
*
*define behavior for ZTRM_I_BANKDATA alias BankData
*persistent table ztrm_a_bankdata
*lock dependent by _bank_file
*draft table ztrm_d_bankdata
*authorization dependent by _bank_file
*//etag master <field_name>
*{
*  update ( features : instance ) ;
*  delete ( features : instance ) ;
*  field ( readonly ) end_user;
*  field ( readonly ) CreatedOn, CreatedAt, Snro, StatusIcon, Rpcode, rwbtr, Waers, RpText, Keyno, Message, ReleaseStatus,
*    RunDate, RunId, Valut, Pdate, PaymentStatus;
*  association _bank_file { with draft; }
*  // Logic to process the uploaded data from excel
*  action ( features : instance ) createReq result [1] $self;
*
*  // Logic to process the uploaded data from excel
*  action ( features : instance ) releasePayment result [1] $self;
*
*  // Logic to process the uploaded data from excel
*  action ( features : instance )  payPayrq result [1] $self;
*
*  mapping for ztrm_a_bankdata {
*
*    end_user = end_user;
*    CreatedOn = created_on;
*    CreatedAt = created_at;
*    Snro = snro;
*    StatusIcon = status_icon;
*    Rpcode = rpcode;
*    rwbtr = rwbtr;
*    Waers = waers;
*    RpText = rp_text;
*    Keyno = keyno;
*    Message = message;
*    ReleaseStatus = release_status;
*    RunDate = run_date;
*    RunId = run_id;
*    Valut = valut;
*    Pdate = pdate;
*    PaymentStatus = payment_status;
*    Title = title;
*    CriticalityStatus = criticalitystatus;
*    RelCriticality = relcriticality;
*    PayCriticality = paycriticality;
*  }
*
*}
*
*------------------------
*
*ZTRM_C_BANKFILE
*
*projection;
*strict ( 2 );
*use draft;
*
*define behavior for ZTRM_C_BANKFILE
*{
*  use update;
*  use delete;
*
*  use action uploadExcelData;
*
*  use action Edit;
*  use action Activate;
*  use action Discard;
*  use action Resume;
*  use action Prepare;
*
*  use association _bank_excel { create; with draft; }
*}
*
*define behavior for ZTRM_C_BANKDATA
*{
*  use update;
*  use delete;
*
*  use action createReq;
*  use action releasePayment;
*  use action payPayrq;
*
*  use association _bank_file { with draft; }
*}
*
*------------------------
*
*Service Definitions
*
*ZTRM_BANKDATA
*
*@EndUserText.label: 'Service definition for Bank Transfer'
*define service ZTRM_BANKDATA {
*  expose ZTRM_C_BANKFILE as bankfile;
*  expose ZTRM_C_BANKDATA as bankdata;
*}
*
*-----------------------
*ZTRM_UI_BANKDATA_O2
*
*---------------------
*
*BSP APP:
*ZZ1_TRM_MFNDWIR
*
*---------------------
*
*Authorization object
*
*ZTRM_FNDWR
*
*-----------------------
*Fiori User Interface
*
*ZC_TRM
*
*Fiori Launchpad AppDescr ID    1B1265D081481EEF9DEA6B2EAC424206
*Description                    Upload Funding Wire
*
*
* Application Type
* Transaction
* Fiori ID                       ZVE002
* Technical Catalog              ZC_TRM
* Semantic Object                ZBankFundWire
* Action                         massUpload
* Target Mapping ID              1B1265D081481EEF9DEA6B2EAC424206_TM
* Target Application Title
* Target Mapping Information
* UI5 Component ID               vistracorp.trm.fundingwire.bankfiledata
* BSP Application                ZZ1_TRM_MFNDWIR
* ICF Path                       /sap/bc/ui5_ui5/sap/zz1_trm_mfndwir
* Additional Parameters
* Suppress Tile
* Desktop
* Tablet
*
*
*----------------------------------------------------------
*ZBP_TRM_I_BANKFILE
*
*CLASS lhc_File DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR File RESULT result.
*
*    METHODS get_global_features FOR GLOBAL FEATURES
*      IMPORTING REQUEST requested_features FOR File RESULT result.
*
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR File RESULT result.
*
*    METHODS uploadExcelData FOR MODIFY
*      IMPORTING keys FOR ACTION File~uploadExcelData RESULT result.
*
*    METHODS UploadAttachment FOR DETERMINE ON MODIFY
*      IMPORTING keys FOR File~UploadAttachment.
*
*ENDCLASS.
*
*CLASS lhc_File IMPLEMENTATION.
*
*  METHOD get_instance_features.
*
*    READ ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*             ENTITY file
*               FIELDS ( end_user )
*                  WITH CORRESPONDING #( keys )
*                RESULT DATA(lt_file).
*
*
*    result = VALUE #( FOR lwa_file IN lt_file ( %key = lwa_file-%key
*                                               %is_draft = lwa_file-%is_draft
*                                               %features-%action-uploadexceldata = COND #( WHEN lwa_file-%is_draft = '00'
*                                                                                           THEN if_abap_behv=>fc-f-read_only
*                                                                                           ELSE if_abap_behv=>fc-f-unrestricted ) ) ).
*
*  ENDMETHOD.
*
*  METHOD get_global_features.
*
*    result-%assoc-_bank_excel = if_abap_behv=>fc-o-disabled.
*    result-%delete = if_abap_behv=>mk-off.
*
*    "SOC Auth Obj check
*    AUTHORITY-CHECK OBJECT 'ZTRM_FNDWR'
*        ID 'ACTVT'      FIELD '01'.
*
*    IF sy-subrc <> 0.
*      result-%create = if_abap_behv=>fc-o-disabled.
*      result-%update = if_abap_behv=>fc-o-disabled.
*      result-%delete = if_abap_behv=>fc-o-disabled.
*    ENDIF.
*    "EOC Auth Obj check.
*
*  ENDMETHOD.
*
*  METHOD get_instance_authorizations.
*
*  ENDMETHOD.
*
*  METHOD uploadExcelData.
*
**The type definition resembling the structure of the rows in the worksheet selection.
*    TYPES: BEGIN OF lty_excel,
*             snro    TYPE string,
*             rpcode  TYPE string,
*             rwbtr   TYPE string,
*             waers   TYPE string,
*             rp_text TYPE string,
*             valut   TYPE string,
*             pdate   TYPE string,
*           END OF lty_excel,
*           ltt_row TYPE STANDARD TABLE OF lty_excel.
*
*** Data declarations
*    DATA: lt_rows_csv    TYPE STANDARD TABLE OF string,
*          lv_content     TYPE string,
*          lo_conv        TYPE REF TO cl_abap_conv_in_ce,
*          lwa_excel_data TYPE ztrm_a_bankdata,
*          lt_excel_data  TYPE STANDARD TABLE OF ztrm_a_bankdata,
*          lv_amount      TYPE char23,
*          lv_snro        TYPE char10.
*
*    DATA: lv_file_content TYPE xstring,
*          lt_rows         TYPE ltt_row,
*          lv_date         TYPE dats,
*          lv_pdate        TYPE string,
*          lv_valut        TYPE string.
*    DATA: lt_att_create TYPE TABLE FOR CREATE ztrm_i_bankfile\_bank_excel.
*
*    CONSTANTS: lc_csv  TYPE char255 VALUE 'text/csv',
*               lc_xls  TYPE char255 VALUE 'application/vnd.ms-excel',
*               lc_xlsx TYPE char255 VALUE 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.
*
*** Read the parent instance
*    READ ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*      ENTITY file
*      ALL FIELDS WITH
*      CORRESPONDING #( keys )
*      RESULT DATA(lt_inv).
*
*** Get attachment value from the instance
*    DATA(lv_attachment) = lt_inv[ 1 ]-attachment.
*
**Try to check excel data
**The type definition resembling the structure of the rows in the worksheet selection.
*    IF lt_inv[ 1 ]-mimetype = lc_xls OR
*       lt_inv[ 1 ]-mimetype = lc_xlsx.
*
*      lv_file_content = lv_attachment.
*
** Process the .xlsx file content
*      DATA(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_file_content )->read_access( ).
*      DATA(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).
*
** Extract the data from Excel object
*      DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
*      DATA(lo_execute) = lo_worksheet->select( lo_selection_pattern
*     )->row_stream(
*     )->operation->write_to( REF #( lt_rows ) ).
*      lo_execute->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
*                 )->if_xco_xlsx_ra_operation~execute( ).
*
*      DELETE lt_rows INDEX 1. "remove header row
*
*      "Mapping file data to entity
*      IF lt_rows IS NOT INITIAL.
*
*        LOOP AT lt_rows INTO DATA(lwa_row).
*
*          lwa_excel_data-rpcode = lwa_row-rpcode.
*          lwa_excel_data-snro = CONV #( lwa_row-snro ).
*          lv_amount = lwa_row-rwbtr.
*          lwa_excel_data-rwbtr = CONV #( lv_amount ).
*          lwa_excel_data-waers = lwa_row-waers.
*          lwa_excel_data-rp_text = lwa_row-rp_text.
*
*          "converting date from MM.DD.YYYY to YYYYMMDD
*          "SOC FITT-12856 Change of Date Format in E002 - Funding Wire Template
*          lwa_row-valut = replace( val = lwa_row-valut sub = `.` with = `/`  occ = 0 ).
*
*          CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
*            EXPORTING
*              date_external = lwa_row-valut
*            IMPORTING
*              date_internal = lv_date
*            EXCEPTIONS
*              date_external_is_invalid = 1
*              others                   = 2.
*
*          "EOC FITT-12856 Change of Date Format in E002 - Funding Wire Template
*          lwa_excel_data-valut = lv_date.
*          CLEAR: lv_Date.
*
*          "SOC FITT-12856 Change of Date Format in E002 - Funding Wire Template
*          lwa_row-pdate = replace( val = lwa_row-pdate sub = `.` with = `/`  occ = 0 ).
*
*          CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
*            EXPORTING
*              date_external = lwa_row-pdate
*            IMPORTING
*              date_internal = lv_date
*            EXCEPTIONS
*              date_external_is_invalid = 1
*              others                   = 2.
*
*          "EOC FITT-12856 Change of Date Format in E002 - Funding Wire Template
*
*          lwa_excel_data-pdate = lv_date.
*          CLEAR: lv_Date.
*
*          lwa_excel_data-created_at = sy-uzeit .
*          lwa_excel_data-created_on = sy-datum.
*          lwa_excel_data-end_user = sy-uname.
*          lwa_excel_data-title = 'Funding Wire Upload'(001).
*
*          APPEND lwa_excel_data TO lt_excel_data.
*          CLEAR: lwa_row, lwa_excel_data.
*
*        ENDLOOP.
*
*      ENDIF.
*
** Process the .csv file content
*    ELSEIF lt_inv[ 1 ]-mimetype = lc_csv.
*** Convert excel file with CSV format into internal table of type string
*      lo_conv = cl_abap_conv_in_ce=>create( input = lv_attachment ).
*      lo_conv->read( IMPORTING data = lv_content ).
*
*** Split the string table to rows
*      SPLIT lv_content AT cl_abap_char_utilities=>cr_lf INTO TABLE lt_rows_csv.
*
*      DELETE lt_rows_csv INDEX 1.
*
*** Process the rows and append to the internal table
*      LOOP AT lt_rows_csv INTO DATA(lwa_row_csv).
*
*        SPLIT lwa_row_csv AT ',' INTO lv_snro
*                                 lwa_excel_data-rpcode
*                                 lv_amount
*                                 lwa_excel_data-waers
*                                 lwa_excel_data-rp_text
*                                 lv_valut
*                                 lv_pdate.
*
*        lwa_excel_data-snro = CONV #( lv_snro ).
*        lwa_excel_data-rwbtr = CONV #( lv_amount ).
*        lwa_excel_data-created_at = sy-uzeit .
*        lwa_excel_data-created_on = sy-datum.
*        lwa_excel_data-end_user = sy-uname.
*        lwa_excel_data-title = 'Funding Wire Upload'(001).
*
*        "converting date from MM.DD.YYYY to YYYYMMDD
*        "SOC FITT-12856 Change of Date Format in E002 - Funding Wire Template
*          lv_valut = replace( val = lv_valut sub = `.` with = `/`  occ = 0 ).
*
*          CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
*            EXPORTING
*              date_external = lv_valut
*            IMPORTING
*              date_internal = lwa_excel_data-valut
*            EXCEPTIONS
*              date_external_is_invalid = 1
*              others                   = 2.
*
*          "EOC FITT-12856 Change of Date Format in E002 - Funding Wire Template
*
*        CLEAR: lv_valut.
*
*          "SOC FITT-12856 Change of Date Format in E002 - Funding Wire Template
*          lv_pdate = replace( val = lv_pdate sub = `.` with = `/`  occ = 0 ).
*
*          CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
*            EXPORTING
*              date_external = lv_pdate
*            IMPORTING
*              date_internal = lwa_excel_data-pdate
*            EXCEPTIONS
*              date_external_is_invalid = 1
*              others                   = 2.
*
*          "EOC FITT-12856 Change of Date Format in E002 - Funding Wire Template
*
*        CLEAR: lv_pDate.
*
*        APPEND lwa_excel_data TO lt_excel_data.
*
*        CLEAR: lwa_row_csv, lwa_excel_data.
*      ENDLOOP.
*    ENDIF.
*
*** Delete duplicate records
*    DELETE ADJACENT DUPLICATES FROM lt_excel_data.
*    DELETE lt_excel_data WHERE rpcode IS INITIAL.
*
*** Prepare the datatypes to store the data from internal table lt_excel_data to child entity through EML
*
*    lt_att_create = VALUE #( (  %cid_ref  = keys[ 1 ]-%cid_ref
*                                %is_draft = keys[ 1 ]-%is_draft
*                                end_user  = keys[ 1 ]-end_user
*                                %target   = VALUE #( FOR ls_data IN lt_excel_data ( %cid       = |{ ls_data-snro }|
*                                                                                   %is_draft   = keys[ 1 ]-%is_draft
*                                                                                   end_user    = sy-uname
*                                                                                   rpcode  = ls_data-rpcode
*                                                                                   rwbtr       = ls_data-rwbtr
*                                                                                   waers       = ls_data-waers
*                                                                                   rptext  = ls_data-rp_text
*                                                                                   snro     = ls_data-snro
*                                                                                   createdat     = ls_data-created_at
*                                                                                   createdon   = ls_data-created_on
*                                                                                   valut = ls_data-valut
*                                                                                   pdate = ls_data-pdate
*                                                                                   title = ls_data-title
*                                                                                  %control = VALUE #( end_user    = if_abap_behv=>mk-on
*                                                                                                      rpcode  = if_abap_behv=>mk-on
*                                                                                                      rwbtr       = if_abap_behv=>mk-on
*                                                                                                      waers       = if_abap_behv=>mk-on
*                                                                                                      rptext  = if_abap_behv=>mk-on
*                                                                                                      snro     = if_abap_behv=>mk-on
*                                                                                                      createdat     = if_abap_behv=>mk-on
*                                                                                                      createdon    = if_abap_behv=>mk-on
*                                                                                                      valut = if_abap_behv=>mk-on
*                                                                                                      pdate = if_abap_behv=>mk-on
*                                                                                                      title = if_abap_behv=>mk-on ) ) ) ) ).
*    READ ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY file
*    BY \_bank_excel
*    ALL FIELDS WITH
*    CORRESPONDING #( keys )
*    RESULT DATA(lt_excel).
*
** Delete already existing entries from child entity
*    MODIFY ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY bankdata
*    DELETE FROM VALUE #( FOR lwa_excel IN lt_excel (  %is_draft = lwa_excel-%is_draft
*                                                     %key      = lwa_excel-%key ) )
*    MAPPED DATA(lt_mapped_delete)
*    REPORTED DATA(lt_reported_delete)
*    FAILED DATA(lt_failed_delete).
*
*** Create the records from the new attached CSV file
*    MODIFY ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY file
*    CREATE BY \_bank_excel
*    AUTO FILL CID
*    WITH lt_att_create.
*
*
*    APPEND VALUE #( %tky = lt_inv[ 1 ]-%tky ) TO mapped-file.
*    APPEND VALUE #( %tky = lt_inv[ 1 ]-%tky
*                    %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
*                                                  text = 'Excel Data Uploaded'(002) )
*                   ) TO reported-file.
*
*    "Update the status to bankfile
*    MODIFY ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY file
*    UPDATE FROM VALUE #( ( %is_draft = keys[ 1 ]-%is_draft
*                           end_user  = sy-uname
*                           status     =  'P'
*                           %control  = VALUE #( status = if_abap_behv=>mk-on
*                                                title = if_abap_behv=>mk-on ) ) )
*    MAPPED DATA(lt_mapped_update)
*    REPORTED DATA(lt_reported_update)
*    FAILED DATA(lt_failed_update).
*
*    READ ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*       ENTITY file
*       ALL FIELDS WITH
*       CORRESPONDING #( keys )
*       RESULT DATA(lt_file).
*
*
*    result = VALUE #( FOR lwa_file IN lt_file ( %tky   = lwa_file-%tky
*                                               %param = lwa_file ) ).
*
*
*  ENDMETHOD.
*
*  METHOD UploadAttachment.
*
*    SELECT SINGLE end_user INTO @DATA(lv_end_user) FROM ztrm_a_bankfile WHERE end_user = @sy-uname.
*
*** Create one entry for current user, if it does not exist
*    IF sy-subrc <> 0.
*      INSERT ztrm_a_bankfile FROM @( VALUE #( end_user = sy-uname ) ).
*    ENDIF.
*
*    MODIFY ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY file
*    UPDATE FROM VALUE #( FOR key IN keys ( end_user        = key-end_user
*                                           status          = ' ' " Accepted
*                                           %control-status = if_abap_behv=>mk-on ) ).
*
*    IF keys[ 1 ]-%is_draft = '01'.
*
*      MODIFY ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*      ENTITY file
*      EXECUTE uploadexceldata
*      FROM CORRESPONDING #( keys ).
*    ENDIF.
*
*  ENDMETHOD.
*
*
*ENDCLASS.
*
*CLASS lhc_BankData DEFINITION INHERITING FROM cl_abap_behavior_handler.
*
*  PUBLIC SECTION.
*
*    TYPES: tt_map_data TYPE TABLE FOR READ RESULT ztrm_i_bankfile\\bankdata,
*           tt_logs     TYPE TABLE FOR CREATE ztrm_i_fndlog.
*
*  PRIVATE SECTION.
*
*    METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR BankData RESULT result.
*
*    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
*      IMPORTING keys REQUEST requested_authorizations FOR BankData RESULT result.
*
*    "Create Payment Request
*    METHODS createReq FOR MODIFY
*      IMPORTING keys FOR ACTION BankData~createReq RESULT result.
*
*    "Pay Payment Request
*    METHODS payPayrq FOR MODIFY
*      IMPORTING keys FOR ACTION BankData~payPayrq RESULT result.
*
*    "Release payment Request
*    METHODS releasePayment FOR MODIFY
*      IMPORTING keys FOR ACTION BankData~releasePayment RESULT result.
*
*    METHODS preparemessage
*      IMPORTING
*                iv_msgid   TYPE t100-arbgb " Message class
*                iv_msgno   TYPE t100-msgnr " Message number
*                iv_msgty   TYPE sy-msgty OPTIONAL " Message type
*                iv_msgv1   TYPE balm-msgv1 OPTIONAL " Variable 1
*                iv_msgv2   TYPE balm-msgv2 OPTIONAL " Variable 2
*                iv_msgv3   TYPE balm-msgv3 OPTIONAL
*                iv_msgv4   TYPE balm-msgv4 OPTIONAL
*      EXPORTING ev_message TYPE bapiret2-message.
*
*    METHODS GetPartnerAcc
*      IMPORTING it_t018v TYPE ztt_t018v
*                iv_pbukr TYPE pbukr
*                iv_hbkid TYPE hbkid
*                iv_zlsch TYPE dzlsch
*                iv_waers TYPE waers
*                iv_hktid TYPE hktid
*                iv_sland TYPE sland
*      EXPORTING ev_gehvk TYPE gehvk.
*
*    METHODS MapLogsData
*      CHANGING ct_data TYPE tt_map_data
*               ct_logs TYPE tt_logs.
*
*ENDCLASS.
*
*CLASS lhc_BankData IMPLEMENTATION.
*
*  METHOD get_instance_features.
*    READ ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*           ENTITY bankdata
*             FIELDS ( keyno runid releasestatus )
*                WITH CORRESPONDING #( keys )
*              RESULT DATA(lt_bank_file).
*
*    "SOC Auth Obj check
*    AUTHORITY-CHECK OBJECT 'ZTRM_FNDWR'
*        ID 'ACTVT'      FIELD '01'.
*    IF sy-subrc <> 0.
*      "Disable the buttons for create, release and payment if no authorization is provided to user
*      result = VALUE #( FOR lwa_file IN lt_bank_file ( %key = lwa_file-%key
*                                                 %is_draft = lwa_file-%is_draft
*                                                 %features-%update = if_abap_behv=>fc-o-disabled
*                                                 %features-%delete = if_abap_behv=>fc-o-disabled
*                                                 %features-%action-paypayrq =  if_abap_behv=>fc-o-disabled
*                                                 %features-%action-releasepayment = if_abap_behv=>fc-o-disabled
*                                                 %features-%action-createreq = if_abap_behv=>fc-o-disabled ) ).
*
*    ELSE.
*      "EOC Auth Obj check.
*
*      "Enable the buttons for create, release and payment based on statuses
*      result = VALUE #( FOR lwa_file IN lt_bank_file ( %key = lwa_file-%key
*                                                 %is_draft = lwa_file-%is_draft
*                                                 %features-%update = if_abap_behv=>fc-o-disabled
*                                                 %features-%delete = if_abap_behv=>fc-o-disabled
*                                                 %features-%action-paypayrq = COND #( WHEN lwa_file-runid IS NOT INITIAL AND lwa_file-keyno IS NOT INITIAL
*                                                                                             THEN if_abap_behv=>fc-o-disabled
*                                                                                      WHEN lwa_file-runid IS INITIAL AND lwa_file-keyno IS INITIAL
*                                                                                              THEN if_abap_behv=>fc-o-disabled
*                                                                                      WHEN lwa_file-runid IS INITIAL AND lwa_file-keyno IS NOT INITIAL AND lwa_file-releasestatus = 'Released'(003)
*                                                                                             THEN if_abap_behv=>fc-o-enabled
*                                                                                              ELSE if_abap_behv=>fc-o-disabled )
*                                                 %features-%action-releasepayment = COND #( WHEN lwa_file-keyno IS NOT INITIAL AND lwa_file-releasestatus IS NOT INITIAL
*                                                                                             THEN if_abap_behv=>fc-o-disabled
*                                                                                              WHEN lwa_file-keyno IS NOT INITIAL AND lwa_file-runid IS INITIAL AND lwa_file-releasestatus IS INITIAL
*                                                                                             THEN if_abap_behv=>fc-o-enabled
*                                                                                              ELSE if_abap_behv=>fc-o-disabled )
*                                                 %features-%action-createreq = COND #( WHEN lwa_file-keyno IS NOT INITIAL
*                                                                                             THEN if_abap_behv=>fc-o-disabled
*                                                                                       WHEN lwa_file-keyno IS INITIAL
*                                                                                             THEN if_abap_behv=>fc-o-enabled
*                                                                                              ELSE if_abap_behv=>fc-o-enabled ) ) ).
*
*
*    ENDIF.
*  ENDMETHOD.
*
*  METHOD get_instance_authorizations.
*  ENDMETHOD.
*
*  "Method for creating payment request
*  METHOD createReq.
*
*    "type declaration for repetative code
*    TYPES: BEGIN OF lty_rpcode,
*             include TYPE  fibl_rpcode.
*    TYPES: gsber      TYPE  gsber,
*           rp_text    TYPE  rpcode_text,
*           rwbtr      TYPE  rwbtr,
*           paymt_ref  TYPE  kidno,
*           xpore      TYPE  prq_xpore,
*           pbukr      TYPE  fi_pbukr,
*           zlsch      TYPE  dzlsch,
*           waers      TYPE  waers,
*           banks      TYPE  banks,
*           bukrs      TYPE  prq_zbukr,
*           hbkid      TYPE  hbkid,
*           rpcode     TYPE  rpcode,
*           hktid      TYPE  hktid,
*           chain      TYPE  chainid,
*           bankl      TYPE  bankk,
*           bankn      TYPE  bankn,
*           bkont      TYPE  bkont,
*           bkref      TYPE  bkref,
*           koinh      TYPE  koinh_fi,
*           ptype      TYPE  gpa1t_cfm,
*           partn      TYPE  gpa1r_cfm,
*           parta      TYPE  partac,
*           xkdfb      TYPE  xkdfb_042e,
*           pmtmthsupl TYPE  uzawe,
*           END OF lty_rpcode.
*
** Types for PAYRQ
*    TYPES:
*      lty_address_data TYPE STANDARD TABLE OF bapi2021_address,
*      lty_bank_data    TYPE STANDARD TABLE OF bapi2021_bank
*                         WITH KEY account_role,
*      lty_reftxt       TYPE STANDARD TABLE OF bapi2021_reftext,
*      lty_extension    TYPE STANDARD TABLE OF bapiparex.
*
*    "Data declarations for bapi
*    DATA: lwa_rpcode        TYPE lty_rpcode,
*          lt_rpcode         TYPE STANDARD TABLE OF lty_rpcode,
*          lwa_return        TYPE bapiret2,                  "#EC NEEDED
*          lwa_return_commit TYPE bapiret2,
*          lv_keyno          TYPE prq_keyno,
*          lv_rpcode         TYPE rpcode.
*
*    DATA: lwa_bnka_payrq TYPE bnka,
*          lt_bnka_payrq  TYPE STANDARD TABLE OF bnka.
*
*    "Declarations for BAPI create payment request
*    DATA: lt_address_data      TYPE lty_address_data,
*          lt_bank_data         TYPE lty_bank_data,
*          lwa_bank_data        TYPE LINE OF lty_bank_data,
*          lwa_origin           TYPE bapi2021_origin,
*          lwa_organizations    TYPE bapi2021_organisations,
*          lwa_accounts         TYPE bapi2021_accounts,
*          lwa_amounts          TYPE bapi2021_amounts,
*          lwa_dates            TYPE bapi2021_dates,
*          lwa_paym_control     TYPE bapi2021_paymentctrl,
*          lwa_references       TYPE bapi2021_references,
*          lwa_central_bank_rep TYPE bapi2021_centralbankrep,
*          lwa_instructions     TYPE bapi2021_instructions,
*          lt_reftxt            TYPE lty_reftxt,
*          lt_extension         TYPE lty_extension,
*          lwa_corrdoc          TYPE  bapi2021_corrdoc,
*          lwa_t042z            TYPE t042z.
*
*    "fibl_check_amount_for_format declarations
*    DATA:
*      lv_format          TYPE formi_fpm,
*      lwa_tfpm042f       TYPE tfpm042f,
*      lv_trunc_amount    TYPE prq_amtfc,
*      lv_num_amount(13)  TYPE n,
*      lv_char_amount(17) TYPE c.
*
*    "declarations get_address_bank
*    DATA: lwa_addr1_sel    TYPE addr1_sel,
*          lwa_sadr         TYPE sadr,
*          lwa_address_data TYPE LINE OF lty_address_data,
*          lwa_t001_adr     TYPE t001.
*
*    " selection from T018V
*    DATA: lv_fibl_pstng_date TYPE fibl_mainpay_101-pstng_date,
*          lt_t018v           TYPE TABLE OF t018v,
*          lwa_t012k_paccb    TYPE t012k,
*          lt_t012k_paccb     TYPE STANDARD TABLE OF t012k,
*          lv_gehvk           TYPE t018v-gehvk,
*          lv_valut           TYPE reguh-valut,
*          lv_iban            TYPE iban,
*          lt_logs            TYPE tt_logs.
*
** Constants
** Constants: types of business-partner
*    CONSTANTS: lc_origin_bank  TYPE tfiblorigin-origin VALUE 'TR-CM-BT',
*               lc_type_bank(2) VALUE '03',
*               lc_msgcls       TYPE t100-arbgb VALUE 'FIBL_RPCODE',
*               lc_success      TYPE sy-msgty VALUE 'S',
*               lc_error        TYPE sy-msgty VALUE 'E',
*               lc_abort        TYPE sy-msgty VALUE 'A',
*               lc_partnerrole  TYPE prq_partro VALUE '02',
*               lc_addr_grp     TYPE adrg-addr_group VALUE 'CA01',
*               lc_acct_type    TYPE koart VALUE 'S',
*               lc_account_role TYPE prq_bnktyp VALUE '2'.
*
*
*    READ ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY bankdata
*    ALL FIELDS WITH
*    CORRESPONDING #( keys )
*    RESULT DATA(lt_data_bank).
*
*    IF sy-subrc = 0.
*
*      "Fetch repetative code data
*      SELECT * FROM ztrm_i_rpcode INTO TABLE @DATA(lt_selrpcode)
*      FOR ALL ENTRIES IN @lt_data_bank
*      WHERE rpcode = @lt_data_bank-Rpcode.
*
*      IF sy-subrc = 0.
*        "map the data for House Bank Accounts, Bank master
*        lt_bnka_payrq = CORRESPONDING #( lt_selrpcode MAPPING banks = banks
*                                                              bankl =  bankl
*                                                              provz = region
*                                                              swift = swift_code
*                                                              bnklz = bank_no ).
*
*        lt_rpcode = CORRESPONDING #( lt_selrpcode ).
*        lt_t012k_paccb = CORRESPONDING #( lt_Selrpcode MAPPING bukrs = HBBukrs
*                                                               hbkid = housebank
*                                                               hktid = housebankaccount
*                                                               hkont = glaccount ).
*        "Sort & Delete adjacent duplicates if any
*        SORT lt_rpcode.
*        SORT lt_t012k_paccb.
*        SORT lt_bnka_payrq.
*        DELETE ADJACENT DUPLICATES FROM lt_rpcode.
*        DELETE ADJACENT DUPLICATES FROM lt_t012k_paccb.
*        DELETE ADJACENT DUPLICATES FROM lt_bnka_payrq.
*
*      ENDIF.
*
*    ENDIF.
*
*    "Prepare the data for bapi call
*    LOOP AT lt_data_bank ASSIGNING FIELD-SYMBOL(<lfs_create>).
*
*      READ TABLE lt_selrpcode INTO DATA(lwa_sel_rpcode) WITH KEY rpcode = <lfs_create>-rpcode.
*
*      IF sy-subrc = 0.
*
*        "map the posting date and value date.
*        lv_fibl_pstng_date = <lfs_create>-Pdate.
*        lv_valut = <lfs_create>-Valut.
*        IF lv_valut IS INITIAL.
*          lv_valut = sy-datum.
*        ENDIF.
*
*        MOVE-CORRESPONDING lwa_sel_rpcode TO lwa_rpcode.
*
*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*          EXPORTING
*            input  = lwa_rpcode-partn
*          IMPORTING
*            output = lwa_rpcode-partn.
*
*        "map the amount, currency, and text for rpcode structure
*        lwa_rpcode-rwbtr = <lfs_create>-rwbtr.
*        lwa_rpcode-waers = <lfs_create>-waers.
*        lwa_rpcode-rp_text = <lfs_create>-rptext.
*        IF lwa_rpcode-rwbtr IS NOT INITIAL.
*
*          CLEAR: lv_keyno.
*
*          "prepare rpcode for display in error-log
*          lv_rpcode = | { lwa_rpcode-rpcode ALPHA = OUT } |.
*
*          " fill internal table bank data
*          lwa_bank_data = VALUE #( bank_ref = lwa_rpcode-bkref
*                                      bank_ctry = lwa_rpcode-banks
*                                      bank_key = lwa_rpcode-bankl
*                                      bank_acct = lwa_rpcode-bankn
*                                      acct_hold = lwa_rpcode-koinh
*                                      account_role = lc_account_role
*                                      coll_auth = abap_true  ).
*
**          " fill bank-information
*          READ TABLE lt_bnka_payrq INTO lwa_bnka_payrq
*                    WITH KEY banks = lwa_rpcode-banks
*                             bankl = lwa_rpcode-bankl.
*
*          lwa_bank_data-region = lwa_bnka_payrq-provz.
*          lwa_bank_data-bank_no = lwa_bnka_payrq-bnklz.
*          lwa_bank_data-swift_code = lwa_bnka_payrq-swift.
*          lwa_bank_data-ctrl_key = lwa_rpcode-bkont.
*          APPEND lwa_bank_data TO lt_bank_data.
*
*          " fill organizations structure with company code, sending and paying compcode
*          lwa_organizations = VALUE #( comp_code = lwa_rpcode-pbukr
*                                      pay_comp_code  = lwa_rpcode-bukrs
*                                      send_comp_code = lwa_rpcode-bukrs ).
*
*          " accounts
*          lwa_accounts-acct_type           = lc_acct_type.
*
*          " check payment method for posting
*          CALL FUNCTION 'FI_PAYMENT_METHOD_PROPERTIES'
*            EXPORTING
*              i_zlsch                = lwa_rpcode-zlsch
*              i_zbukr                = lwa_rpcode-bukrs
*            IMPORTING
*              e_t042z                = lwa_t042z
*            EXCEPTIONS
*              error_t042z            = 1
*              error_t042e            = 2
*              error_import_parameter = 3
*              OTHERS                 = 4.
*          IF sy-subrc <> 0.
*            IF sy-msgty = lc_error OR sy-msgty = lc_abort.
*
*              preparemessage(
*              EXPORTING
*              iv_msgid   = sy-msgid
*              iv_msgno   = CONV msgnr( sy-msgno )
*              iv_msgty   = sy-msgty
*              iv_msgv1   = sy-msgv1
*              iv_msgv2   = sy-msgv2
*              iv_msgv3   = sy-msgv3
*              iv_msgv4   = sy-msgv4
*              IMPORTING
*              ev_message = <lfs_create>-message
*              ).
*              <lfs_create>-statusicon = lc_error.
*
*            ENDIF.
*          ENDIF.
*
*          " check amount for methods with payment medium workbench
*          " for ACH-Format amount must be less or equl $99.999.999,99
*          IF NOT lwa_t042z-formi IS INITIAL.
*
*            "logic for fibl_check_amount_for_format
*            CLEAR: lv_format, lwa_tfpm042f, lv_trunc_amount, lv_num_amount, lv_char_amount.
*
*            lv_format = lwa_t042z-formi.
*
*            CALL FUNCTION 'FI_PAYM_FORMAT_READ_PROPERTIES'
*              EXPORTING
*                i_formi            = lv_format
*              IMPORTING
*                e_tfpm042f         = lwa_tfpm042f
*              EXCEPTIONS
*                not_found          = 1
*                parameters_invalid = 2
*                OTHERS             = 3.
*            IF sy-subrc <> 0.
*
*              IF sy-msgty = lc_error OR sy-msgty = lc_abort.
*                preparemessage(
*                EXPORTING
*                iv_msgid   = sy-msgid
*                iv_msgno   = CONV msgnr( sy-msgno )
*                iv_msgty   = sy-msgty
*                iv_msgv1   = sy-msgv1
*                iv_msgv2   = sy-msgv2
*                iv_msgv3   = sy-msgv3
*                iv_msgv4   = sy-msgv4
*                IMPORTING
*                ev_message = <lfs_create>-message
*                ).
*                <lfs_create>-statusicon = lc_error.
*
*              ENDIF.
*            ENDIF.
*
*            " for ACH-Format amount must be less or equl $99.999.999,99
*            IF NOT lwa_tfpm042f-beanz IS INITIAL.
*              IF lwa_tfpm042f-beanz < 13.
*                UNPACK lwa_rpcode-rwbtr TO lv_num_amount(lwa_tfpm042f-beanz).
*                MOVE lv_num_amount(lwa_tfpm042f-beanz) TO lv_trunc_amount.
*
*                IF lv_trunc_amount NE lwa_rpcode-rwbtr.
*                  WRITE lwa_rpcode-rwbtr TO lv_char_amount
*                  CURRENCY lwa_rpcode-waers LEFT-JUSTIFIED.
*
*                  preparemessage(
*                  EXPORTING
*                  iv_msgid   = lc_msgcls
*                  iv_msgno   = CONV msgnr( '129' )
*                  iv_msgty   = lc_error
*                  iv_msgv1   = CONV symsgv( lv_char_amount )
*                  iv_msgv2   = CONV symsgv( lwa_rpcode-waers )
*                  iv_msgv3   = CONV symsgv( lwa_rpcode-zlsch )
*                  iv_msgv4   = CONV symsgv( lv_format )
*                  IMPORTING
*                  ev_message = <lfs_create>-Message
*                  ).
*                  <lfs_create>-statusicon = lc_error.
*
*                ENDIF.
*              ENDIF.
*
*            ENDIF.
*
*            " check amount for methods with payment medium workbench
*            IF NOT lwa_t042z-formi IS INITIAL.
*              CALL FUNCTION 'FIBL_CHECK_AMOUNT_FOR_FORMAT'
*                EXPORTING
*                  im_paym_amount     = lwa_rpcode-rwbtr
*                  im_paym_curr       = lwa_rpcode-waers
*                  im_paym_method     = lwa_rpcode-zlsch
*                  im_format          = lwa_t042z-formi
*                EXCEPTIONS
*                  no_pmw_paym_method = 1
*                  amount_too_large   = 2
*                  paym_method_error  = 3
*                  format_error       = 4
*                  OTHERS             = 5.
*              IF sy-subrc <> 0.
*
*                IF sy-msgty = lc_error OR sy-msgty = lc_abort.
*
*                  preparemessage(
*                  EXPORTING
*                  iv_msgid   = sy-msgid
*                  iv_msgno   = CONV msgnr( sy-msgno )
*                  iv_msgty   = sy-msgty
*                  iv_msgv1   = sy-msgv1
*                  iv_msgv2   = sy-msgv2
*                  iv_msgv3   = sy-msgv3
*                  iv_msgv4   = sy-msgv4
*                  IMPORTING
*                  ev_message = <lfs_create>-Message
*                  ).
*                  <lfs_create>-statusicon = lc_error.
*
*                ENDIF.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*
*
*          "-- fill foreign currency for BAPI amounts structure
*          lwa_amounts-paym_curr    = lwa_rpcode-waers.
*
*          "-- if the payment is done in foreign currency and the domestic
*          "   domestic currency amount has not been specified, the field for the
*          "   demestic currency has to be cleared to make the Create-BAPI doing
*          "   calculation for the domestic amount ---
*          CLEAR lwa_amounts-loc_currcy.
*
*          "* Dates
*          lwa_dates-due_date              = sy-datlo.
*          lwa_dates-value_date_sender     = lv_valut.
*
*          "Fill Payment control structure for bapi
*          lwa_paym_control = VALUE #( housebankid = lwa_rpcode-hbkid
*                                      housebankacctid = lwa_rpcode-hktid
*                                      paycode = lwa_rpcode-rpcode
*                                      indiv_payment = lwa_rpcode-xpore
*                                      no_exchange_rate_diff = lwa_rpcode-xkdfb
*                                      payment_methods = lwa_rpcode-zlsch
*                                      pmtmthsupl = lwa_rpcode-pmtmthsupl ).
*
*          " check bankchain
*          IF NOT lwa_rpcode-chain IS INITIAL.
*            CALL FUNCTION 'FIBL_GET_BANKCHAIN_DATA'
*              EXPORTING
*                im_chainid                = lwa_rpcode-chain
*              TABLES
*                ext_bank_data             = lt_bank_data
*              EXCEPTIONS
*                acct_num_conversion_error = 1
*                OTHERS                    = 2.
*            IF sy-subrc <> 0.
*
*              IF sy-msgty = lc_error OR sy-msgty = lc_abort.
*                preparemessage(
*                  EXPORTING
*                  iv_msgid   = sy-msgid
*                  iv_msgno   = CONV msgnr( sy-msgno )
*                  iv_msgty   = sy-msgty
*                  iv_msgv1   = sy-msgv1
*                  iv_msgv2   = sy-msgv2
*                  iv_msgv3   = sy-msgv3
*                  iv_msgv4   = sy-msgv4
*                  IMPORTING
*                  ev_message = <lfs_create>-Message
*                  ).
*                <lfs_create>-statusicon = lc_error.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*
*          " add * to reference text
*          IF NOT lwa_rpcode-rp_text IS INITIAL.
*            CONCATENATE '*' lwa_rpcode-rp_text INTO lwa_references-item_text.
*          ENDIF.
*          lwa_references-paymt_ref = lwa_rpcode-paymt_ref.
*
*          " fetch origin logsystem
*          CALL FUNCTION 'FIBL_GET_LOGSYS'
*            IMPORTING
*              ex_logsys = lwa_origin-logsystem.
*
*          " fetch business areas
*          " map business area to organization structure
*          CALL FUNCTION 'FIBL_GET_BUS_AREA_BANK'
*            EXPORTING
*              im_comp_code       = lwa_rpcode-bukrs
*              im_housebankid     = lwa_rpcode-hbkid
*              im_paym_method     = lwa_rpcode-zlsch
*              im_paym_curr       = lwa_rpcode-waers
*              im_housebankacctid = lwa_rpcode-hktid
*            IMPORTING
*              ex_bus_area        = lwa_organizations-bus_area_bank  "lv_gsber
*            EXCEPTIONS
*              no_t042y_entry     = 1
*              OTHERS             = 2.
*          IF sy-subrc <> 0.
*
*            IF sy-msgty = lc_error OR sy-msgty = lc_abort.
*
*              preparemessage(
*              EXPORTING
*              iv_msgid   = sy-msgid
*              iv_msgno   = CONV msgnr( sy-msgno )
*              iv_msgty   = sy-msgty
*              iv_msgv1   = sy-msgv1
*              iv_msgv2   = sy-msgv2
*              iv_msgv3   = sy-msgv3
*              iv_msgv4   = sy-msgv4
*              IMPORTING
*              ev_message = <lfs_create>-Message
*              ).
*              <lfs_create>-statusicon = lc_error.
*            ENDIF.
*          ENDIF.
*
*          "map business area to organization structure
**          lwa_organizations-bus_area_bank  = lv_gsber.
*
**---- partner type bank -----
*          CASE lwa_rpcode-ptype.
*            WHEN lc_type_bank.
*
*              "logic to get_address_bank
*              CLEAR: lwa_addr1_sel, lwa_sadr, lwa_address_data, lwa_t001_adr.
*
*              " read company code information for address
*              CALL FUNCTION 'FI_COMPANY_CODE_DATA'
*                EXPORTING
*                  i_bukrs      = lwa_rpcode-pbukr
*                IMPORTING
*                  e_t001       = lwa_t001_adr
*                EXCEPTIONS
*                  system_error = 1
*                  OTHERS       = 2.
*              IF sy-subrc <> 0.
*
*                IF sy-msgty = lc_error OR sy-msgty = lc_abort.
*
*                  preparemessage(
*                  EXPORTING
*                  iv_msgid   = sy-msgid
*                  iv_msgno   = CONV msgnr( sy-msgno )
*                  iv_msgty   = sy-msgty
*                  iv_msgv1   = sy-msgv1
*                  iv_msgv2   = sy-msgv2
*                  iv_msgv3   = sy-msgv3
*                  iv_msgv4   = sy-msgv4
*                  IMPORTING
*                  ev_message = <lfs_create>-Message
*                  ).
*                  <lfs_create>-statusicon = lc_error.
*
*                ENDIF.
*              ENDIF.
*
*              "get address details from sadr based on address number
*              lwa_addr1_sel-addrnumber = lwa_t001_adr-adrnr.
*              IF NOT lwa_t001_adr-adrnr IS INITIAL.
*                CALL FUNCTION 'ADDR_GET'
*                  EXPORTING
*                    address_selection = lwa_addr1_sel
*                    address_group     = lc_addr_grp
*                  IMPORTING
*                    sadr              = lwa_sadr
*                  EXCEPTIONS
*                    parameter_error   = 1
*                    address_not_exist = 2
*                    version_not_exist = 3
*                    internal_error    = 4
*                    OTHERS            = 5.
*                IF sy-subrc = 0.
*
*                  "fill address data structure for bapi
*                  lwa_address_data = VALUE #( formofaddr = lwa_sadr-anred
*                                              name = lwa_sadr-name1
*                                              name_2 = lwa_sadr-name2
*                                              name_3 = lwa_sadr-name3
*                                              name_4 = lwa_sadr-name4
*                                              postl_code = lwa_sadr-pstlz
*                                              city = lwa_sadr-ort01
*                                              pobx_pcd = lwa_sadr-pstl2
*                                              street = lwa_sadr-stras
*                                              po_box = lwa_sadr-pfach
*                                              country = lwa_sadr-land1
*                                              region = lwa_sadr-regio
*                                              langu = lwa_sadr-spras
*                                              addr_no = lwa_sadr-adrnr
*                                              telephone = lwa_sadr-telf1 ).
*
*                ENDIF.
*              ENDIF.
*
*              " no adr given in T001, or no information for adr found
*              IF lwa_address_data-name IS INITIAL.
*                lwa_address_data-name = lwa_t001_adr-butxt.
*              ENDIF.
*              IF lwa_address_data-city IS INITIAL
*              OR lwa_address_data-country IS INITIAL.
*                lwa_address_data-city = lwa_t001_adr-ort01.
*                lwa_address_data-country = lwa_t001_adr-land1.
*              ENDIF.
*              IF lwa_address_data-langu IS INITIAL.
*                lwa_address_data-langu = lwa_t001_adr-spras.
*              ENDIF.
*              lwa_address_data-partner_role = '01'.
*              APPEND lwa_address_data TO lt_address_data.
*
*              lwa_address_data-partner_role = lc_partnerrole.
*              APPEND lwa_address_data TO lt_address_data.
*
*
*              "-- fill amount foreign currency
*              CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXT_31' " AFLE
*                EXPORTING
*                  currency        = lwa_amounts-paym_curr
*                  amount_internal = lwa_rpcode-rwbtr
*                IMPORTING
*                  amount_external = lwa_amounts-paym_amount_long. " AFLE
*
*              " origin
*              lwa_origin-origin = lc_origin_bank.
*              " business areas
*              lwa_organizations-bus_area = lwa_rpcode-gsber.
*
*              "-- Accounts: determine the partner account ---
*              lt_t018v = CORRESPONDING #( lt_selrpcode MAPPING bukrs = AccBukrs
*                                          gehvk = Gehvk
*                                          hbkid = AccHbkid
*                                          zlsch = AccZlsch
*                                          waers = AccWaers
*                                          hktid = AccHktid
*                                          sland = AccSland ).
*
*              "Get the housebank clearing account based on company code,
*              "currency, payment method, house bank, country
*              getpartneracc(
*              EXPORTING
*              it_t018v = lt_t018v
*              iv_pbukr = lwa_rpcode-pbukr
*              iv_hbkid = CONV hbkid( lwa_rpcode-partn ) "lv_hbkid_paccb
*              iv_zlsch = lwa_rpcode-zlsch
*              iv_waers = lwa_rpcode-waers
*              iv_hktid = CONV hktid( lwa_rpcode-parta ) "lv_hktid_paccb
*              iv_sland = lwa_sel_rpcode-Country
*              IMPORTING
*              ev_gehvk = lv_gehvk
*              ).
*
*              " safety check
*              IF lv_gehvk IS INITIAL.
*
*                IF sy-msgty = lc_error OR sy-msgty = lc_abort.
*
*                  preparemessage(
*                  EXPORTING
*                  iv_msgid   = lc_msgcls
*                  iv_msgno   = CONV msgnr( '065' )
*                  iv_msgty   = lc_error
*                  iv_msgv1   = CONV symsgv( lwa_rpcode-pbukr )
*                  iv_msgv2   = CONV symsgv( lwa_rpcode-partn )
*                  iv_msgv3   = CONV symsgv( lwa_rpcode-parta )
*                  iv_msgv4   = CONV symsgv( lwa_rpcode-zlsch )
*                  IMPORTING
*                  ev_message = <lfs_create>-Message
*                  ).
*
*                  <lfs_create>-statusicon = lc_error.
*                ENDIF.
*              ELSE.
*                "Map housebank clearing account to accounts structure fo BAPI
*                lwa_accounts-partner_account = lv_gehvk.
*                lwa_accounts-reconcil_account = lwa_accounts-partner_account.
*              ENDIF.
*
*
*              "---determin glaccount from T012K
*              READ TABLE lt_t012k_paccb INTO lwa_t012k_paccb
*                  WITH KEY bukrs = lwa_rpcode-pbukr
*                           hbkid = lwa_rpcode-partn
*                           hktid = lwa_rpcode-parta.
*
*              lwa_accounts-partner_acct_transfer = lwa_t012k_paccb-hkont.
*
*              IF lv_valut IS INITIAL.
*                lv_valut = sy-datum.
*              ENDIF.
*
*              " dates
*              CALL FUNCTION 'FI_PRQ_CREDIT_DATE_DETERMINE'
*                EXPORTING
*                  im_valut = lv_valut
*                IMPORTING
*                  ex_crval = lwa_dates-value_date_receiver.
*
*              "--- Get IBAN ---
*
*              LOOP AT lt_bank_data ASSIGNING FIELD-SYMBOL(<fs_bank_data>).
*                CLEAR lv_iban.
**                lv_bankn = <fs_bank_data>-bank_acct.
*                CALL FUNCTION 'READ_IBAN_HBA'
*                  EXPORTING
*                    i_banks        = <fs_bank_data>-bank_ctry
*                    i_bankl        = <fs_bank_data>-bank_no
*                    i_bankn        = CONV bankn( <fs_bank_data>-bank_acct ) "lv_bankn
*                    i_bkont        = <fs_bank_data>-ctrl_key
*                    i_bkref        = <fs_bank_data>-bank_ref
*                  IMPORTING
*                    e_iban         = lv_iban
*                  EXCEPTIONS
*                    iban_not_found = 1.
*
*                IF sy-subrc = 0 AND lv_iban IS NOT INITIAL.
*                  <fs_bank_data>-iban = lv_iban.
*                ENDIF.
*              ENDLOOP.
*
*          ENDCASE.
*
*          "-- direction of payment has to be considered outgoing payment has negative sign ---
*          IF lwa_t042z-xeinz IS INITIAL.
*            lwa_amounts-paym_amount_long = - lwa_amounts-paym_amount_long. " AFLE
*          ENDIF.
*
*          "prepare Central bank rep and instructions structures foe BAPI
*          "bank indicator, supplying country and instruction key
*          lwa_central_bank_rep = CORRESPONDING #( lwa_rpcode ).
*          lwa_instructions = CORRESPONDING #( lwa_rpcode ).
*
*          " Create the payment requests
*          IF <lfs_create>-statusicon <> lc_error.
*
*            CALL FUNCTION 'BAPI_PAYMENTREQUEST_CREATE'
*              EXPORTING
*                origin           = lwa_origin
*                organisations    = lwa_organizations
*                accounts         = lwa_accounts
*                amounts          = lwa_amounts
*                value_dates      = lwa_dates
*                paym_control     = lwa_paym_control
*                corr_doc         = lwa_corrdoc
*                references       = lwa_references
*                central_bank_rep = lwa_central_bank_rep
*                instructions     = lwa_instructions
*                releasepost      = abap_true
*                releasepay       = space
*              IMPORTING
*                return           = lwa_return
*                requestid        = lv_keyno
*              TABLES
*                address_data     = lt_address_data
*                bank_data        = lt_bank_data
*                reference_text   = lt_reftxt
*                extensionin      = lt_extension.
*
*            IF NOT lwa_return IS INITIAL.
*
*              "map the error message and status
*              <lfs_create>-statusicon = lc_error.
*              <lfs_create>-message = lwa_return-message.
*
*            ELSE.
*
*              CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION 'NONE'
*                EXPORTING
*                  wait                  = abap_true
*                IMPORTING
*                  return                = lwa_return_commit
*                EXCEPTIONS
*                  system_failure        = 1
*                  communication_failure = 2.
*
*              IF sy-subrc = 0 .
*                "-   write a message about success regarding PAYRQ-creation ---
*                lv_keyno = | { lv_keyno ALPHA = OUT } |.
*                <lfs_create>-keyno = lv_keyno.
*                <lfs_create>-statusicon = lc_success.
*
*                IF lwa_return-message IS INITIAL.
*
*                  preparemessage(
*                  EXPORTING
*                  iv_msgid   = lc_msgcls
*                  iv_msgno   = CONV msgnr( '068' )
*                  iv_msgty   = CONV symsgty( lc_success )
*                  iv_msgv1   = CONV symsgv( lv_keyno )
*                  iv_msgv2   = CONV symsgv( lv_rpcode )
*                  IMPORTING
*                  ev_message = <lfs_create>-Message
*                  ).
*                ELSE.
*                  <lfs_create>-message = lwa_return-message.
*                ENDIF.
*              ELSE.
*                "map the error message and status
*                <lfs_create>-statusicon = lc_error.
*                <lfs_create>-message = lwa_return_commit-message.
*              ENDIF.
*
*            ENDIF.
*
*            CLEAR: lwa_origin, lwa_organizations, lwa_accounts,
*             lwa_amounts, lwa_dates, lwa_paym_control, lwa_references,
*             lwa_central_bank_rep , lwa_instructions ,lt_reftxt, lt_extension,
*             lwa_corrdoc.
*          ENDIF.
*
*        ELSEIF lwa_rpcode-rwbtr IS INITIAL.
*          " no entries with amount ?
*          " MESSAGE w069(fibl_rpcode).
*          preparemessage(
*          EXPORTING
*          iv_msgid   = lc_msgcls
*          iv_msgno   = CONV msgnr( '069' )
*          iv_msgty   = sy-msgty
*          IMPORTING
*          ev_message = <lfs_create>-message
*          ).
*          <lfs_create>-statusicon = lc_error.
*        ENDIF.
*
*      ELSE.
*
*        "Log the error message
*        CONCATENATE 'Repititive code'(005) <lfs_create>-Rpcode 'is invalid'(006)
*                INTO <lfs_create>-message SEPARATED BY space.
*        <lfs_create>-statusicon = lc_error.
*
*      ENDIF.
*
*      CLEAR: lwa_return, lwa_rpcode, lv_keyno,
*             lwa_t012k_paccb, lv_gehvk, lv_fibl_pstng_date,
*             lwa_return_commit, lv_rpcode, lwa_address_data,
*             lwa_bnka_payrq, lt_address_data, lt_bank_data,
*             lwa_bank_data, lwa_t042z, lv_format, lwa_tfpm042f,
*             lv_trunc_amount, lv_num_amount, lv_char_amount,
*             lt_t018v, lwa_addr1_sel, lwa_sadr, lwa_t001_adr,
*              lv_fibl_pstng_date, lwa_t012k_paccb,
*             lv_valut, lv_iban.
*
*
*    ENDLOOP.
*
*    "Update the entity with keyno, status and message
*    MODIFY ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY bankdata
*    UPDATE FIELDS ( keyno statusicon message )
*    WITH CORRESPONDING #( lt_data_bank )
*
*    MAPPED DATA(lt_mapped_status)
*    REPORTED DATA(lt_reported_status)
*    FAILED DATA(lt_failed_status).
*
*    "As logs are required only for success deleting error records.
*    DELETE lt_data_bank WHERE StatusIcon <> 'S'.
*
*    "Map the data to logs table structure ZTRM_A_FUNDLOGS.
*    maplogsdata(
*      CHANGING
*        ct_data = lt_data_bank
*        ct_logs = lt_logs
*    ).
*
*    "Update logs
*    MODIFY ENTITIES OF ztrm_i_fndlog
*    ENTITY ztrm_i_fndlog
*    CREATE
*    AUTO FILL CID
*    WITH lt_logs
*    MAPPED DATA(lt_mapped_stat)
*    REPORTED DATA(lt_reported_stat)
*    FAILED DATA(lt_failed_stat).
*
*    "Get the response updated record
*    READ ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY bankdata
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(bankdata).
*
*    result = VALUE #( FOR bankrec IN bankdata
*    ( %tky = bankrec-%tky %param = bankrec )
*    ).
*
*  ENDMETHOD.
*
*  METHOD payPayrq.
*
*    DATA: lv_budat_f111     TYPE budat_f111,
*          lt_selrequestid   TYPE TABLE OF bapi2021_selrequestid,
*          lwa_selrequestid  TYPE bapi2021_selrequestid,
*          lv_run_date       TYPE bapi2021_pay-payment_run_date,
*          lv_run_id         TYPE bapi2021_pay-payment_run_id,
*          lwa_return        TYPE bapiret2,
*          lwa_return_commit TYPE bapiret2,
*          lv_valut          TYPE valut,
*          lv_xpmw           TYPE xfeld.
*
*    DATA: lwa_logs TYPE ztrm_a_fundlogs,
*          lt_logs  TYPE tt_logs.
*
*    "Read the selected record
*    READ ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY bankdata
*    ALL FIELDS WITH
*    CORRESPONDING #( keys )
*    RESULT DATA(lt_data).
*
*    IF sy-subrc = 0.
*      "Get Paying Company Code for this Payment Request and payment method for request number from PAYRQ table
*      "Get country from T001 table based on paying company code
*      SELECT PaymentRequest, PayingCompanyCode, PaymentMethod, Country
*      FROM ztrm_i_payrq
*      INTO TABLE @DATA(lt_payrq)
*      FOR ALL ENTRIES IN @lt_Data
*      WHERE PaymentRequest = @lt_Data-keyno.
*
*    ENDIF.
*
*
*    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_pay>).
*
*      lv_budat_f111 = <lfs_pay>-pdate.
*      lv_valut = <lfs_pay>-valut.
*
**Check if value date is less than posting date
*
*      IF NOT <lfs_pay>-pdate IS INITIAL.
*        lv_budat_f111 = <lfs_pay>-pdate.
*      ELSEIF lv_valut LT lv_budat_f111.
*        lv_valut = <lfs_pay>-valut.
*      ENDIF.
*
*      "popluate requestid table for BAPI call
*      lwa_selrequestid = VALUE #( sign = 'I' option = 'EQ' requestid_low = <lfs_pay>-keyno ).
*      APPEND lwa_selrequestid TO lt_selrequestid.
*
*      " test run for payment
*      CALL FUNCTION 'BAPI_PAYMENTREQ_STARTPAYMENT'
*        EXPORTING
*          pstng_date = lv_budat_f111
*          testrun    = abap_true
*        IMPORTING
*          return     = lwa_return
*        TABLES
*          requestid  = lt_selrequestid.
*
*      IF NOT lwa_return IS INITIAL.
*        <lfs_pay>-PaymentStatus = lwa_return-message.
*      ENDIF.
*
*      IF lwa_return IS INITIAL.
*
*        READ TABLE lt_payrq INTO DATA(lwa_payrq) WITH KEY PaymentRequest = <lfs_pay>-keyno.
*
*        "Get the payment medium based on country and payment method
*        CALL FUNCTION 'FI_PAYMENT_FORMAT_INDICATOR'
*          EXPORTING
*            i_country = lwa_payrq-Country
*            i_zwels   = lwa_payrq-PaymentMethod
*          IMPORTING
*            e_xformi  = lv_xpmw.
*
*        "Start payment for selected payment request number (key no)
*        CALL FUNCTION 'BAPI_PAYMENTREQ_STARTPAYMENT' DESTINATION 'NONE'
*          EXPORTING
*            pstng_date              = lv_budat_f111
*            payment_run_log         = abap_true
*            use_payment_medium_tool = lv_xpmw
*          IMPORTING
*            return                  = lwa_return
*            payment_run_date        = lv_run_date
*            payment_run_id          = lv_run_id
*          TABLES
*            requestid               = lt_selrequestid.
*
*        "populate success or error message
*        IF lwa_return IS INITIAL OR lwa_return-type CO 'SI'  .
*          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION 'NONE'
*            EXPORTING
*              wait                  = abap_true
*            IMPORTING
*              return                = lwa_return_commit
*            EXCEPTIONS
*              system_failure        = 1
*              communication_failure = 2.
*
*          IF sy-subrc = 0 .
*            <lfs_pay>-PaymentStatus = 'Payment Successful'(004).
*            <lfs_pay>-RunId = lv_run_id.
*            <lfs_pay>-RunDate = lv_run_date.
*          ELSE.
*            <lfs_pay>-PaymentStatus = lwa_return_commit-message.
*          ENDIF.
*        ELSE.
*          <lfs_pay>-PaymentStatus = lwa_return-message.
*        ENDIF.
*
*        CLEAR: lv_xpmw, lwa_payrq.
*      ENDIF.
*
*      CLEAR: lwa_return, lwa_return_commit, lv_run_date,
*              lv_run_id, lv_budat_f111, lwa_logs,
*              lt_selrequestid, lwa_selrequestid, lv_valut.
*
*    ENDLOOP.
*
*    "update the runid, date and payment status
*    MODIFY ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY bankdata
*    UPDATE FIELDS ( runid rundate paymentstatus )
*    WITH CORRESPONDING #( lt_data )
*
*    MAPPED DATA(lt_mapped_status)
*    REPORTED DATA(lt_reported_status)
*    FAILED DATA(lt_failed_status).
*
*    "Map the data to logs table structure ZTRM_A_FUNDLOGS.
*    maplogsdata(
*          CHANGING
*            ct_data = lt_data
*            ct_logs = lt_logs
*        ).
*
*    "Update logs with runid, date and payment status.
*    MODIFY ENTITIES OF ztrm_i_fndlog
*    ENTITY ztrm_i_fndlog
*    UPDATE FIELDS ( runid rundate paymentstatus )
*    WITH CORRESPONDING #( lt_logs )
*    MAPPED DATA(lt_mapped_stat)
*    REPORTED DATA(lt_reported_stat)
*    FAILED DATA(lt_failed_stat).                                                   .
*
*    "Get the response updated record
*
*    READ ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY bankdata
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(bankdata).
*
*    result = VALUE #( FOR bankrec IN bankdata
*    ( %tky = bankrec-%tky %param = bankrec )
*    ).
*
*  ENDMETHOD.
*
*  "Method to release payment request
*  METHOD releasePayment.
*
*    DATA: lwa_return        TYPE bapiret2,
*          lt_logs           TYPE tt_logs,
*          lwa_return_commit TYPE bapiret2.
*
**Read the selected records
*    READ ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY bankdata
*    ALL FIELDS WITH
*    CORRESPONDING #( keys )
*    RESULT DATA(lt_data).
*
*    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_release>).
*
**Check if the record is already released, if not continue to release
*      IF <lfs_release>-keyno IS NOT INITIAL AND <lfs_release>-releasestatus <> 'Released'(003) .
*
** Test run for payment release
*        CALL FUNCTION 'BAPI_PAYMENTREQUEST_RELEASE'
*          EXPORTING
*            requestid = <lfs_release>-keyno
*            testrun   = abap_true
*          IMPORTING
*            return    = lwa_return.
*
*        IF NOT lwa_return IS INITIAL.
*          <lfs_release>-ReleaseStatus = lwa_return-message.
*
*        ELSE.
*
** BAPI call for payment release
*          CALL FUNCTION 'BAPI_PAYMENTREQUEST_RELEASE'
*            EXPORTING
*              requestid = <lfs_release>-keyno
*              testrun   = space
*            IMPORTING
*              return    = lwa_return.
*
*          IF lwa_return IS INITIAL.
*            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' DESTINATION 'NONE'
*              EXPORTING
*                wait                  = abap_true
*              IMPORTING
*                return                = lwa_return_commit
*              EXCEPTIONS
*                system_failure        = 1
*                communication_failure = 2.
*
*            IF sy-subrc = 0 .
*              <lfs_release>-ReleaseStatus = 'Released'(003).
*            ELSE.
*              <lfs_release>-ReleaseStatus = lwa_return_commit-message.
*            ENDIF.
*          ELSE.
*            <lfs_release>-ReleaseStatus = lwa_return-message.
*          ENDIF.
*
*        ENDIF.
*
*        CLEAR: lwa_return, lwa_return_commit.
*      ENDIF.
*    ENDLOOP.
*
*
*    MODIFY ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY bankdata
*    UPDATE FIELDS ( releasestatus )
*    WITH CORRESPONDING #( lt_data )
*
*    MAPPED DATA(lt_mapped_status)
*    REPORTED DATA(lt_reported_status)
*    FAILED DATA(lt_failed_status).
*
*    "Map the data to logs table structure ZTRM_A_FUNDLOGS.
*    maplogsdata(
*      CHANGING
*        ct_data = lt_data
*        ct_logs = lt_logs
*    ).
*
*    "Update the logs table with Release status
*    MODIFY ENTITIES OF ztrm_i_fndlog
*    ENTITY ztrm_i_fndlog
*    UPDATE FIELDS ( releasestatus )
*    WITH CORRESPONDING #( lt_logs )
*    MAPPED DATA(lt_mapped_stat)
*    REPORTED DATA(lt_reported_stat)
*    FAILED DATA(lt_failed_stat).
*
*    "Get the response updated record
*    READ ENTITIES OF ztrm_i_bankfile IN LOCAL MODE
*    ENTITY bankdata
*    ALL FIELDS WITH CORRESPONDING #( keys )
*    RESULT DATA(bankdata).
*
*    result = VALUE #( FOR bankrec IN bankdata
*    ( %tky = bankrec-%tky %param = bankrec )
*    ).
*
*
*  ENDMETHOD.
*
*  "prepare messages from message class and id
*  METHOD preparemessage.
*
*    DATA: lv_msg TYPE bapiret2-message.
*
*    CALL FUNCTION 'MESSAGE_PREPARE'
*      EXPORTING
*        msg_id                 = iv_msgid
*        msg_no                 = iv_msgno
*        msg_var1               = iv_msgv1
*        msg_var2               = iv_msgv2
*        msg_var3               = iv_msgv3
*        msg_var4               = iv_msgv4
*      IMPORTING
*        msg_text               = lv_msg
*      EXCEPTIONS
*        function_not_completed = 1
*        message_not_found      = 2
*        OTHERS                 = 3.
*
*    IF sy-subrc = 0.
*      ev_message = lv_msg.
*    ENDIF.
*
*  ENDMETHOD.
*
*  "fetch partner account from T018v
*  METHOD getpartneracc.
*
*    " first try with complete key
*    READ TABLE it_t018v INTO DATA(lwa_t018v)
*    WITH KEY bukrs = iv_pbukr
*    hbkid = iv_hbkid
*    zlsch = iv_zlsch
*    waers = iv_waers
*    hktid = iv_hktid
*    sland = iv_sland.
*    IF sy-subrc = 0.
*      ev_gehvk = lwa_t018v-gehvk.
*      CLEAR lwa_t018v.
*    ENDIF.
*
*    IF ev_gehvk = space.
*      "  "like 1. try but without land
*      READ TABLE it_t018v INTO lwa_t018v
*      WITH KEY bukrs = iv_pbukr
*      hbkid = iv_hbkid
*      zlsch = iv_zlsch
*      waers = iv_waers
*      hktid = iv_hktid
*      sland = space.
*      IF sy-subrc = 0.
*        ev_gehvk = lwa_t018v-gehvk.
*        CLEAR lwa_t018v.
*      ENDIF.
*    ENDIF.
*
*    IF ev_gehvk = space.
*      "  without hktid but with land
*      READ TABLE it_t018v INTO lwa_t018v
*      WITH KEY bukrs = iv_pbukr
*      hbkid = iv_hbkid
*      zlsch = iv_zlsch
*      waers = iv_waers
*      hktid = space
*      sland = iv_sland.
*
*      IF sy-subrc = 0.
*        ev_gehvk = lwa_t018v-gehvk.
*        CLEAR lwa_t018v.
*      ENDIF.
*
*    ENDIF.
*
*    IF ev_gehvk = space.
*      " without hktid, without land
*      READ TABLE it_t018v INTO lwa_t018v
*      WITH KEY bukrs = iv_pbukr
*      hbkid = iv_hbkid
*      zlsch = iv_zlsch
*      waers = iv_waers
*      hktid = space
*      sland = space.
*
*      IF sy-subrc = 0.
*        ev_gehvk = lwa_t018v-gehvk.
*        CLEAR lwa_t018v.
*      ENDIF.
*
*    ENDIF.
*
*    IF ev_gehvk = space.
*      " without currency, with hktid, with land
*      READ TABLE it_t018v INTO lwa_t018v
*      WITH KEY bukrs = iv_pbukr
*      hbkid = iv_hbkid
*      zlsch = iv_zlsch
*      waers = space
*      hktid = iv_hktid
*      sland = iv_sland.
*
*      IF sy-subrc = 0.
*        ev_gehvk = lwa_t018v-gehvk.
*        CLEAR lwa_t018v.
*      ENDIF.
*
*    ENDIF.
*
*    IF ev_gehvk = space.
*      " without currency, with hktid, without land
*      READ TABLE it_t018v INTO lwa_t018v
*      WITH KEY bukrs = iv_pbukr
*      hbkid = iv_hbkid
*      zlsch = iv_zlsch
*      waers = space
*      hktid = iv_hktid
*      sland = space.
*
*      IF sy-subrc = 0.
*        ev_gehvk = lwa_t018v-gehvk.
*        CLEAR lwa_t018v.
*      ENDIF.
*    ENDIF.
*
*    IF ev_gehvk = space.
*      " without currency, without hktid, with land
*      READ TABLE it_t018v INTO lwa_t018v
*      WITH KEY bukrs = iv_pbukr
*      hbkid = iv_hbkid
*      zlsch = iv_zlsch
*      waers = space
*      hktid = space
*      sland = iv_sland.
*
*      IF sy-subrc = 0.
*        ev_gehvk = lwa_t018v-gehvk.
*        CLEAR lwa_t018v.
*      ENDIF.
*    ENDIF.
*
*    IF ev_gehvk = space.
*
*      " without currency, without hktid, without land
*      READ TABLE it_t018v INTO lwa_t018v
*      WITH KEY bukrs = iv_pbukr
*      hbkid = iv_hbkid
*      zlsch = iv_zlsch
*      waers = space
*      hktid = space
*      sland = space.
*
*      IF sy-subrc = 0.
*        ev_gehvk = lwa_t018v-gehvk.
*        CLEAR lwa_t018v.
*      ENDIF.
*    ENDIF.
*
*    IF ev_gehvk = space.
*
*      " without payment-method, without currency, without hktid, with land
*      READ TABLE it_t018v INTO lwa_t018v
*      WITH KEY bukrs = iv_pbukr
*      hbkid = iv_hbkid
*      zlsch = space
*      waers = space
*      hktid = space
*      sland = iv_sland.
*
*      IF sy-subrc = 0.
*        ev_gehvk = lwa_t018v-gehvk.
*        CLEAR lwa_t018v.
*      ENDIF.
*    ENDIF.
*
*    IF ev_gehvk = space.
*      " without currency, hktid, land and payment method
*      READ TABLE it_t018v INTO lwa_t018v
*      WITH KEY bukrs = iv_pbukr
*      hbkid = iv_hbkid
*      zlsch = space
*      waers = space
*      hktid = space
*      sland = space.
*      IF sy-subrc = 0.
*        ev_gehvk = lwa_t018v-gehvk.
*        CLEAR lwa_t018v.
*      ENDIF.
*    ENDIF.
*
*
*  ENDMETHOD.
*
*  "prepare logs structure
*  METHOD maplogsdata.
*    ct_logs = VALUE #( FOR lwa_payment IN ct_data (   %key = lwa_payment-%key
*                                                        rpcode = lwa_payment-Rpcode
*                                                        createdat = lwa_payment-CreatedAt
*                                                        createdon = lwa_payment-CreatedOn
*                                                        enduser = lwa_payment-end_user
*                                                        keyno = lwa_payment-Keyno
*                                                        statusicon = lwa_payment-StatusIcon
*                                                        message = lwa_payment-Message
*                                                        paymentstatus = lwa_payment-paymentstatus
*                                                        rwbtr = lwa_payment-rwbtr
*                                                        waers = lwa_payment-waers
*                                                        rptext = lwa_payment-RpText
*                                                        valut = lwa_payment-Valut
*                                                        pdate = lwa_payment-Pdate
*                                                        RunId = lwa_payment-RunId
*                                                        RunDate = lwa_payment-RunDate
*                                                        ReleaseStatus = lwa_payment-ReleaseStatus
*                                                        %control-Rpcode = if_abap_behv=>mk-on
*                                                        %control-CreatedAt = if_abap_behv=>mk-on
*                                                        %control-CreatedOn = if_abap_behv=>mk-on
*                                                        %control-EndUser = if_abap_behv=>mk-on
*                                                        %control-Keyno = if_abap_behv=>mk-on
*                                                        %control-StatusIcon = if_abap_behv=>mk-on
*                                                        %control-message = if_abap_behv=>mk-on
*                                                        %control-Rwbtr = if_abap_behv=>mk-on
*                                                        %control-waers = if_abap_behv=>mk-on
*                                                        %control-Rptext = if_abap_behv=>mk-on
*                                                        %control-pdate = if_abap_behv=>mk-on
*                                                        %control-valut = if_abap_behv=>mk-on
*                                                        %control-paymentstatus = if_abap_behv=>mk-on
*                                                        %control-RunId = if_abap_behv=>mk-on
*                                                        %control-RunDate = if_abap_behv=>mk-on
*                                                        %control-ReleaseStatus = if_abap_behv=>mk-on
*                                                        )  ).
*  ENDMETHOD.
*
*ENDCLASS.
*
*---------------------------------------------------------
  ENDMETHOD.

ENDCLASS.


