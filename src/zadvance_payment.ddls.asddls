@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS OF ZADVANCE_PAYMENT'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZADVANCE_PAYMENT as select from I_OperationalAcctgDocItem as a



//left outer join I_JournalEntryItem as M on ( M.ClearingAccountingDocument = a.ClearingJournalEntry and M.Ledger = '0L' and M.TransactionTypeDetermination = 'KBS' ) //PARTIAL 1 
//
left outer join ZC_PAYMENT_ADVICE_ITEM_1 as G on (G.AccountingDocument = a.AccountingDocument)
//
left outer join I_JournalEntry as E on ( E.AccountingDocument = a.AccountingDocument)




{
 key   a.AccountingDocument as DOC_NO,
    a.DocumentDate,
    a.AccountingDocumentType,
    
      a.CompanyCode,
 
   a.FiscalYear,
    
    a.TransactionCurrency,

//  '0.00' as InvoiceAmount,
    @Aggregation.default: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
  a.WithholdingTaxAmount as TDS,

//  '0.00' as otherdeductions
cast( 0 as abap.dec(15,2) ) as OtherDeductions,
 cast( 0 as abap.dec(15,2) ) as InvoiceAmount,  //0.00

   cast( '00000000' as dats ) as invoicedate, //blank
   
  
 
  
  
  
   case
  when right( a.ProfitCenter , 4 ) = '1001' then 'H1'
   when right( a.ProfitCenter , 4 ) = '1002' then 'H2'  
   when right( a.ProfitCenter , 4 ) = '1003' then 'H3' else null end as Unit,
      
         E.DocumentReferenceID as InvoiceNo,
 
         @Aggregation.default: #SUM
@Semantics: { amount : {currencyCode: 'TransactionCurrency'} }
       G.NetAmount as NetAmount
  
  
  
}
group by
 a.AccountingDocument ,
    a.DocumentDate,
    a.AccountingDocumentType,
 a.TransactionCurrency,
 
 a.WithholdingTaxAmount,
   a.CompanyCode,
 
   a.FiscalYear,
a.ProfitCenter,
 E.DocumentReferenceID,
// M.PostingDate,
  G.NetAmount
