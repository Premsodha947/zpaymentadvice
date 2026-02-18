@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds view to add partial Check'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_JournalEntry_item_partial as select from I_JournalEntryItem as _item
  left outer join ZI_Journal_Partial as _partial on _item.AccountingDocument = _partial.AccountingDocument
                                                           and _item.LedgerGLLineItem   = _partial.LedgerGLLineItem
                                                           and _item.Ledger             = _partial.Ledger
                                                           and _item.FiscalYear         = _partial.FiscalYear
                                                           and _item.CompanyCode        = _partial.CompanyCode
                                                           and _partial.Ledger = '0L'
{
    key _item.CompanyCode,
    key _item.FiscalYear,
    key _item.AccountingDocument,
    key _item. LedgerGLLineItem,
     _item.Ledger,
     _item.AccountingDocumentType,
     _item.DocumentDate,
     _item.SpecialGLCode,
     _item.InvoiceReference,
     coalesce(_partial.PartialDocument, 'CL') as PartialDocument
     
}
