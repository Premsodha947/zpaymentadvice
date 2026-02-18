@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS ZPARTIAL2_PAYMENT'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZPARTIAL2_PAYMENT as select from I_OperationalAcctgDocItem as A


left outer join I_JournalEntryItem as M on ( M.ClearingJournalEntry = A.ClearingJournalEntry and M.Ledger = '0L' 
                          and M.TransactionTypeDetermination = 'KBS' ) //PARTIAL 1 


left outer join ZC_PAYMENT_ADVICE_ITEM_1 as G on (G.AccountingDocument = A.AccountingDocument)

left outer join I_JournalEntry as E on ( E.AccountingDocument = M.AccountingDocument)
{

key A.AccountingDocument,
 key   M.AccountingDocument as DOC_NO,
    M.DocumentDate,
    M.AccountingDocumentType,
    
    A.CompanyCode,
 
   A.FiscalYear,
    
    M.TransactionCurrency,
     @Aggregation.default: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
   M.AmountInTransactionCurrency as InvoiceAmount,
    @Aggregation.default: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
   A.WithholdingTaxAmount as TDS,
//    @Aggregation.default: #SUM
//@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
//  ( f.AmountInTransactionCurrency + A.WithholdingTaxAmount ) -  A.AmountInTransactionCurrency as OtherDeductions,

 case
  when right( M.ProfitCenter , 4 ) = '1001' then 'H1'
   when right( M.ProfitCenter , 4 ) = '1002' then 'H2'  
   when right( M.ProfitCenter , 4 ) = '1003' then 'H3' else null end as Unit,
      
         E.DocumentReferenceID as InvoiceNo,
         
        M.PostingDate as InvoiceDate,
             @Aggregation.default: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
          M.AmountInTransactionCurrency -  G.NetAmount as OtherDeductions,
         @Aggregation.default: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       G.NetAmount as NetAmount


}
where A.FinancialAccountType = 'K'
group by
 A.AccountingDocument,
 M.AccountingDocument ,
    M.DocumentDate,
    M.AccountingDocumentType,
 M.TransactionCurrency,
 M.AmountInTransactionCurrency,
 A.WithholdingTaxAmount,
 M.ProfitCenter,
 E.DocumentReferenceID,
 M.PostingDate,
  G.NetAmount,
  A.CompanyCode,
 
   A.FiscalYear
 
