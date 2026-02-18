@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption cds view for Payment'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZC_Payment_Item as  select from  ZI_Payment_Item
{
    key CompanyCode,
    key FiscalYear,
    key AccountingDocument,
    key LedgerGLLineItem,
    SpecialGLCode,
    Yourdoc,
    ClearingJournalEntry,
    Supplierinvoice,
    DebitCreditCode,
    AccoutDocType,
    AccountingDocumentType,
    Postingdate,
    DocumentCurrency,
    @Semantics.amount.currencyCode: 'DocumentCurrency'
    Miroamt,
    CompanyCodeCurrency,
    @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
    Deductionamt,
    @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
    CashDiscountAmount,
    @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
    case
    when DebitCreditCode = 'S'
    then cast (coalesce(cast(amtpaid as abap.dec(23,2)), 0)  * -1 as abap.curr( 23,2 )) 
    else 
    amtpaid end as amtpaid,
    Unit,
     @Semantics.amount.currencyCode: 'DocumentCurrency'
    Miroamt -  amtpaid as OtherDeductions
    
//    DOC_NUM,
//    DOC_TYPE,
//    DOC_DATE
    
}
