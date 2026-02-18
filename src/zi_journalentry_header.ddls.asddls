@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds for Journal Header Min'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_JournalEntry_Header as select from I_JournalEntryItem
{
    key CompanyCode,
    key FiscalYear,
    key AccountingDocument,
    min(LedgerGLLineItem) as LedgerGLLineItem,
    Ledger,
    AccountingDocumentType,
    Supplier,
    DocumentDate
}
where Ledger = '0L'
and 
(AccountingDocumentType = 'KZ' 
or AccountingDocumentType = 'UE'  or AccountingDocumentType = 'ZP' )
and Supplier is not initial
group by
    CompanyCode,
    FiscalYear,
    AccountingDocument,
    Ledger,
    AccountingDocumentType,
    Supplier,
    DocumentDate
