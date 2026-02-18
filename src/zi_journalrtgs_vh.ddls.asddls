@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for Journal RTGS'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE

@ObjectModel: { dataCategory: #VALUE_HELP,
                representativeKey: 'AccountingDocument',
                usageType: { sizeCategory: #XXL,
                             dataClass: #TRANSACTIONAL,
                             serviceQuality: #A },
                supportedCapabilities: [#VALUE_HELP_PROVIDER],
                modelingPattern: #VALUE_HELP_PROVIDER }

@Search.searchable: true
@Consumption.ranked: true

define view entity ZI_JournalRTGS_VH as select from I_JournalEntry
{
     @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.7
  @Search.ranking: #HIGH
  key AccountingDocument
} where AccountingDocumentType = 'KZ'  or AccountingDocumentType = 'ZP' 
