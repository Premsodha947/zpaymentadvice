@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds for invoice supplier doc'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_insupplier_Doc as select from I_JournalEntryItem as _item
left outer join  I_SupplierInvoiceAPI01     as _invoice on  
                                                           _item.FiscalYear        = _invoice.FiscalYear
                                                           and _item.CompanyCode       = _invoice.CompanyCode
                                                           and _item.ReferenceDocument = _invoice.SupplierInvoice
{
    
    key _item.CompanyCode,
    key _item.FiscalYear,
    key _item.AccountingDocument,
    key min(_item.LedgerGLLineItem) as LedgerGLLineItem,
    _item.ReferenceDocument,
    _invoice.SupplierInvoiceIDByInvcgParty
    
} where _item.Ledger = '0L' and  
  _item.DebitCreditCode = 'S' and _item.ReferenceDocument is not initial
group by _item.CompanyCode,
    _item.FiscalYear,
    _item.AccountingDocument,
    _item.ReferenceDocument,
    _invoice.SupplierInvoiceIDByInvcgParty
