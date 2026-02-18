@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS ZADVANCE_PAYMENT_INV'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZADVANCE_PAYMENT_INV as select from I_OperationalAcctgDocItem as A


left outer join I_JournalEntryItem as M on ( M.ClearingJournalEntry = A.ClearingJournalEntry and M.Ledger = '0L' and M.TransactionTypeDetermination = 'KBS' ) //ADVANCE PAYMENT AGAINST INVOICE 

left outer join ZC_PAYMENT_ADVICE_ITEM_1 as G on (G.AccountingDocument = A.AccountingDocument)

left outer join I_JournalEntry as E on ( E.AccountingDocument = M.AccountingDocument)


{
 key   M.AccountingDocument as DOC_NO,
 key A.AccountingDocument,
  A.CompanyCode,
 
   A.FiscalYear,
    M.DocumentDate,
    M.AccountingDocumentType,
    
    M.TransactionCurrency,
     @Aggregation.default: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
   M.AmountInTransactionCurrency as InvoiceAmount,
    @Aggregation.default: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
   A.WithholdingTaxAmount as TDS,


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



group by
 M.AccountingDocument ,
    M.DocumentDate,
    M.AccountingDocumentType,
 M.TransactionCurrency,
 M.AmountInTransactionCurrency,
 A.WithholdingTaxAmount,
  A.AccountingDocument,
   A.CompanyCode,
 
   A.FiscalYear,
    M.ProfitCenter,
 E.DocumentReferenceID,
 M.PostingDate,
  G.NetAmount
