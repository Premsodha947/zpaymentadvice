@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PAYMENT ADVICE ITEM CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_PAYMENT_ADVICE_ITEM as select distinct from   I_OperationalAcctgDocItem as A
 
left outer join I_JournalEntry as L on (L.AccountingDocument = A.AccountingDocument)
left outer join ZC_PAYMENT_ADVICE_ITEM_1 as G on (G.AccountingDocument = A.AccountingDocument)
left outer join I_JournalEntryItem as f on ( f.ClearingJournalEntry = A.AccountingDocument  and f.Ledger = '0L')
//                                             and f.TransactionTypeDetermination = 'KBS' 
left outer join I_JournalEntry as E on ( E.AccountingDocument = f.AccountingDocument)


{

key A.AccountingDocument,
A.HouseBankAccount,
  A.CompanyCode,
  A.AccountingDocumentType as TYPEOFACCOUNTING,
   A.FiscalYear,
  A.Plant,
  A.Supplier as VendorNo,
 
  A.PostingDate as Paymentdate,

 L.DocumentReferenceID as CHQNo,
 
 f.AccountingDocument as DOC_NO,
 f.DocumentDate,
 f.AccountingDocumentType,
 f.ProfitCenter,
 f.ClearingJournalEntry,
 

 
 case
  when right( f.ProfitCenter , 4 ) = '1001' then 'H1'
   when right( f.ProfitCenter , 4 ) = '1002' then 'H2'  
   when right( f.ProfitCenter , 4 ) = '1003' then 'H3' else null end as Unit,
   E.DocumentReferenceID as InvoiceNo,
   f.PostingDate as InvoiceDate,
   A.TransactionCurrency,
   @Aggregation.default: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
   f.AmountInTransactionCurrency as InvoiceAmount,
    @Aggregation.default: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
   A.WithholdingTaxAmount as TDS,
    @Aggregation.default: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
//    f.AmountInTransactionCurrency -  G.NetAmount as OtherDeductions,
cast( '0.00' as abap.curr(15,2) ) as OtherDeductions,

    @Aggregation.default: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
   G.NetAmount as NetAmount

 
 
 
}
where A.FinancialAccountType = 'K'
