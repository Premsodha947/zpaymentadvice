@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds view for invoice filter'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_journal_Exclusion as select from I_JournalEntryItem
{
 
    key CompanyCode,
    key FiscalYear,
    key AccountingDocument,
    key min(LedgerGLLineItem) as LedgerGLLineItem,
     Ledger,
     AccountingDocumentType,
     ClearingJournalEntry
     
} where ClearingJournalEntry is not initial
 and Ledger = '0L'
 and SpecialGLCode is initial
 group by
    CompanyCode,
    FiscalYear,
    AccountingDocument,
    LedgerGLLineItem,
     Ledger,
     AccountingDocumentType,
     InvoiceReference,
     ClearingJournalEntry
