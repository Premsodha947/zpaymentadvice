@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds view for Partial Pick up'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_Journal_Partial as select from I_JournalEntryItem
{
    key CompanyCode,
    key FiscalYear,
    key AccountingDocument,
    key LedgerGLLineItem,
     Ledger,
     AccountingDocumentType,
     ClearingJournalEntry,
     'PA' as PartialDocument
     
} where ReferenceDocumentItem > '000001'
 and ClearingJournalEntry is initial
