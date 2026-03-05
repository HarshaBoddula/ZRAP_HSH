@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZI_BIRAP_ATRAV_AG_CUBE'
@Metadata.ignorePropagatedAnnotations: true
@Analytics.dataCategory: #CUBE
@VDM.viewType: #COMPOSITE
define view entity ZI_BIRAP_ATRAV_AG_CUBE as select from ZR_BIRAP_ATRAV
{
  /* Dimension (Donut slices) */
  @AnalyticsDetails.query.axis: #ROWS
  @EndUserText.label: 'Agency'
  AgencyID,

  /* Measure (Donut value) */
  @AnalyticsDetails.query.axis: #COLUMNS
//  @DefaultAggregation: #SUM
  @EndUserText.label: 'Total Travel Price'
  @Semantics.amount.currencyCode: 'CurrencyCode'
  sum( TotalPrice ) as TotalPrice,
  CurrencyCode
}
group by AgencyID, CurrencyCode;
