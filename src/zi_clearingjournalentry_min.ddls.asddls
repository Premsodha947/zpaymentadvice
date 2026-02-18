@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds for journal Entry Clearing Min'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_ClearingJournalEntry_MIN as select from I_JournalEntryItem
{
   ClearingJournalEntry,
   min(LedgerGLLineItem) as LedgerGLLineItem,
   Ledger,
   FiscalYear,
   CompanyCode,
   ReferenceDocument
   
} where Ledger = '0L'
group by 
   ClearingJournalEntry,
   Ledger,
   FiscalYear,
   CompanyCode,
   ReferenceDocument
   
