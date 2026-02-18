@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds for Clearing Journal Entry'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_ClearingJournalEntry as select from I_JournalEntryItem as journal

 inner join ZI_ClearingJournalEntry_MIN as _min on journal.ClearingJournalEntry = _min.ClearingJournalEntry
                                               and journal.LedgerGLLineItem = _min.LedgerGLLineItem
                                               and journal.Ledger = _min.Ledger
                                               and journal.FiscalYear = _min.FiscalYear
                                               and journal.CompanyCode = _min.CompanyCode
                                               and journal.ReferenceDocument = _min.ReferenceDocument
                                               
{
    journal.AccountingDocument,
    journal.AccountingDocumentItem,
    journal.ClearingJournalEntry,
    journal.LedgerGLLineItem,
    journal.DocumentDate,
    journal.Ledger,
    journal.FiscalYear,
    journal.CompanyCode,
    journal.ReferenceDocument,
    journal.ReferenceDocumentItem,
    journal.DebitCreditCode,
    journal.AccountingDocumentType,
    journal.Supplier,
    journal.CompanyCodeCurrency,
    @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
    journal.AmountInTransactionCurrency
}
