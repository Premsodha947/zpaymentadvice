@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds view for condition on ledger'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_Journalentryitem_ledger as select from ZI_JournalEntry_item_partial as _item
   
  // left outer join ZI_Payment_InvoiceRef as _invoice on _invoice.CompanyCode = _item.CompanyCode
  //                                                  and _invoice.FiscalYear = _item.FiscalYear
  //                                                  and _invoice.AccountingDocument = _item.AccountingDocument
  //                                                  and _invoice.LedgerGLLineItem <> _item.LedgerGLLineItem
{
    key _item.CompanyCode,
    key _item.FiscalYear,
    key _item.AccountingDocument,
    key min(_item.LedgerGLLineItem) as LedgerGLLineItem,
     _item.Ledger,
     _item.AccountingDocumentType,
     _item.DocumentDate,
     _item.SpecialGLCode,
     _item.PartialDocument
//     _invoice.InvoiceReference
     
} where _item.Ledger = '0L'
and 
(_item.AccountingDocumentType = 'KZ' 
or _item.AccountingDocumentType = 'UE'  or  _item.AccountingDocumentType = 'ZP' )
group by 
        _item.CompanyCode,
       _item.FiscalYear,
       _item.AccountingDocument,
     _item.Ledger,
     _item.AccountingDocumentType,
     _item.DocumentDate,
     _item.SpecialGLCode,
 //    _invoice.InvoiceReference,
     _item.PartialDocument
     
