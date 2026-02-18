@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds view for Payment invoice reference'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_Payment_InvoiceRef as select from I_JournalEntryItem as _item

left outer join ZI_journal_Exclusion as _exc on         _exc.CompanyCode = _item.CompanyCode
                                                    and _exc.FiscalYear = _item.FiscalYear
                                                    and _exc.AccountingDocument = _item.AccountingDocument
{
 
    key _item.CompanyCode,
    key _item.FiscalYear,
    key _item.AccountingDocument,
    key _item.LedgerGLLineItem,
     _item.Ledger,
     _item.AccountingDocumentType,
     case when _exc.ClearingJournalEntry is not initial
      then ''
      else
     _item.InvoiceReference end as InvoiceReference,
     _item.ClearingJournalEntry,
     _item.DocumentDate,
     _item.CompanyCodeCurrency,
     @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
     _item.AmountInTransactionCurrency,
     _exc.ClearingJournalEntry as EXClearingJournalEntry,
     
     _item.TransactionTypeDetermination
     
} where _item.InvoiceReference is not initial and _item.ClearingJournalEntry is initial
 
 and _item.Ledger = '0L'
 and _item.SpecialGLCode is initial
